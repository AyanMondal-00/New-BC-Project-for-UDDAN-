# AIRIQ GST delivery

The import files are complete Tax Engine use-case arrays for the existing AIRIQ **Item sales invoice** workflow. Domestic uses `Sales Line."AIRIQ GST Base Fare" * Sales Line.Quantity / 20`; International divides by 10. Each component uses its configured Component Percent on that same reduced base. Other Charges remain in Unit Price and invoice Amount but are excluded from GST Base. No component tax rate is hard-coded.

Own Sales has Decimal Base Fare and Pax; invoice creation makes one line per passenger with Quantity 1, or a fallback line with Quantity = Pax. The existing display-only Sales Line.BaseFare is Text and is retained. API Sales and Third Party Sales have no separate Base Fare or Other Charges; their Rate maps to the new numeric fare field. The Tax Engine receives fare and Quantity through explicit Current Record lookups in each JSON formula. Existing unposted lines created before this mapping need the new fare field populated before using the amended cases.

`FlightType` is Sales Line field 50426, Text[50]. Direct Current Record lookup resolves the table field; no Tax Attribute registration is needed. The small table-extension validation trigger re-runs Microsoft's Calculate Tax when FlightType is changed or cleared on an Item invoice. It does not assign Amount, Quantity or Unit Price. Existing AIRIQ creation routines already validate FlightType before Quantity and Unit Price.

Only these two files are BC imports (six cases each):

- `AIRIQ-GST-Custom/AIRIQ-GST-Domestic.json`
- `AIRIQ-GST-Custom/AIRIQ-GST-International.json`

`case-manifest.json` maps every custom ID to its Microsoft source ID/version/hash and source origin. The two registered intra-state cases now use the confirmed Sandbox `GST.json` export at 7.1 and custom version 1.3; the other ten retain their package sources and custom version 1.2. `validation-results.json`, `sandbox-71-comparison.json` and `offline-regression-results.json` are offline reports, not BC imports. **Never import source files:** they contain Microsoft IDs. Microsoft packages and the packaged 7.0 baseline have not been edited.

Scope is non-exempt, non-FOC, tax-exclusive Item invoices for registered and unregistered customers, with intra-state CGST/SGST or inter-state IGST selected by the retained Microsoft state/customer conditions. The Kerala templates retain their own state/cess conditions and configured cess percent, calculated on the same reduced base. International FlightType does not mean export; export/SEZ, inclusive pricing, FOC, exempt sales, credit memos, orders, G/L Account service lines, resources and fixed assets continue through their existing standard cases. Supporting those paths requires their own reviewed templates; this delivery does not broaden the original Item workflow into those cases.

## Local evidence and compatibility limits

Sources inspected from the installed packages:

- India GST `28.5.54976.57206`: seven extracted JSON files in `AIRIQ-GST-Source`, including parent `9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B`. Parent supplies GST Group, HSN/SAC and rate-column lookups. Child posting scripts and TaxPostingSetup, including GST Base Amount component lookup, remain unchanged. Unregistered computation scripts only perform IF/numeric-expression calculations; those preserved variables are bypassed by the new explicit component formulas.
- Tax Engine `28.5.54976.56550`: `TaxJsonDeserialization.Codeunit.al`, procedures ReadComponentCalculation, ReadComponentExprToken and ReadScriptSymbolLookup: component Sequence, Formula.Expression, Tokens/TokenName/TokenValue and Current Record TableName/FieldName are consumed directly. `AppObjectHelper.GetFieldID` resolves FlightType; it does not call attribute registration. The JSON spelling `FiterFieldName` belongs to Microsoft's serializer and is intentionally preserved.
- `ScriptDataTypeMgmt.Codeunit.al`, EvaluateExpression: arithmetic supports the integer divisions used here. The offline evaluator mirrors its operator scan. Integer ratios avoid locale-dependent decimal literals.
- `UseCaseExecution.Codeunit.al`, InternalExecuteUseCaseTree: children are traversed by tree Code, and the first handled matching leaf ends traversal. ParentCaseId supplies inheritance; it does not attach a custom case to the execution tree. PresentationOrder/Indent describe the use-case list, not runtime tree priority. Keep clones as siblings under the original parent, not children of Microsoft calculation leaves.
- India Tax Base `28.5.54976.56550`, codeunit 18543 Calculate Tax: CallTaxEngineOnSalesLine accepts Rec/xRec; HandleSalesUseCase passes the header currency code/factor to normal Tax Engine execution. Standard calculation, currency conversion, rounding and posting remain in charge.

**Confirmed Sandbox comparison:** root `GST.json` was confirmed as the actual export for case `6B464955-261F-4EAF-A749-7807444FC37C`. Compared with the untouched packaged 7.0 source, MinorVersion changes 0 to 1 and PresentationOrder changes 253 to 257. TaxPostingSetup serializes its components, posting actions and fields in a different order. Matching components by ComponentName, actions by Sequence and fields by Sequence proves every posting field, sequence, filter, account lookup and grouping is identical. Conditions, component formulas, scripts, parent and rate inheritance are unchanged. `sandbox-71-comparison.json` records hashes and the exact differences; reproduce with `node Compare-AIRIQ-GST-Export.js`.

**Remaining tenant blockers:** the relevant execution-tree export (branch filters, overlapping cases and effective priority) and active exports for the other five source cases and parent are still absent. Sandbox calculation, import and preview/posting acceptance remain unperformed. The supplied case's 7.1 comparison is resolved; it does not verify other tenant cases.

On 2026-11-01 the installed AL extension `18.1.2842859` compiler confirmed that the machine-wide **.NET 10 x64 runtime was missing**. Microsoft's official installation command is `winget install --id Microsoft.DotNet.Runtime.10 --exact --architecture x64` (see https://learn.microsoft.com/en-us/dotnet/core/install/windows). A temporary .NET runtime `10.0.14` was downloaded using Microsoft's official dotnet-install.ps1 into `.snapshots/airiq-gst-build/dotnet`; no machine-wide runtime or PATH setting was changed.

The amended project compiled successfully on 2026-11-03: **136 AL files, zero errors**, compiler `18.1.43.24897`. The three AL1025 warnings concern the existing `Info.txt` and the temporary runtime's two license/notice text files. Microsoft importer-source AL files remain archived in ZIP and were excluded from compilation. Output is `.snapshots/airiq-gst-build/AIRIQ_1.0.0.3.app`, with log beside it and current hash in `AIRIQ-GST-Custom/compile-results.json`. The pre-existing root .app was not replaced. The 12 custom cases passed 4,940 offline checks including 4,320 numeric scenarios.

The extension artifact is ready for a controlled Sandbox test deployment against matching dependencies. **GST activation/acceptance remains gated** by the remaining source/parent verification, execution-tree review and Sandbox calculation/preview/posting checks described below. No publication, GST JSON import, tenant setting change or Microsoft standard-case modification was performed.

To repeat the local build from the project root:

```powershell
& .\.snapshots\airiq-gst-build\dotnet\dotnet.exe 'C:\Users\P.C\.vscode\extensions\ms-dynamics-smb.al-18.1.2842859\bin\alc.dll' /project:. /packagecachepath:.alpackages /out:.snapshots\airiq-gst-build\AIRIQ_1.0.0.3.app
```

## Reproduce offline validation

Run from the project root. ExecutionPolicy applies only to each child process; no machine policy is changed.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\Extract-AIRIQ-GST-UseCase.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\Build-AIRIQ-GST-Cases.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\Test-AIRIQ-GST-Cases.ps1
```

Extraction selects the exact India GST dependency version from app.json and fails for missing sources. Build preserves custom IDs and assigns version 1.3 to the two registered intra-state cases and 1.2 for the other ten. The shared source resolver selects confirmed root GST.json for the registered intra-state source and packaged files for all other cases. Validation checks the untouched baselines against the pinned package, effective source hashes/versions, schema/identity, preserved conditions/scripts/posting/rate inheritance, direct tokens, formula length, component rates, and 4,320 numeric scenarios including zero, negative and fractional fares, multiple passengers and nonzero Other Charges. See validation-results.json for the current check count. This is source-based validation, not a BC schema-import execution or a ledger-posting test. compile-results.json records the earlier AL build; AL source changed for this amendment.

## Sandbox import and activation (manual)

1. Use an isolated Sandbox company. Confirm installed India GST/Tax Engine/India Tax Base versions against app.json. Export the remaining active source cases, their parent, any existing AIRIQ cases, and the complete relevant **Use Case Tree** (Export Nodes); retain a company/environment restore point. The registered intra-state 7.1 source comparison is complete. Build the AL project locally and deploy the resulting extension to Sandbox yourself if the FlightType recalculation trigger is required. No new diagnostic pages are required by this delivery.
2. Open **Tax Types**, select GST, then **Use Cases**. Use **Import Use Case** to upload the Domestic JSON, then International JSON. Import no other JSON from these folders. Check there are 12 AIRIQ IDs matching case-manifest.json, parent `9B72...`, version 1.3 for the two registered intra-state cases and 1.2 for the other ten, and no changed Microsoft IDs. Leave the AIRIQ cases disabled while arranging the tree. If old versions of the first two IDs exist, export them before accepting their custom upgrade.
3. Open **Use Case Tree**. For each manifest SourceCaseID locate its earliest applicable standard leaf. Add two sibling **Use Case** nodes (Domestic and International), Table **Sales Line (37)**, Tax Type GST, attached by Use Case Name to the respective custom ID. Give them unused **Code** values sorting immediately before that standard leaf, inside the same Begin/End branch and with the same branch filters. Preserve the existing relative order of all Microsoft nodes, including Kerala/special-case precedence. Do not place all clones globally at the beginning of GST. Run **Indent Nodes** and verify the new siblings have the same indentation as their source leaf. Reuse already-existing AIRIQ nodes after verifying their attachments; do not duplicate them.
4. The exact new Code values cannot be prescribed without the exported tenant tree. If there is no unused sorting gap, or an earlier overlapping tenant case catches the invoice, stop and review a concrete tree change from that export. Do not overwrite an existing node, change standard conditions or disable a Microsoft case. Adding JSON alone does not activate priority. Compare the tree before/after and confirm no unrelated branch or Microsoft node was changed.
5. Select only the 12 AIRIQ cases in **Use Cases** and run **Enable Selected Cases** (this releases/enables them). Verify the parent and existing GST setup remain enabled as before. Check one saved invoice line's Tax Transaction Value Case ID: it must be the intended AIRIQ leaf, not its standard source. A tree row's Blocked checkbox is insufficient proof of effective runtime selection in the inspected engine; use case Enable and the executed Case ID for verification.

## Sandbox acceptance (manual)

Use a test Item with normal GST Group/HSN and existing tax rates. Choose customer/location/ship-to setup that satisfies each source case's normal conditions; FlightType alone does not choose state treatment. Test Domestic and International for registered and unregistered customers, each intra/inter, plus the two Kerala templates where applicable. Keep prices tax-exclusive and FOC/exempt off.

For Base Fare 5,000, Pax 2 and Other Charges 500 per passenger, the original invoice Amount is 11,000. With example configured CGST=9%, SGST=9%, IGST=18%:

| FlightType | GST base | Intra CGST | Intra SGST | Inter IGST |
|---|---:|---:|---:|---:|
| Domestic | 500 | 45 | 45 | 90 |
| International | 1,000 | 90 | 90 | 180 |

These rates are examples only. Use the actual configured rates in your Sandbox. Verify the appropriate components are present and the other state's components are absent. Check configured cess independently for a matching Kerala case. Standard precision, currency conversion and ledger sign conventions still apply; compare base magnitudes and rounded component amounts rather than assuming a ledger sign.

- Record Quantity, Unit Price and Amount before each test; confirm they are unchanged after tax calculation. Use the numeric fare field 5,000, Quantity 2, Other Charges 500 and Unit Price 5,500. GST Base must follow fare × Quantity even when Amount changes through discounts. Verify the discount treatment against the intended business policy before activation.
- Change FlightType Domestic → International → blank on a saved line, leave the field to validate, and inspect calculated components/Case ID. With the new AL trigger deployed, tax must recalculate immediately; blank must return to the matching standard case. Without that trigger, create fresh lines with FlightType entered before Quantity/Unit Price; existing-line FlightType refresh is not validated.
- Repeat zero, fractional and negative-line amounts where accepted by the standard document; check rounding. Repeat foreign currency if used, using standard header currency factor. Offline numeric checks do not substitute for currency/posting acceptance.
- Negative controls: blank/other FlightType, orders, FOC, exempt, inclusive-price and non-Item lines must keep their previous standard selection and results. Compare against the same setup with AIRIQ cases disabled.
- Use **Preview Posting** and inspect GST/G/L preview entries for the reduced base and configured rates. If preview is correct, manually post disposable Sandbox invoices and inspect GST Ledger Entry, Detailed GST Ledger Entry, customer/G/L totals and posted invoice line values. This final ledger check requires a human action and has not been performed here. Retain the executed Case IDs and expected/actual figures as acceptance evidence.

## Rollback (manual)

Disable only the 12 AIRIQ IDs using **Disable Selected Cases**; confirm Enable=false. If earlier AIRIQ versions existed, restore their backed-up JSON and prior Enable state instead. Remove only newly added AIRIQ tree nodes (or restore changed AIRIQ attachments from the export); leave all Microsoft nodes and their order intact. Import Nodes is an upsert, so reimporting the old export alone does not remove newly inserted nodes. Recalculate fresh/unposted test lines and confirm the original standard Case IDs/base/rates. Remove the FlightType validation trigger and build/deploy the previous extension yourself if reverting the AL change too.

Disabling/deleting cases cannot reverse posted ledger entries. Use the Sandbox restore point for disposable posted tests or perform the normal reviewed BC reversal/correction process. No tenant setup, import, publication or transaction posting was executed by these scripts.
