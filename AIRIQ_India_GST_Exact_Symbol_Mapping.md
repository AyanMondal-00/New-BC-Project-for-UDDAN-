# AIRIQ India GST Exact Symbol Mapping

## Scope and package evidence
Read-only inspection of installed archive contents. `.app` files were enumerated with `unzip -Z1` and relevant AL source entries extracted with `unzip -p` into `%TEMP%\airiq-symbol-inspect`; no package, AL, RDL, or tenant files were changed. In these packages, relevant entries are readable AL source, not merely opaque symbol metadata. Package versions below are taken from exact filenames in `.alpackages`.

| Package | Version | Relevant evidence |
|---|---|---|
| Microsoft India GST | 28.5.54976.57206 | `src/GSTBase/src/table/GSTLedgerEntry.table.al`, `DetailedGSTLedgerEntry.table.al`, `GSTRegistrationNos.table.al`; GSTSales invoice extensions and e-invoice management. |
| Microsoft India Tax Base | 28.5.54976.56550 | `src/src/table/State.table.al`. |
| Microsoft Base Application | 28.5.54976.57206 | `src/Sales/History/SalesInvoiceHeader.Table.al`, `SalesInvoiceLine.Table.al`, `src/Foundation/Company/CompanyInformation.Table.al`, `src/Bank/BankAccount/BankAccount.Table.al`. |
| Microsoft Tax Engine | 28.5.54976.56550 | Installed; no required GST ledger source table was found here; GST ledger tables are India GST package. |

Project context: report 50390 is currently an Integer/sample dataset; Own Sales posted header custom `Sales Type` = `Own Sales` is tableextension 50429, and line custom passenger/travel fields are tableextension 50430. Codeunit 50471 transfers these custom header/line values at posting. See `AIRIQ_OwnSales_Report_Mapping_Analysis.md`.

## Exact GST tables and linkage

### GST Ledger Entry — table 18005 (India GST)

Evidence: `GSTLedgerEntry.table.al`, declaration `table 18005 "GST Ledger Entry"`; fields:

| Field | AL type | Meaning / use |
|---|---|---|
| `"Entry No."` (1) | Integer | PK, auto increment. |
| `"Posting Date"` (4) | Date | Posting date. |
| `"Document No."` (5) | Code[20] | Posted document number. |
| `"Document Type"` (7) | Enum `Detail GST Document Type` (enum 18012) | Invoice value is `Invoice` (2). |
| `"Transaction Type"` (8) | Enum `GST Ledger Transaction Type` (enum 18029) | Sales = 1. |
| `"GST Base Amount"` (9) | Decimal | GST base; not invoice line Amount. |
| `"Source Type"` (10) | Enum `GST Ledger Source Type` (enum 18028) | Customer = 0 among values. |
| `"Source No."` (11) | Code[20] | Customer source number. |
| `"Transaction No."` (18) | Integer | Transaction identity. |
| `"GST Component Code"` (20) | Code[30] | Component key; codes are configuration data, not a built-in CGST/SGST/IGST enum. |
| `"GST Amount"` (27) | Decimal | Posted GST amount. |

Key3: (`Transaction Type`, `Transaction No.`, `Source No.`, `Entry Type`, `Document Type`, `Document No.`, `GST Component Code`). GST Ledger Entry has no `GST %` field and no `Document Line No.` in this package definition. Hence it supports document/component amounts and base, but not the rate or strongest per-line relation by itself.

### Detailed GST Ledger Entry — table 18001 (India GST)

Evidence: `DetailedGSTLedgerEntry.table.al`, declaration `table 18001 "Detailed GST Ledger Entry"`.

| Field | AL type | Use |
|---|---|---|
| `"Entry No."` (1) | Integer | PK. |
| `"Entry Type"` (2) | Enum `Detail Ledger Entry Type` (enum 18013): Initial Entry=0, Application=1, Adjustment Entry=2. |
| `"Transaction Type"` (3) | Enum `Detail Ledger Transaction Type` (enum 18014): Purchase=0, Sales=1, Transfer=2, Settlement=3. |
| `"Document Type"` (4) | Enum `GST Document Type` | Invoice enum member must be confirmed in `GSTDocumentType.Enum.al`; do not substitute enum 18012 without checking—the source field uses a distinct enum. |
| `"Document No."` (5) | Code[20] | Posted document no. |
| `"Posting Date"` (6) | Date | Posted date. |
| `"Source Type"` (10) | Enum `Source Type` | Standard source type; Customer member. |
| `"Source No."` (11) | Code[20] | Customer no. |
| `"HSN/SAC Code"` (12) | Code[10] | GST classification snapshot. |
| `"GST Component Code"` (13) | Code[30] | Component key. |
| `"GST Jurisdiction Type"` (15) | Enum `GST Jurisdiction Type` | GST jurisdiction classification. |
| `"GST Base Amount"` (16) | Decimal | Posted tax base. |
| `"GST %"` (17) | Decimal | Posted rate. |
| `"GST Amount"` (18) | Decimal | Posted tax amount. |
| `"Document Line No."` (26) | Integer | Posted line number. |
| `"Transaction No."` (37) | Integer | Transaction identity. |
| `"Location  Reg. No."` (32) | Code[20] | GST registration code (note two spaces in field name). |
| `"Buyer/Seller Reg. No."` (33) | Code[20] | Counterparty GST registration number. |
| `"GST Place of Supply"` (58) | Enum `GST Dependency Type` (enum 18051) | Describes basis: Bill-to Address, Ship-to Address, Location Address; this is not a state code/name. |

Key14 is (`Transaction Type`, `Document Type`, `Document No.`, `Document Line No.`, `GST Component Code`) with SumIndexFields `GST Amount`. This is the strongest table-native line/component lookup key. Other relevant key6 is Transaction Type, Document Type, Document No., Document Line No.; key5 is Document No., Document Line No., GST Component Code.

### Safe lookup/aggregation logic

For the Own Sales posted header `Sales Invoice Header` 112, use its `"No."`, and its posted customer number (`"Bill-to Customer No."` or source filter as appropriate). For line-level GST use Detailed GST Ledger Entry:

1. Filter `"Transaction Type"` = Sales (enum 18014 value 1).
2. Filter `"Document Type"` = the Sales Invoice value from enum `GST Document Type` (confirm exact member in extracted enum; source is distinct from enum 18012).
3. Filter `"Document No."` = header `"No."`.
4. Join each Sales Invoice Line (113) by both `"Document No."` and `"Line No."` = `"Document Line No."`.
5. Filter/validate `"Source Type"` = Customer and `"Source No."` = posted invoice bill-to/sell-to source matching the actual GST posting semantics. Confirm in a posted test record which customer identity the localization writes; document/type/no/line are the primary link, source filters are defensive validation.
6. Group/sum by line, `"GST Component Code"`, and `"GST %"` (and retain `"GST Base Amount"` per group). Multiple component rows or rates can exist; preserve separate groups or explicitly sum amounts only when same component/rate/base presentation is intended.

For document-level summary use Detailed GST Ledger Entry grouped by component and rate, filtered as above, summing posted `"GST Amount"` and `"GST Base Amount"`. Avoid summing both detailed and parent GST Ledger Entry rows together: these are distinct ledgers, not additive sources. GST Ledger Entry (18005) supports document/component aggregate, but has no line no/rate. Its `"Transaction No."` is a useful cross-ledger correlation where populated, but do not use it alone as invoice identity. Do not filter solely by document number: include sales transaction type and invoice document type, and use detailed line no for line joins.

The package defines component codes as Code[30], not enum. There is no universal enum member `CGST`/`SGST`/`IGST` in these table definitions. Codes resolve through configured GST components/use-case mappings. Map configured component codes to displayed CGST/SGST/IGST only after confirming actual company configuration and the installed GST component setup relationship. Do not hardcode assumed values or derive percentages.

## Invoice, GST registration, state, and amount sources

| Requested output | Exact source and type | Findings |
|---|---|---|
| Posted number/date | Base Application table 112 Sales Invoice Header: `"No."` Code[20], `"Posting Date"` Date; also `"Document Date"` exists in header source | Direct. |
| Posted line identity | Base Application table 113 Sales Invoice Line: `"Document No."` Code[20], `"Line No."` Integer | Direct join key to Detailed GST Ledger Entry’s Document No./Document Line No. |
| Line amount excl/incl tax | Table 113 `Amount` Decimal and `"Amount Including VAT"` Decimal | Direct. Header 112 `Amount` (field 60) and `"Amount Including VAT"` (61) are FlowFields summing line values by Document No. Header total inclusive/exclusive are available directly after CalcFields. India GST package also adds posted line `"Price Exclusive of Tax"` Boolean (18152), `"Unit Price Incl. of Tax"` Decimal (18155), `"GST Assessable Value (LCY)"` Decimal (18150). These are not interchangeable with GST Ledger Entry `"GST Base Amount"`. |
| Place of Supply | India GST Sales Invoice Line extension 18149 field 18141 `"GST Place of Supply"` Enum `GST Dependency Type`; header extension 18148 has `"GST Bill-to State Code"` Code[10] field 18150, `"GST Ship-to State Code"` 18151, `"Location State Code"` 18152, `State` Code[10] field 18166 | Line field is a dependency basis enum, not a state. For displayed state, select the appropriate persisted header state code according to the actual transaction. Table 18547 State: `Code` Code[10], `Description` Text[50], `"State Code for eTDS/TCS"` Code[2]. Lookup State.Code to Description for state name. Detailed GST ledger also stores the dependency basis enum only. |
| Seller GST registration | India GST Sales Invoice Header extension 18148 field 18154 `"Location GST Reg. No."` Code[20] → Table 18008 `GST Registration Nos.` field `Code` Code[20], field `State Code` Code[10], `Description` Text[50]. Header also stores `"GST Bill-to State Code"` etc. | Prefer posted snapshot `"Location GST Reg. No."`; resolve to registration description/state as needed. This field is a registration code, not necessarily the displayed GSTIN string; verify configured registration record/related location data before printing. |
| Customer GST registration | Header extension 18148 field 18155 `"Customer GST Reg. No."` Code[20]; `"Ship-to GST Reg. No."` (18156) Code[20] | Direct posted snapshot. No separate table relation on 18155 in its field declaration. Use bill-to registration for bill-to display; do not substitute the entry's Buyer/Seller registration without checking posting direction. |
| HSN/SAC | India GST posted line extension 18149 field 18144 `"HSN/SAC Code"` Code[10] | Direct posted line snapshot. GST Detailed Entry also stores `"HSN/SAC Code"` Code[10] field 12. |
| GST percent/amount/base | Detailed GST Ledger Entry 18001 fields 17/18/16, all Decimal | Authoritative posted source; aggregate by component+rate as above. GST Ledger Entry 18005 amount/base fields 27/9 but no rate or line. |

## E-invoice exact fields

India GST package `GSTSalesInvoiceHeaderExt.TableExt.al`, tableextension 18148 on Sales Invoice Header (112):

| Field ID/name | Type | Use / limitation |
|---|---|---|
| 18171 `"Acknowledgement No."` | Text[30] | Direct posted header. |
| 18172 `"IRN Hash"` | Text[64] | IRN value; direct posted header. |
| 18173 `"QR Code"` | Blob, Subtype Bitmap | QR image. The symbol calls it QR Code; it does not establish that the payload is signed QR content. |
| 18174 `"Acknowledgement Date"` | DateTime | Direct posted header. |
| 18176 `"E-Inv. Cancelled Date"` | DateTime | Cancellation metadata only. |
| 18177 `"Cancel Reason"` | Enum `e-Invoice Cancel Reason` (enum 18054; inspect members if needed) | Cancellation reason, not status. |

No `Status` field was found in this posted header extension. `eInvoiceManagement.Codeunit.al` validates IRN length and references IRN Hash, but no persistent status field was identified. Thus “Generated” status in existing RDL is not evidence-backed. Check current posting/e-invoice integration behavior to determine whether acknowledgement/IRN/QR are populated; field existence does not guarantee values. Signed QR Code specifically is unresolved: symbol field is named `QR Code`, Bitmap Blob.

## Bank, website/email, words

- Base Application `Company Information` table 79: `"Bank Name"` Text[100] (12), `"Bank Branch No."` Text[20] (13), `"Bank Account No."` Text[30] (14), `"Payment Routing No."` Text[20] (15), `"VAT Registration No."` Text[20] (19), `"E-Mail"` Text[80] (34), `"Home Page"` Text[255] (35). Company setup lookup, not posted snapshot. Standard VAT Registration No. is not necessarily the India GST registration to print; prefer India GST registration details.
- Base Application `Bank Account` table 270 includes `"No."` Code[20], Name Text[100], `"Bank Account No."` Text[30], `"Transit No."` Text[20], and related standard bank fields. No IFSC field was found in the Base Application Bank Account table source inspected. `"Transit No."` is not proven equivalent to IFSC. IFSC needs a separate India-specific extension/table if configured; unresolved in the inspected package set.
- Search across installed `.alpackages` source entries found no standard amount-in-words routine identified for this invoice report. Treat amount in words as not available from the verified symbols; use a separately verified implementation if required.

## Project-specific implications

- Header tableextension 50429 stores Own Sales discriminator `"Sales Type"`; filter to enum-like Option member `Own Sales` (project OptionMembers: Own Sales, API Sales, Third Party Sales).
- Header custom AQ number is 50424; passenger/travel data on posted Sales Invoice Line comes from AIRIQ extension 50430 (not standard symbols). PNR is posted line Description per codeunit 50426.
- Codeunit 50471 copies passenger and travel date to posted line; it does not populate custom posted `CGST`/`SGST`/`IGST` fields. Do not use those custom values. Standard posted GST records above are source of truth.
- Existing report 50390 uses literals/fixed RDL tablix rows. Convert the data pipeline and RDL to repeating header/line/tax groups; ensure tax lines remain separate for multiple component/rate combinations.

## Remaining blockers / unverified items

1. Component code configuration mapping to CGST/SGST/IGST is tenant/configuration data and has no universal enum in the ledger table. Inspect actual GST component/use-case mapping before labeling.
2. Verify `GST Document Type` enum’s exact Invoice member in the installed source and confirm which GST source/customer no. is written for posted Own Sales records. Do not use document number alone.
3. Confirm India GST `"Location GST Reg. No."` and `"Customer GST Reg. No."` values are the formatted GSTIN string in this deployment or are codes requiring lookup; table 18008 itself only has Code, State Code, Description, ISD flag.
4. “Status” and signed QR payload are not represented by the fields identified; QR Code is a Bitmap Blob. Runtime integration may have additional service/external storage not represented in inspected packages.
5. IFSC was not found in Base Application bank/company fields or inspected India GST symbols; verify any additional local India extension.
6. Amount-in-words helper was not identified in inspected packages.
7. Referenced invoice PDF was not available in the workspace for field-by-field validation.

## Extracted source locations

All paths below are archive-internal paths in exact packages listed above:

- India GST `src/GSTBase/src/table/GSTLedgerEntry.table.al`: table 18005, fields, key3.
- India GST `src/GSTBase/src/table/DetailedGSTLedgerEntry.table.al`: table 18001, fields 1-94, keys 5/6/14 and sum index fields.
- India GST `src/GSTBase/src/Enum/DetailGSTDocumentType.Enum.al`: enum 18012 (GST Ledger Entry document type).
- India GST `src/GSTBase/src/Enum/DetailLedgerEntryType.Enum.al`: enum 18013.
- India GST `src/GSTBase/src/Enum/DetailLedgerTransactionType.Enum.al`: enum 18014.
- India GST `src/GSTBase/src/Enum/GSTLedgerSourceType.Enum.al`: enum 18028.
- India GST `src/GSTBase/src/Enum/GSTLedgerTransactionType.Enum.al`: enum 18029.
- India GST `src/GSTBase/src/Enum/GSTDependencyType.enum.al`: enum 18051.
- India GST `src/GSTBase/src/table/GSTRegistrationNos.table.al`: table 18008.
- India GST `src/GSTSales/src/tableextension/GSTSalesInvoiceHeaderExt.TableExt.al`: tableextension 18148; GST state/registration and e-invoice fields.
- India GST `src/GSTSales/src/tableextension/GSTSalesInvoiceLineExt.TableExt.al`: tableextension 18149; line GST POS/HSN/tax-price fields.
- India Tax Base `src/src/table/State.table.al`: table 18547.
- Base Application `src/Sales/History/SalesInvoiceHeader.Table.al`: table 112, posted header and FlowFields 60/61.
- Base Application `src/Sales/History/SalesInvoiceLine.Table.al`: table 113, standard line amount and line identity fields.
- Base Application `src/Foundation/Company/CompanyInformation.Table.al`: table 79, company and contact/bank data.
- Base Application `src/Bank/BankAccount/BankAccount.Table.al`: table 270, bank account fields.
