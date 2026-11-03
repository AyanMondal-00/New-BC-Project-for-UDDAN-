# AIRIQ Report 50390 Final Validation

Validation date: 2026-11-01

## Existing implementation status

Continued the existing Report 50390 implementation. It reads posted Sales Invoice Header (112), Sales Invoice Line (113), and Detailed GST Ledger Entry (18001), filters Own Sales at the header, and retains the single-invoice run requirement. Passenger and GST tablixes are already grouped for repeating detail rows. No report code changes were required during this validation.

## Files modified

- `AIRIQ_Report_50390_Final_Validation.md` (this report).
- No AL or RDL files were modified during this validation. Earlier implementation state is preserved.

## AL compilation

- Compiler: `C:\Users\P.C\.vscode\extensions\ms-dynamics-smb.al-18.1.2842859\bin\alc.exe`
- Version: AL Compiler 18.1.43.24897.
- Project: `AIRIQ`, 123 AL files.
- Command used:

  ```powershell
  & 'C:\Users\P.C\.vscode\extensions\ms-dynamics-smb.al-18.1.2842859\bin\alc.exe' /project:. /packagecachepath:.alpackages /out:C:\Users\P.C\Desktop\backUp\New-BC-Project-for-UDDAN-\AIRIQ_validation.app /errorlog:C:\Users\P.C\Desktop\backUp\New-BC-Project-for-UDDAN-\AIRIQ_compile_errors.json
  ```

- Result: compilation completed successfully; no AL errors or Report 50390 diagnostics.
- Warnings: three AL1025 warnings because `Info.txt`, `.snapshots\airiq-gst-build\dotnet\LICENSE.txt`, and `.snapshots\airiq-gst-build\dotnet\ThirdPartyNotices.txt` do not match AL object definitions. They are unrelated to Report 50390.
- The initial compiler invocation without `/packagecachepath:.alpackages` failed with AL1021 and cascading unresolved standard symbols. The retry with the existing package cache completed successfully.
- `dotnet --list-runtimes` could not run in this session: PowerShell reports `dotnet` is not recognized. Therefore this environment does not expose the .NET runtime through PATH. This did not block AL compilation. To verify runtime outside this shell, run `dotnet --list-runtimes` in a shell where the .NET 10 installation directory is on PATH (normally `C:\Program Files\dotnet\dotnet.exe --list-runtimes`).

## RDL and dataset validation

- `AIRIQDummyInvoice.rdl` parsed successfully as XML using PowerShell's XML parser.
- Dataset `DataSet_Result` declares 44 fields.
- All 34 distinct `Fields!…Value` references found in the RDL resolve to declared dataset fields; unresolved references: none.
- Passenger tablix `TablixPassengers` contains two row definitions (header and detail) and a repeating `PassengerGroup` group.
- GST tablix `TablixTax` contains two row definitions (header and detail) and a repeating `TaxGroup` group.
- Dataset checks show the passenger detail uses passenger name, PNR, travel date, SAC, quantity, rate, amount, and row number fields. The GST detail uses posted component, rate, and amount fields.
- XML/layout structure was inspected. Actual RDLC rendering, pagination, and footer overlap cannot be verified without a renderer or Business Central preview.

## Hardcoded sample data check

No invoice-specific sample values (103008, ABC Travels, Ayan Mondal, Mili Mani, MIG1J4, or fixed rupee fare/total values) were found in the RDL. Dynamic posted data expressions remain. Static branding, captions, and standard legal footer wording remain by design. E-invoice status is not populated with a fabricated Generated value.

## Remaining blockers and runtime validation

- **GST reversals:** report filters Initial Entry and signed-negates sales credit amounts, preserving negative signs. Actual reversal artifacts and correction behavior have not been verified against tenant ledger data; net-of-reversal treatment remains unresolved. Do not claim reconciled tax until validated against posted entries.
- **Tax presentation:** posted header `Amount` and `Amount Including VAT` FlowFields are used after `CalcFields`; the invoice does not automatically add ledger GST to the posted total. Runtime verification is still needed to confirm tax-inclusive/exclusive labels and the printed amount against invoice 103008 values and customer-ledger posting.
- **IFSC:** no verified IFSC field was established; no value is invented. IFSC display remains unavailable.
- **Amount in words:** no verified helper was found; the field remains blank.
- **PDF reference/rendering:** requested sample PDF was not found in the workspace. Existing visual design is preserved, but no PDF/RDLC renderer or Business Central preview was run. Variable-row pagination and footer overlap, QR rendering, and exact PDF label match remain to be checked in Sandbox.
- **GST labels:** component codes and posted rates are shown; configured tenant component-to-CGST/SGST/IGST mapping was not available for validation.
- **E-invoice fields:** standard posted IRN, acknowledgement, and QR fields are bound and can remain empty. Runtime population and QR image rendering are unverified.

## Sandbox readiness

The AL extension compiles successfully and static RDL checks pass. Report 50390 is ready for controlled Sandbox preview, with the runtime checks above still required before production acceptance. No extension was published or installed, and no Business Central tenant data was accessed or changed.

## QR rendering fix — 2026-11-01

Sandbox reported missing MIMEType for ImgQRCode. The only RDL Image element used Database source with QRImage but no MIMEType. QRImage remains mapped in AL to the posted Sales Invoice Header QR Code Blob after CalcFields. Bitmap subtype does not prove PNG encoding; available India GST eInvoiceManagement source did not establish encoding and actual posted bytes were unavailable.

Changed only AIRIQDummyInvoice.rdl implementation: ImgQRCode is temporarily Hidden=true with Value =Nothing and MIMEType image/png. The MIME type is structural metadata for the disabled image, not a claim that posted QR bytes are PNG. Null value prevents decoding unknown or empty data even if hidden expressions are evaluated. No embedded sample QR is used. Position, size, styling, and AL dataset mapping are preserved. Restoring QR display requires verifying actual posted byte signatures and selecting a matching MIME type, with an empty-data guard.

Post-fix XML parse passed; all Fields references resolve. Only one Image element exists and it now has MIMEType. AL Compiler 18.1.43.24897 compiled all 123 files successfully with /packagecachepath:.alpackages /generatereportlayout-; three existing AL1025 warnings remain. Full output: AIRIQ_QR_compile.log. No AL files changed. AIRIQ_validation.app was rebuilt locally. Sandbox/PDF rendering has not been rerun; QR is intentionally omitted pending encoding verification. No publishing or tenant changes.

## Tablix duplicate binding fix — 2026-11-01

Removed exactly two duplicate direct-child DataSetName elements: the second DataSetName (after Style, before Filters) in TablixPassengers, and the equivalent second element in TablixTax. Each now retains exactly one DataSetName = DataSet_Result, located after TablixRowHierarchy. No rows, columns, row/column hierarchies, filters, expressions, fonts, colors, positions, or groups were changed. PassengerGroup and TaxGroup remain dynamic groups without fixed group expressions. Each tablix retains its header and detail row. Only AIRIQDummyInvoice.rdl implementation changed; no AL source changed.

XML parsing passed. Duplicate direct-child DataSetName count is zero. A broader repeated-child scan, allowing known collection containers, found no other repeated singleton candidates. This structural scan is not a substitute for XSD validation and cannot certify all schema ordering. Both original hierarchies and their ordering were preserved.

There are 33 distinct active Fields references, all resolving to the declared dataset. The earlier count of 34 predates the QR fallback: QRImage is still declared and mapped in AL but is no longer actively referenced because ImgQRCode uses =Nothing. ImgQRCode remains hidden, with image/png MIMEType present; no unverified QR bytes are supplied.

Actual AL compilation passed for all 123 files with AL Compiler 18.1.43.24897, /packagecachepath:.alpackages and /generatereportlayout-. No errors; the same three unrelated AL1025 warnings remain. Full compiler output is saved in AIRIQ_Tablix_compile.log. Local validation package AIRIQ_validation.app was rebuilt.

Full RDLC/RDL schema validation is unavailable: no compatible local ReportDefinition XSD or Reporting validator was located in the inspected compiler/installed locations. Attempting to obtain the RDL 2016 schema from https://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition/ReportDefinition.xsd returned an unavailable-resource response. Therefore schema ordering and Business Central renderer acceptance are not claimed. Sandbox PDF preview must be repeated to confirm acceptance and pagination. Existing GST reversal, tax presentation, IFSC, amount-in-words and QR encoding blockers remain as previously documented. No publish, install, or tenant operation was performed.

## Body page-number expression fix — 2026-11-01

FooterRight is a direct report Body report item, not an actual PageFooter. Replaced its expression with =First(Fields!Website.Value, "DataSet_Result"), removing only the appended separator, Page label and Globals!PageNumber reference. Used the permitted temporary removal option: introducing a PageFooter would reserve page space and require adjusting the existing body/footer arrangement. Website content, bottom-right alignment, location, dimensions and styling are preserved. Page numbering is temporarily absent.

XML validation passed. Entire RDL contains zero Globals!PageNumber/Globals!TotalPages references. All 33 active dataset field references resolve. No other Globals, ReportItems, Code, Lookup or RunningValue expressions were found by the targeted scan; this is not a complete renderer expression validation. PassengerGroup and TaxGroup are preserved and both tablixes retain one DataSet_Result binding each. ImgQRCode remains hidden, =Nothing, MIMEType image/png. No dataset or AL source changes.

AL Compiler 18.1.43.24897 compiled all 123 files successfully with the existing .alpackages cache and /generatereportlayout-. No errors and the same three unrelated AL1025 warnings. Output saved to AIRIQ_Footer_compile.log; local AIRIQ_validation.app rebuilt. Full compatible RDL schema/renderer validation remains unavailable as documented above; no successful Sandbox PDF rendering is claimed. Sandbox preview remains necessary to assess pagination and any further renderer diagnostics. No publishing or tenant changes.
