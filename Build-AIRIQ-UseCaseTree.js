// Rebuild and validate custom-only nodes against the actual BC branch export.
const fs = require('fs');
const assert = require('assert/strict');
const crypto = require('crypto');
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const requested = 'AIRIQ-GST-Source/UseCaseTree (3).json';
const source = fs.existsSync(requested) ? requested : 'UseCaseTree (3).json';
const output = 'AIRIQ-GST-Custom/AIRIQ-UseCaseTree-Nodes.json';
const read = file => JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, ''));
const sourceBytes = fs.readFileSync(source);
const standard = read(source);
const manifest = read('AIRIQ-GST-Custom/case-manifest.json');
const old = read(output);
const cases = ['Domestic', 'International'].flatMap(f => read(`AIRIQ-GST-Custom/AIRIQ-GST-${f}.json`));
const id = value => value.replace(/[{}]/g, '').toUpperCase();
const compare = (a, b) => a.Code < b.Code ? -1 : a.Code > b.Code ? 1 : 0;
assert(Array.isArray(standard));
assert.equal(standard.length, 11);
assert.equal(standard[0].Code, 'TE-112400');
assert.equal(standard[0].NodeType, 'Begin');
assert.equal(standard[0].TableID, 37);
assert.equal(standard[0].Condition, 'VERSION(1) SORTING(Field1,Field3,Field4) WHERE(Field5=1(2))');
assert.deepEqual([...standard].sort(compare), standard);
const nodes = [], placements = [];
for (let index = 1; index < standard.length; index++) {
  const sibling = standard[index];
  const mappings = manifest.filter(m => id(m.SourceCaseID) === id(sibling.CaseID));
  if (!mappings.length) continue; // Preserve export/SEZ leaves without cloning them.
  assert.equal(mappings.length, 2);
  for (const [flightIndex, flight] of ['Domestic', 'International'].entries()) {
    const mapping = mappings.find(m => m.FlightType === flight);
    assert(mapping);
    const customCase = cases.find(c => id(c.CaseID) === id(mapping.CaseID));
    assert(customCase);
    const code = `${standard[index - 1].Code}A0${flightIndex + 1}`;
    // Code must be first: the importer gets/inserts the record on this property.
    const node = {Code: code, Name: `AIRIQ ${flight} - ${sibling.Name}`,
      NodeType: sibling.NodeType, TableID: sibling.TableID, CaseID: mapping.CaseID};
    // Microsoft exports Condition only when the blob has a value; never emit null.
    if (Object.hasOwn(sibling, 'Condition')) {
      assert.equal(typeof sibling.Condition, 'string');
      node.Condition = sibling.Condition;
    }
    node.TaxType = sibling.TaxType;
    node.IsTaxTypeRoot = sibling.IsTaxTypeRoot;
    assert.equal(node.NodeType, 'Use Case');
    assert.equal(node.TableID, 37);
    assert(node.Code.length <= 20 && node.Name.length <= 250);
    assert(standard[index - 1].Code < code && code < sibling.Code);
    assert(!standard.some(s => s.Code === code));
    assert.deepEqual(Object.keys(node), Object.keys(sibling));
    nodes.push(node);
    placements.push({Code: code, CaseID: node.CaseID, beforeStandard: sibling.Code});
  }
}
assert.equal(nodes.length, 12);
assert.equal(new Set(nodes.map(n => n.Code)).size, 12);
assert.equal(new Set(nodes.map(n => id(n.CaseID))).size, 12);
assert.deepEqual(nodes.map(n => id(n.CaseID)).sort(), manifest.map(m => id(m.CaseID)).sort());
// Preserve every original node value except the invalid optional null property.
const normalize = list => list.map(n => Object.fromEntries(Object.entries(n)
  .filter(([key, value]) => !(key === 'Condition' && value === null))
  .sort(([a], [b]) => a < b ? -1 : a > b ? 1 : 0)));
assert.deepEqual(normalize(nodes), normalize(old));
const merged = [...standard, ...nodes].sort(compare);
assert.deepEqual(merged.filter(n => standard.includes(n)), standard);
for (const sibling of standard.slice(1, 7)) {
  const index = merged.indexOf(sibling);
  const pair = placements.filter(p => p.beforeStandard === sibling.Code);
  assert.equal(pair.length, 2);
  assert.deepEqual(merged.slice(index - 2, index).map(n => n.Code), pair.map(p => p.Code));
}
const bytes = Buffer.from(JSON.stringify(nodes), 'utf8');
assert(bytes.every(b => b < 128));
assert.equal(bytes[0], 0x5b);
const text = new TextDecoder('utf-8', {fatal: true, ignoreBOM: true}).decode(bytes);
assert.deepEqual(JSON.parse(text), nodes);
assert.deepEqual(JSON.parse(text.split(/\r\n|\n|\r/).join('')), nodes);
assert.throws(() => JSON.parse('\uFEFF' + text), SyntaxError);
assert.equal(hash(fs.readFileSync(source)), hash(sourceBytes));
fs.writeFileSync(output, bytes); // Explicit UTF-8, no BOM, compact array.
const report = {Result: 'PASS', Source: source, SourceSHA256: hash(sourceBytes),
  Output: output, OutputSHA256: hash(bytes), Bytes: bytes.length,
  Nodes: nodes.length, MicrosoftNodes: standard.length, MergedNodes: merged.length,
  Root: 'array of objects', UTF8BOM: false, NullConditions: 0,
  OriginalCodesAndCaseIDsPreserved: true, MicrosoftSourceUnchanged: true,
  PlacementScope: 'Supplied TE-112400 Item branch only; full tenant tree not supplied',
  Placements: placements, RuntimeImport: 'NOT RUN; no tenant changes'};
fs.writeFileSync('AIRIQ-GST-Custom/tree-import-validation.json', JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report, null, 2));
