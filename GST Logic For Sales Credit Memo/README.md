# Sales Credit Memo GST ? ISOLATED DRAFTS, NOT IMPORT READY

No existing project file is changed. Do not import these drafts, release/enable cases, publish, or post without approval and resolution of blockers.

## Formulas
Domestic base = Sales Line."AIRIQ GST Base Fare" * Quantity / 20.
International base = Sales Line."AIRIQ GST Base Fare" * Quantity / 10.
CGST/SGST/IGST/KFloodCess = base * the respective Component Percent / 100. No rate is hardcoded.

## Sources
Project root app.json; AIRIQ-GST-Custom/AIRIQ-GST-Domestic.json, AIRIQ-GST-International.json, case-manifest.json; Sales Credit Memo Invoice/AIRIQSalesReturnCreditMemoCU.al (codeunit 50715, AddLine lines 142?181); src/Sales Invoice Creation/Own Sales/AIRIQSalesInvoiceLineTableExt.al (tableextension 50425).
Microsoft package .alpackages/Microsoft_India GST_28.5.54976.57206.app resources/GSTUseCases: standard source GUID filenames are recorded in case-manifest.json.
India Tax Base package Microsoft_India Tax Base_28.5.54976.56550.app: src/src/codeunit/CalculateTax.Codeunit.al, codeunit 18543, CallTaxEngineOnSalesLine lines 44?58; HandleSalesUseCase lines 132?144.
Tax Engine package Microsoft_Tax Engine_28.5.54976.56550.app: src/TaxEngine-UseCaseBuilder/src/UseCase/codeunit/UseCaseExecution.Codeunit.al, codeunit 20293, parent execution lines 50?64, tree traversal 124?179, conditions 265?276. TaxUseCase.Table.al table 20306 Enable validation lines 34?46 requires Released.
India GST GSTSalesValidation.Codeunit.al codeunit 18143 CreateReferenceInvoiceNo lines 1984?1998 establishes standard references; the custom AIRIQ Original Invoice text alone is not that relationship.

## Cases and differences
Each FlightType has Registered Intrastate, Registered Interstate, Unregistered Intrastate, Unregistered Interstate, Kerala Registered Intrastate and Kerala Unregistered Intrastate. The complete 12-ID manifest follows below.
Cases use Credit Memo only, not Invoice or Return Order. FlightType, positive numeric fare, and nonblank Sales Header AIRIQ Return No. restrict matching to the intended workflow. This marker is not a security boundary: manually tagged records can match. The ordinary intra-state unregistered branch now excludes Kerala, matching the ordinary registered branch. All new branches require non-FOC and tax-exclusive conditions inherited from Invoice templates. Existing Invoice conditions are untouched.
Standard return attributes, rate columns, scripts, posting filters, posting setup and parent relationship are retained. Invoice components supply only the custom formulas/tokens. The unregistered standard computation scripts remain present; sandbox testing must confirm they introduce no conflicting component effects.

## Posting and blockers
Standard return sources debit GST payable accounts. Keep their original document type mappings, ReverseSign flags, ledger insertion actions and scripts. Do not negate fare/quantity to force reversal. Validate actual G/L, GST Ledger and Detailed GST Ledger signs in preview and sandbox posting.
Kerala drafts are INCOMPLETE: no matching standard goods-return cess posting configuration was established. They contain KFloodCess calculation from the Invoice design but no invented cess posting mapping. Validation reports the missing mapping. A tax specialist must confirm whether cess applies to the credit date/original invoice and establish the correct return posting resource before these cases are usable.
Source Base Fare per-passenger semantics, standard invoice references, source validation, currency, rate dates and partial-refund allocation need confirmation. A credit calculated at current rates may not reverse the original invoice accurately.

## Tree and activation
All drafts retain parent 9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B. They must be sibling leaves, not children of Invoice leaves. Parent execution supplies shared symbols. Verify parent exists/enabled and compatible with the installed tenant version.
The execution engine follows tree Code/indentation/ranges and stops at a handled branch; PresentationOrder alone does not establish priority. Custom nodes must be reachable through all ancestor filters and precede overlapping standard return branches. No tree import draft is supplied because the active tenant tree is unavailable. Export and review it before deciding exact insertion codes, indentation and End nodes.
Each case can be enabled separately after release; tax type and parent prerequisites still apply. Import defaults, tenant GUID uniqueness and active-tree precedence are NOT confirmed. These files have no added invented Enable/Status JSON properties. Do not treat import as activation or assume imports create the right tree.
Local new Case IDs were checked against workspace JSON and packaged India GST JSON GUIDs. Other installed extensions and tenant-only configuration remain outside that guarantee.

## Tests and rollback
For both FlightTypes run all six scenarios with quantity 1, aggregate PAX >1 and separate passenger lines. Check correct selected GUID, base, rate lookup, component totals and rounding. Verify interstate only IGST and intrastate CGST/SGST. Exercise Kerala overlap, unknown FlightType, ordinary non-AIRIQ, zero fare, FOC, exempt, inclusive-tax, Export/SEZ and missing marker exclusions. Regress all 12 existing Invoice cases.
Test full/partial credits against original invoice rates and references, repeated credits, currency and rate-date changes, recalculation after edits, preview and eventual approved sandbox posting. Reconcile customer balance, payable debit, GST base, components and detailed ledger reference/signs.
Before an approved import export tenant configuration/tree and record enabled flags. Roll back by disabling only new cases, restoring approved tree placement and recalculating drafts. Posted entries require standard corrective documents, not deletion. No rollback action is needed now: nothing was imported or published.

## Case ID manifest
- Domestic scenario 1: `{8C726039-861D-4A4D-9DAE-4AD8D4F5F565}`; standard source `{26581492-A8D9-41EB-B84E-40671AE8CC3C}`.
- Domestic scenario 2: `{952B1DED-477B-4F63-9460-C2157194B71D}`; standard source `{2167C0D3-971D-481A-86BA-F45FB92025FB}`.
- Domestic scenario 3: `{D066C5EA-32A0-4549-BB73-5FE9FB7927DE}`; standard source `{08F3F188-43F5-441F-AB95-BE332651AD3D}`.
- Domestic scenario 4: `{EA1B96D1-9501-4D94-85AF-F21F030F4072}`; standard source `{77DC6AF2-5D31-4450-8F78-E2F7383B9EAB}`.
- Domestic scenario 5: `{D93F3BED-9F35-42B0-B328-C9151A1B52DB}`; standard source `{26581492-A8D9-41EB-B84E-40671AE8CC3C}`.
- Domestic scenario 6: `{F8539BCB-7DE0-4680-8833-2DA0798ECB85}`; standard source `{08F3F188-43F5-441F-AB95-BE332651AD3D}`.
- International scenario 1: `{253D80CE-50AF-4E45-A3B4-15BE6899FCB9}`; standard source `{26581492-A8D9-41EB-B84E-40671AE8CC3C}`.
- International scenario 2: `{5FCD4C7F-4D4D-4AFA-8AE3-04813BA636D1}`; standard source `{2167C0D3-971D-481A-86BA-F45FB92025FB}`.
- International scenario 3: `{5EA15565-6963-4BAE-BF5B-AD87F37F90A2}`; standard source `{08F3F188-43F5-441F-AB95-BE332651AD3D}`.
- International scenario 4: `{F88C7163-4D06-49AB-9CF6-15B6A12EF29B}`; standard source `{77DC6AF2-5D31-4450-8F78-E2F7383B9EAB}`.
- International scenario 5: `{16B92FDA-248F-41A0-87F4-BB32B508637A}`; standard source `{26581492-A8D9-41EB-B84E-40671AE8CC3C}`.
- International scenario 6: `{40247520-EB3D-4F60-B8FE-890F5FF5091B}`; standard source `{08F3F188-43F5-441F-AB95-BE332651AD3D}`.
