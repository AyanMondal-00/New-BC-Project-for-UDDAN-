# Tree import correction (2026-11-02)

Corrected `AIRIQ-UseCaseTree-Nodes.json`: 12 custom nodes, 3,123 bytes.

Inspected codeunit 20299 from the installed Tax Engine 28.5.54976.56550
package; reference source is in `importer-source/UseCaseTreeIndent.Codeunit.al`.
ImportNodes uploads an InStream, reads all lines through
TypeHelper.ReadAsTextWithSeparator(IStream, ''), and calls ReadUseCaseTree.
ReadUseCaseTree starts with JArray.ReadFrom(JsonText), then iterates objects
through JToken.AsObject(), and calls Indent(). It expects an array of objects.
The original root was correct; pretty printing does not truncate this reader.

## Defects and changes

- Original first bytes: EF BB BF 5B (UTF-8 BOM followed by array opener).
  Successful BC export: 5B 7B (no BOM). The import path does not explicitly
  select encoding or clean a BOM before parsing text. A retained BOM or its
  codepage-decoded characters cannot start a JSON token. This is the identified
  format defect consistent with the initial ReadFrom failure. Strict JSON
  parsing reproduces failure on BOM-prefixed text. Actual BC stream decoding
  and runtime acceptance were not tested, as tenant operations are prohibited.
- Removed all 12 `Condition: null` properties. ExportSingleTreeNode omits
  Condition when its blob has no value; the object importer expects AsText()
  when that property is present. Null was a second schema defect, reached after
  root parsing. These custom leaves now have the same seven fields as the
  corresponding exported leaves.
- Output is compact UTF-8 without BOM. Every payload character is ASCII,
  eliminating codepage ambiguity. Code remains the first property because the
  importer loads/inserts the record while processing Code.
- No tree generator script was found. Added reproducible generator and
  validator `Build-AIRIQ-UseCaseTree.js`; run it with Node from the project root.
  It derives nodes from the BC export and existing manifest, preserves the
  original artifact values except null Condition, and explicitly writes no BOM.

All original codes, names, CaseIDs, TableID, NodeType, TaxType and IsTaxTypeRoot
values are unchanged. Case JSON files, formulas and posting data were untouched.

## Source and ordering

The requested AIRIQ-GST-Source/UseCaseTree (3).json is absent. Used the available
root UseCaseTree (3).json (11 exported nodes TE-112400 through TE-112410).
The generator prefers the requested path if it becomes available.
Source SHA-256: 6e5821af368539cbdf9c0c80903a11ce4925f805d26a5072c3d15af1cf5f3f23.
The source remains byte-identical.

Pairs TE-112400A01/A02 through TE-112405A01/A02 sort immediately before their
matching standard leaves TE-112401 through TE-112406 in the Item branch.
The offline merged sequence has 23 nodes; all 11 Microsoft nodes retain their
original values and relative order. No Microsoft nodes are in the custom import.
Export/SEZ nodes TE-112407 through TE-112410 are not cloned or edited. Placement
is verified within the supplied branch, not against an unavailable full tenant tree.

## Validation

PASS: strict UTF-8 decoding, strict JSON parsing without BOM stripping, array
root, 12 objects, exported field schema/types, unique codes/IDs, Code[20] and
Name[250] limits, all CaseID mappings to case files/manifest, original value
preservation except null Condition, pair ordering, source preservation, and
upload line-joining simulation. Repeated generation produces the same hash.

Existing GST validator: PASS, 1,300 checks including 720 numeric scenarios.
Existing case-file encoding/parser validator: PASS.

See tree-import-validation.json for hashes and all placements, and
tree-format-before.json for original byte evidence. Original artifact preserved
in .snapshots/airiq-tree-import-fix/original-tree.json. This report supersedes
the earlier execution-tree report's claim that null Condition matched the export.

No BC import or tenant modification was performed; runtime success is not claimed.
The custom Use Cases must exist before a future tree-node import.
