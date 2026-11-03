# AIRIQ GST import format correction

Inspected the exact local Domestic and International files and source extracted
from Microsoft_Tax Engine_28.5.54976.56550.app. No tenant operations performed.

## Root cause and importer contract

Both original files were valid JSON arrays after explicitly removing a UTF-8
BOM, but their first bytes were EF BB BF 5B. The successful Microsoft GST.json
7.1 export starts 5B 7B, with no BOM. Windows PowerShell's
`Set-Content -Encoding UTF8` in Build-AIRIQ-GST-Cases.ps1 introduced the BOM.

Codeunit 20361, TaxJsonDeserialization.Codeunit.al, ImportUseCases declares
`TaxUseCaseJArray: JsonArray` and immediately calls
`TaxUseCaseJArray.ReadFrom(JsonText)`. This is the first statement (reported
line 5). ReadUseCases iterates that array and calls
`ReadUseCase(JToken.AsObject())` for each element. The expected root is an array
of case objects, including for a single case. There is no wrapper object and
no requirement to split six cases into six files. The existing roots were correct.

UseCaseArchivalMgmt.Codeunit.al, ImportUseCases uploads into an InStream and
calls `TypeHelper.ReadAsTextWithSeparator(IStream, '')`. It does not explicitly
select UTF-8 or remove a BOM. TypeHelper.Codeunit.al reads ALL lines with
ReadText and joins them; pretty printing is not a root-type or truncation issue.
No BOM cleanup occurs before JsonArray.ReadFrom. A BOM retained as U+FEFF,
or decoded as codepage characters, is not JSON whitespace and causes the
initial token parse to fail. Strict JSON parsing reproduces the failure with a
BOM-prefixed text string. Thus the identified file-format defect is the BOM /
stream encoding boundary, not the root shape or case data. Actual BC stream
decoding and a successful runtime import cannot be confirmed offline; no tenant
import was attempted as instructed.

## Corrected files

- AIRIQ-GST-Domestic.json: six unchanged custom cases; Amount/20 (5%).
- AIRIQ-GST-International.json: six unchanged custom cases; Amount/10 (10%).

Both now use compact UTF-8 without BOM, starting directly with `[`, matching
Microsoft's export format. All payload characters are ASCII, eliminating
codepage ambiguity. The generator now explicitly uses UTF8Encoding(false),
preventing recurrence under Windows PowerShell.

## Validation

- Existing Test-AIRIQ-GST-Cases.ps1: PASS, 1,300 checks, 12 cases,
  720 numeric scenarios; see validation-results.json.
- Test-AIRIQ-GST-Import.js: PASS, strict UTF-8 decoding, strict JSON parsing
  without BOM stripping, array/object structure, six cases per file, no BOM,
  upload line-joining simulation, and ASCII compatibility.
- Semantic SHA-256 hashes before/after match for both entire arrays: all 12
  CaseIDs, rates/formulas, conditions, scripts, inheritance and GST posting
  data are preserved without any semantic changes.
- Microsoft GST.json and all AIRIQ-GST-Source JSON files remain byte-identical.
- See import-format-before.json and import-format-validation.json for byte
  evidence, hashes and all preserved custom IDs. Extracted installed source
  is in importer-source; it is reference evidence and was not modified.
- No Microsoft standard cases modified. No BC import, tenant change, or
  runtime posting test performed. These are corrected offline import artifacts;
  runtime acceptance is not claimed.

Reproduce from the project root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Build-AIRIQ-GST-Cases.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\Test-AIRIQ-GST-Cases.ps1
node Test-AIRIQ-GST-Import.js
```
