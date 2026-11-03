// Offline byte/parser regression for the Microsoft Tax Engine upload format.
const fs = require('fs');
const crypto = require('crypto');
const assert = require('assert/strict');
const hash = b => crypto.createHash('sha256').update(b).digest('hex');
const before = JSON.parse(fs.readFileSync('AIRIQ-GST-Custom/import-format-before.json', 'utf8'));
const results = [];
for (const previous of before) {
  const bytes = fs.readFileSync(previous.file);
  const custom = previous.file.startsWith('AIRIQ-GST-Custom/');
  const text = new TextDecoder('utf-8', {fatal: true, ignoreBOM: true}).decode(bytes);
  if (!custom) {
    assert.equal(hash(bytes), previous.sha256, 'Microsoft source must remain byte-identical');
    continue;
  }
  assert.notEqual(bytes.subarray(0, 3).toString('hex'), 'efbbbf', 'No UTF-8 BOM');
  assert.equal(bytes[0], 0x5b, 'Array must start at byte zero');
  const cases = JSON.parse(text); // Deliberately do not strip a BOM.
  assert(Array.isArray(cases));
  assert.equal(cases.length, 6);
  assert(cases.every(c => c && typeof c === 'object' && !Array.isArray(c)));
  assert.equal(hash(JSON.stringify(cases)), previous.semanticSHA256, 'All case data preserved');
  // Type Helper joins ReadText lines with an empty separator.
  assert.deepEqual(JSON.parse(text.split(/\r\n|\n|\r/).join('')), cases);
  // These payloads are ASCII, so the default stream codepage cannot alter them.
  assert(bytes.every(b => b < 128), 'Codepage-independent payload');
  const original = Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), bytes]).toString('utf8');
  assert.throws(() => JSON.parse(original), SyntaxError, 'BOM-prefixed text fails strict JSON parsing');
  results.push({file: previous.file, result: 'PASS', bytes: bytes.length,
    sha256: hash(bytes), root: 'array of objects', cases: cases.length,
    utf8BOM: false, semanticDataUnchanged: true, caseIDs: cases.map(c => c.CaseID)});
}
fs.writeFileSync('AIRIQ-GST-Custom/import-format-validation.json', JSON.stringify({
  result: 'PASS', results, microsoftSourcesUnchanged: true,
  runtimeImport: 'NOT RUN; offline checks only'
}, null, 2) + '\n');
console.log('PASS: strict UTF-8/JSON, array root, upload line joining, 12 unchanged cases, unchanged Microsoft sources.');
