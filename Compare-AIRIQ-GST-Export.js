// Read-only comparison. Array order is normalized only for keyed posting collections.
const fs = require('fs');
const crypto = require('crypto');
const oldPath = 'AIRIQ-GST-Source/6b464955-261f-4eaf-a749-7807444fc37c.json';
const exportPath = 'GST.json';
const read = p => JSON.parse(fs.readFileSync(p, 'utf8').replace(/^\uFEFF/, ''));
const hash = p => crypto.createHash('sha256').update(fs.readFileSync(p)).digest('hex').toUpperCase();
const old = read(oldPath)[0];
const cases = read(exportPath);
if (cases.length !== 1 || cases[0].CaseID !== old.CaseID || cases[0].Version !== 7 || cases[0].MinorVersion !== 1)
  throw Error('Expected exact Sandbox case 6B464955 at version 7.1');
function normalize(value, key = '') {
  if (Array.isArray(value)) {
    const result = value.map(v => normalize(v));
    const sortKey = {TaxPostingSetup: 'ComponentName', When: 'Sequence', InsertRecordFields: 'Sequence'}[key];
    if (sortKey) {
      if (new Set(result.map(v => v[sortKey])).size !== result.length) throw Error('Duplicate posting key');
      result.sort((a,b) => String(a[sortKey]).localeCompare(String(b[sortKey])));
    }
    return result;
  }
  if (value && typeof value === 'object')
    return Object.fromEntries(Object.keys(value).sort().map(k => [k, normalize(value[k], k)]));
  return value;
}
function differences(a, b, path = '$', result = []) {
  if (JSON.stringify(a) === JSON.stringify(b)) return result;
  if (a && b && typeof a === 'object' && typeof b === 'object' && Array.isArray(a) === Array.isArray(b)) {
    for (const k of new Set([...Object.keys(a), ...Object.keys(b)])) differences(a[k], b[k], `${path}.${k}`, result);
  } else result.push({Path: path, Before: a, After: b});
  return result;
}
const current = cases[0];
const report = {
  CaseID: old.CaseID, LocalSource: oldPath, LocalSHA256: hash(oldPath),
  SandboxExport: exportPath, SandboxSHA256: hash(exportPath),
  FromVersion: '7.0', ToVersion: '7.1',
  RawChangedProperties: Object.keys(old).filter(k => JSON.stringify(old[k]) !== JSON.stringify(current[k])),
  SemanticDifferences: differences(normalize(old), normalize(current)),
  PostingMappingsSemanticallyEqual: JSON.stringify(normalize(old.TaxPostingSetup, 'TaxPostingSetup')) === JSON.stringify(normalize(current.TaxPostingSetup, 'TaxPostingSetup')),
  UnchangedProperties: Object.keys(old).filter(k => JSON.stringify(old[k]) === JSON.stringify(current[k])),
  NormalizedPostingCollections: ['TaxPostingSetup by ComponentName', 'When by Sequence', 'InsertRecordFields by Sequence'],
  TenantActions: 'NONE'
};
fs.writeFileSync('AIRIQ-GST-Custom/sandbox-71-comparison.json', JSON.stringify(report, null, 2) + '\n');
console.log(JSON.stringify(report, null, 2));
