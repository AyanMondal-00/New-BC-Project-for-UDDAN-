# AIRIQ Own Sales Posted Invoice Report Mapping Analysis

## Scope and evidence
Analysis is limited to Own Sales and installed project artifacts. The requested PDF was not present among workspace files, so PDF field labels below are taken from the provided invoice design embedded in `AIRIQDummyInvoice.rdl`; verify against the actual PDF before implementation. No tenant or project changes were made other than this analysis file.

### Exact project files / AL IDs

- Report 50390 `AIRIQ Dummy Invoice`: `src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al` (lines 1-83); RDLC `AIRIQDummyInvoice.rdl`.
- Codeunit 50426 `AIRIQ Create Sales Invoice`: `src/Sales Invoice Creation/Own Sales/AIRIQCreateSalesInvoiceCodeUnit.al`.
- Codeunit 50471 `AIRIQ Posted Sales Invoice Mgt`: `src/Sales Invoice Creation/Own Sales/AIRIQPostedSalesInvoiceMgtCodeUnit.al`.
- Header extensions: tableextension 50424 `AIRIQ Sales Header Ext` on Sales Header; 50429 `AIRIQ Posted Sales Header Ext` on Sales Invoice Header.
- Line extensions: tableextension 50425 `AIRIQ Sales Line Ext` on Sales Line; 50430 `AIRIQ Posted Sales Line Ext` on Sales Invoice Line.
- Passenger source table 50404 `Own Sales Passenger Name`: `src/Tables/Sales/Own Sales/OwnSalesPassengerName.Table.al`.
- Installed symbols: `.alpackages/Microsoft_Base Application_28.5.54976.57206.app`, `Microsoft_India GST_28.5.54976.57206.app`, `Microsoft_India Tax Base_28.5.54976.56550.app`, `Microsoft_Tax Engine_28.5.54976.56550.app` (also older Base Application 28.3, Application, System, Business Foundation and India Voucher Interface packages). `.app` files are packaged symbols, not readable AL source in this workspace. Therefore this analysis does not claim unverified India GST field IDs or e-invoice field names.

## Field mapping
“Direct” means stored on the posted invoice records. Header/line standard fields below are standard BC names; custom fields are explicitly identified.

| Invoice field | Posted source / exact field | Availability and notes |
|---|---|---|
| Posted invoice number | Sales Invoice Header (112), `"No."` | Direct; report should be driven by posted header. |
| Invoice date | Sales Invoice Header, `"Posting Date"` (or `"Document Date"` if document date is what the PDF prints) | Direct; choose and label consistently. |
| Reference/AQ number | custom Sales Invoice Header field `"AQ Number"` (50424); populated from Sales Header by codeunit 50471 | Direct for posted records produced with subscriber; created from Normal Sales `"Ref No./AQ Number"`. |
| Place of Supply | Sales Invoice Header standard GST/India field not verified in readable source | Requires symbol inspection/compile-time confirmation. Do not assume a field name. GST ledger source-state fields can also support a lookup if the required display is state name/code. |
| Company name/address/GSTIN | Company Information (79): `Name`, `Address`, `Address 2`, `City`, `Post Code`, `County`, `Country/Region Code`, `VAT Registration No.`; GST Registration Nos. is an India GST table candidate | Company Information direct for general details; authoritative GSTIN may require GST Registration Nos lookup by company/location. Inspect installed symbols to confirm exact India GST key and fields. |
| Bill-to name/address/GSTIN | Sales Invoice Header: `"Bill-to Name"`, `"Bill-to Address"`, `"Bill-to Address 2"`, `"Bill-to City"`, `"Bill-to Post Code"`, `"Bill-to County"`, `"Bill-to Country/Region Code"`, `"VAT Registration No."` | Direct snapshot fields; GSTIN may be this header snapshot, subject to localization behavior. |
| Passenger | Sales Invoice Line (113), custom `"Passenger Name"` (50431) | Direct, copied from Sales Line by subscriber. Passenger-wise mapping loops Own Sales Passenger Name (AQ number + PNR + SL No.) and writes one invoice line per passenger. Fallback uses Normal Sales Passenger and Pax. |
| PNR | Sales Invoice Line `Description` | Codeunit 50426 explicitly assigns `NormalSales.PNR` to Description. |
| Travel date | Sales Invoice Line custom `"Travel Date"` (50424) | Direct; copied by codeunit 50471. Stored DateTime. |
| HSN/SAC | Sales Invoice Line standard `"HSN/SAC Code"` (verify symbol spelling in installed Base/India GST symbols) | Standard item line field expected; derive from posted line snapshot, not a fresh Item lookup. Exact symbol name requires source/symbol confirmation before coding. |
| Quantity | Sales Invoice Line `Quantity` | Direct. Passenger iteration sets 1; fallback quantity is Normal Sales Pax. |
| Rate | Sales Invoice Line `"Unit Price"` | Direct commercial unit price. Existing creator sets unit price = Base Fare + Other Charges. The RDL currently labels rate and amount as inclusive of GST; do not use BaseFare as taxable value. |
| Line amount | Sales Invoice Line `Amount` (excl. invoice discount/VAT; inspect field caption semantics); `"Amount Including VAT"` is another standard amount | Direct; pick the one matching printed inclusive/exclusive semantics. Do not substitute GST Base Amount. |
| Taxable value | GST Ledger Entry posted tax base, filtered to invoice linkage and summed by component | Requires lookup/aggregation. GST Base Amount is tax computation base and may differ from line amount; never infer it from line amount or Base Fare. |
| CGST/SGST/IGST amount and percent | GST Ledger Entry (India GST) component entries linked to posted invoice; exact table fields are not verified from source-readable symbols here | Lookup and aggregate by posted invoice number, document type, component/type, and applicable line/document linkage. Use posted entry amount/base/percent fields. Never calculate tax from Base Fare or invoice line amount. Confirm exact field names and key from installed India GST symbols before AL changes. |
| Invoice total | Sales Invoice Header `"Amount Including VAT"` (standard field; confirm localized GST display) | Direct header total; reconcile to posted customer amount/ledger where required. |
| Amount in words | No identified standard persisted field | Requires number-to-words conversion from final posted total; no matching helper or implementation verified in project. |
| Bank details | Company Information: `"Bank Name"`, `"Bank Account No."`, `"Bank Branch No."` / `"Bank Branch No."` field availability depends symbols; Bank Account table lookup is alternative | Requires confirm exact Company Information fields in installed symbols. IFSC may be unavailable unless stored in India-specific bank/account extension. |
| Website/email | Company Information `"Home Page"`, `"E-Mail"` | Lookup, or company information record. |
| IRN, Ack No/date/status, signed QR | No project custom fields found on posted invoice extensions; installed India GST package exists but unpacked e-invoice symbol/source was not available | Unverified/unavailable in current source inspection. Could be stored by GST/e-document integration in another table or external service; inspect installed symbols and enabled integration before mapping. Do not bind fake RDL literals. |

## GST ledger lookup and aggregation

Use the posted GST ledger as the authoritative source. The local README describes the Tax Engine posting path and explicitly says GST Ledger Entry / Detailed GST Ledger Entry are the final posted evidence (`AIRIQ-GST-README.md`, lines 20 and 79), while the creator removed custom tax assignments and says standard BC Tax Engine handles GST (`AIRIQCreateSalesInvoiceCodeUnit.al`, around lines 206-207).

For each posted invoice: start with Sales Invoice Header `"No."`; find India GST Ledger Entry rows whose posted document number/type corresponds to that invoice (and, where present, document line number/source type/source no. ties to Sales Invoice Line). Partition by component/type CGST, SGST, IGST. Sum posted GST Amount per component across applicable entries; obtain percentage and GST Base Amount from ledger entries. If ledger has multiple rates/lines, do not present one arbitrary percentage: group by component and percentage or show line/component totals. Do not join solely on customer or date. Exact India GST ledger table name/field spellings and document linkage fields must be extracted from installed India GST symbols before implementation; the `.app` package inventory verifies version presence but not those identifiers. Detailed GST Ledger Entry may be the component-detail source; verify relationship from symbols rather than assuming.

The custom `CGST`, `SGST`, `IGST` fields on posted Sales Invoice Line (50428-50430) exist but posting subscriber does not populate them, and creator explicitly no longer maps custom GST. They are not authoritative and should not be used as a fallback.

## RDL binding and hardcoded inventory

`AIRIQDummyInvoice.rdl` contains a `TablixPassengers` with five explicit body rows (RDL lines 1179 onward, rows around 1469-2705), and a `TablixTax` with explicit tax rows (2770 onward). These are fixed rows, not a repeating group bound to invoice records. The report dataset declares `InvoiceRows` as Integer Number 1..3; all AL columns except passenger name are literals, including three-row limitation and sample values (`AIRIQDummyInvoice.Report.al`, lines 12-47, 72-83). RDL dataset fields near lines 4170-4290 describe fields but field declarations alone do not make textboxes dynamic.

Hardcoded content includes: IRN `4a43161a...493db2`, ack `112610000000001`, ack date, status Generated, QR placeholder `QRCodeImage`; invoice 103002, date 08 Sep 2026, West Bengal (19); seller identity/address/GSTIN; customer identity/address/GSTIN; five passenger names, PNR5625X, travel date, SAC 998555, quantities, ₹6,300 rows; CGST/SGST labels/rates/₹101.25; taxable value ₹31,297.50; total ₹31,500; words; narration; bank name/account/IFSC; website/contact and fixed footer/page text. The RDL also has fixed policy/explanatory language (“inclusive of GST”, Rule 32(3)) which should only remain if validated for the posted transaction. Static branding, labels and declaration text are intentionally static; invoice facts must bind to dataset expressions.

## Missing fields / blockers

1. The referenced PDF was not found in workspace; design labels were inspected in RDL only.
2. Exact India GST Ledger Entry and Detailed GST Ledger Entry table/field names and linkage were not verified from decompressed AL symbols. No guess should be implemented.
3. The report AL currently has no request/filter record for Sales Invoice Header and no dynamic table dataitems; it emits three fabricated rows.
4. Passenger and PNR are represented on posted lines, but invoice creation groups passenger records only by AQ Number + PNR and creates one line for each result; confirm intended invoice grouping and line layout.
5. HSN/SAC, Place of Supply, company GST registration, bank/IFSC and e-invoice values require symbol/application storage confirmation.
6. Amount in words has no verified implementation.
7. Existing posted invoice historical records may not contain custom passenger fields if posted before codeunit 50471 was active.

## Recommended minimal changes

1. Replace Integer dataitem with Sales Invoice Header (112), filtered to Own Sales (`"Sales Type"` custom field = Own Sales), and expose posted header snapshots. Add a Sales Invoice Line (113) child dataitem linked by `Document No.` = header `"No."`; use posted line custom passenger/travel fields and standard description, quantity, unit price/amount and HSN/SAC after symbol verification.
2. Add GST ledger lookup procedure(s) using verified installed India GST symbols. Filter by posted invoice linkage, aggregate actual posted CGST/SGST/IGST amount/base/percent; do not calculate from line amount/Base Fare and do not use the unpopulated custom tax fields.
3. Fetch Company Information and GST registration/bank detail records only for fields actually printed and confirmed available. Use posted header bill-to snapshots for customer data.
4. Change RDL passenger and tax tablixes to dataset-bound repeating members and replace invoice fact literals with `Fields!…Value` expressions. Use conditional visibility for absent e-invoice data; remove sample IRN/ack/QR. Keep static labels/branding only. Handle variable passenger count and variable tax components.
5. Provide report request filters on posted invoice (at least No., Posting Date, Sell-to/ Bill-to customer), preserve Own Sales restriction, and keep report read-only. Do not change invoice creation/posting/tax mappings.

## Source line references

- Report literals and integer dataset: `src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al` lines 1-47; passenger switch lines 72-83.
- Invoice creation/customer and item matching, AQ/passenger filtering, header Sales Type, passenger lines/fallback, unit price, PNR, date/name: `src/Sales Invoice Creation/Own Sales/AIRIQCreateSalesInvoiceCodeUnit.al` lines 8-136, 144-213.
- Posted custom field transfer: `src/Sales Invoice Creation/Own Sales/AIRIQPostedSalesInvoiceMgtCodeUnit.al` lines 1-67.
- Sales Header extension: `src/Sales Invoice Creation/Own Sales/AIRIQSalesInvoiceHeaderTableExt.al` lines 1-25.
- Sales Line extension: `src/Sales Invoice Creation/Own Sales/AIRIQSalesInvoiceLineTableExt.al` lines 1-78.
- Posted header extension: `src/Base Table Extended/Posted Invoice Form/AIRIQPostedSalesInvoiceHeaderExt.al` lines 1-25.
- Posted line extension: `src/Base Table Extended/Posted Invoice Form/AIRIQPostedSalesInvoiceLineExt.al` lines 1-71.
- Passenger table/key: `src/Tables/Sales/Own Sales/OwnSalesPassengerName.Table.al` lines 1-79.
- RDL hardcoded e-invoice values: `AIRIQDummyInvoice.rdl` lines 156-479; invoice metadata lines 514-764; seller/customer block around 817-1123; passenger tablix lines 1179-2705; tax tablix lines 2770-3099; totals/bank/contact around 3153-3884; field declarations at end (around 4170-4290).
- Tax source notes: `AIRIQ-GST-README.md` lines 20, 24, 79.
