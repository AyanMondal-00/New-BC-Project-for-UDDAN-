# AIRIQ Final GST Verification — Own Sales Report 50390

## Result and evidence scope
This is read-only source verification against the AIRIQ project and the installed Business Central 28.5 package archives in `.alpackages`. The relevant `.app` archives were listed and source entries extracted with `unzip -Z1` / `unzip -p`; no tenant was accessed and no AL/RDL/configuration was altered. Archive internals cited below are under exact packages in the package table.

| Package | Version | Verified role |
|---|---|---|
| Microsoft India GST | 28.5.54976.57206 | GST ledger tables, GST document enums, component code fields, posted GST invoice extensions, e-invoice fields. |
| Microsoft India Tax Base | 28.5.54976.56550 | State table 18547. |
| Microsoft Base Application | 28.5.54976.57206 | Posted Sales Invoice Header 112 / Line 113, Company Information 79, Bank Account 270. |
| Microsoft Tax Engine | 28.5.54976.56550 | Installed; component calculation/use-case setup is configurable. No tenant values are available from this local package inspection. |

## 1. Exact GST document types and filter syntax

Detailed GST Ledger Entry is table 18001, field `"Document Type"` is `Enum "GST Document Type"` (`src/GSTBase/src/table/DetailedGSTLedgerEntry.table.al`). The exact enum is object 18021 in `src/GSTBase/src/Enum/GSTDocumentType.Enum.al`; it defines value ID 2 named `Invoice` (also Payment=1, Credit Memo=3, Refund=4).

Correct AL filter syntax is:

```al
DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
```

This is deliberately distinct from table 18005 GST Ledger Entry, whose field `"Document Type"` uses enum 18012 `Detail GST Document Type` (also has Invoice=2, but it is a different enum type). Never assign the enum 18012 member to field 18001.

## 2. GST component identification: tenant configuration blocker

Verified ledger fields:

- Table 18001 Detailed GST Ledger Entry field 13 `"GST Component Code"`: Code[30].
- Table 18005 GST Ledger Entry field 20 `"GST Component Code"`: Code[30].
- Neither field is an enum and the inspected GST package has no universal `CGST`/`SGST`/`IGST` enum that can safely classify rows. GST Posting Setup is table 18007 with key (`State Code`: Code[10], `Component ID`: Integer) and posting account fields, but it does not provide the component code/name mapping itself.
- GST Tax Engine use-case/component configuration and actual company data determine the component codes. Local project JSON and README describe configured behavior but do not prove the active tenant’s component IDs/codes or posting output.

**Runtime verification required:** in a read-only sandbox/company, open the standard GST component/use-case setup pages (or inspect relevant GST Tax Engine component configuration records through read-only pages/API), record configured component identifiers and labels for central, state, and integrated GST, then inspect a posted Own Sales invoice with mixed/intra-state and inter-state examples. Confirm ledger component codes and their amounts/rates against the configured component record and source invoice. Do not infer classification from code substrings or from accounts alone. Preserve the confirmed mapping as a configuration-backed lookup in report design.

Safe procedure:

1. Select an already-posted Own Sales invoice (`Sales Invoice Header` 112 where project `"Sales Type"` = Own Sales); do not post a new document for this read-only task.
2. Read its lines from Sales Invoice Line 113 and corresponding Detailed GST Ledger Entry 18001 rows using the filters below.
3. Display `"GST Component Code"`, component setup label/ID, `"GST %"`, `"GST Base Amount"`, `"GST Amount"`, `"Document Line No."`, transaction/document/source fields side by side.
4. Independently compare the component mapping to configured Tax Engine/GST setup. If no matching configured record is exposed/readable, leave labels as component codes and mark CGST/SGST/IGST classification blocked.

## 3. Posted GST filter and aggregation

For posted header `SalesInvHeader: Record "Sales Invoice Header"` and its line `SalesInvLine: Record "Sales Invoice Line"`, the strongest line-level relationship in Detailed GST Ledger Entry is table key14:

`("Transaction Type", "Document Type", "Document No.", "Document Line No.", "GST Component Code")` with SumIndexFields `"GST Amount"`.

Safe starting filters:

```al
DGLE.Reset();
DGLE.SetRange("Transaction Type", DGLE."Transaction Type"::Sales); // enum 18014, Sales=1
DGLE.SetRange("Document Type", DGLE."Document Type"::Invoice);   // enum 18021, Invoice=2
DGLE.SetRange("Document No.", SalesInvHeader."No.");
DGLE.SetRange("Document Line No.", SalesInvLine."Line No.");
```

Fields on 18001 include `"Source Type"` enum `Source Type` and `"Source No."` Code[20]. Filtering `Source Type` to Customer is appropriate for customer sales entries where that source identity is populated. Validate the actual source number from posted entries against the posted header’s bill-to/sell-to customer context before using a source-number predicate; the package alone does not prove which customer number is written in every invoice flow. Add source filters only after confirming the source semantics in read-only posted records. The document type/transaction type/document no/line no combination is already the primary exact key; do not join on document number alone.

Entry/reversal handling:

- Detailed ledger field 2 `"Entry Type"` uses enum 18013: Initial Entry=0, Application=1, Adjustment Entry=2.
- Detailed ledger field 36 `"Reversal Entry"` Boolean.
- `"GST Amount"` is the posted detail amount. For invoice tax display, include the initial posted invoice tax entries. Do not blindly include Application or Adjustment Entry rows in the original tax summary; first establish from actual records whether those types are present and whether they represent settlement, correction, or legitimate tax adjustment. If adjustments must be reflected, report them distinctly or apply a documented netting rule.
- The package provides an Initial Entry enum but no generic `Reversed` Boolean on table 18001 (the explicit `Reversed` fields are on parent table 18005). Verify reversal rows through `"Reversal Entry"`, document type/no, transaction and related reversal document/transaction where applicable; exclude reversal artifacts from original invoice tax unless intentionally presenting net-of-reversal values.
- Avoid counting table 18005 and 18001 together: they are separate ledger representations. Use Detailed GST Ledger Entry for line/component/rate reporting and GST Ledger Entry only when a separately validated document aggregate is needed.
- Group/sum only at a consistent grain, at minimum document + line + component code + GST %. Different rates/components must stay distinct. Sum posted `"GST Amount"`; retain `"GST Base Amount"` from ledger as the tax base. Never recompute tax from Base Fare, Sales Invoice Line Amount, or custom posted line CGST/SGST/IGST.

## 4. Posted invoice display semantics and reconciliation

Base Application source confirms:

- Sales Invoice Line (113): `"Unit Price"` Decimal (field 22), `Amount` Decimal (29), `"Amount Including VAT"` Decimal (30), Quantity Decimal (15), document no Code[20] and line no Integer.
- Sales Invoice Header (112): `Amount` Decimal FlowField (60), sum of line Amount by document no; `"Amount Including VAT"` Decimal FlowField (61), sum of line Amount Including VAT by document no. Call `CalcFields(Amount, "Amount Including VAT")` before reading.

Recommended printed meanings:

| PDF concept | Posted source |
|---|---|
| Passenger Rate | Sales Invoice Line `"Unit Price"` (commercial price per unit); if the GST extension’s actual `"Unit Price Incl. of Tax"` field (18155) is populated and matches the intended inclusive display, that is an explicit localized inclusive-rate candidate. Confirm actual posted values before choosing. |
| Passenger Amount | Use Sales Invoice Line `Amount` for excl-tax commercial line value, or `"Amount Including VAT"` for inclusive line value. Label must match selected field. |
| Invoice Value Excluding GST | Header `Amount` FlowField (or sum of lines’ Amount); it is the posted commercial amount excluding VAT/tax. It is not GST Ledger Entry `"GST Base Amount"`. |
| CGST/SGST/IGST tax | Detailed GST Ledger Entry (18001) `"GST Amount"`, classified by verified component setup, grouped by GST % as needed. |
| Invoice Total | Header `"Amount Including VAT"` FlowField (61), after CalcFields. Reconcile to posted line totals and customer ledger as needed. |

AIRIQ Own Sales invoice creation (codeunit 50426) computes UnitPriceValue = Normal Sales `"Base Fare"` + `"Other Charges"` and validates it into Sales Line `"Unit Price"`; it sets quantity per passenger. It does not set a GST-inclusive price field or manually map tax. Project README says the Tax Engine handles GST separately. Therefore source code alone does **not** prove that the RDL’s static phrase “Rate & Amount are inclusive of GST” matches posted data. Existing RDL has that exact phrase and sample inclusive-looking values, but the current report is dummy data. Compare actual posted line Unit Price, Amount, Amount Including VAT, localized `"Price Exclusive of Tax"` and `"Unit Price Incl. of Tax"` flags/values before retaining the phrase. Flag it for invoice-owner review; do not alter tax logic.

## 5. Remaining source verification

| Field | Verified standard source | Status |
|---|---|---|
| Seller GST registration | India GST tableextension 18148 on Sales Invoice Header 112: field 18154 `"Location GST Reg. No."` Code[20], relation to GST Registration Nos. 18008. That table has `Code` Code[20], `"State Code"` Code[10], `Description` Text[50]. | Posted field exists; whether Code is the display GSTIN or a registration code requiring lookup is not proven by schema alone. Verify actual stored value/config. |
| Customer GSTIN | Header extension 18148 field 18155 `"Customer GST Reg. No."` Code[20], field 18156 `"Ship-to GST Reg. No."` Code[20]. | Posted snapshots exist; verify which one matches PDF Bill-to and formatting. |
| Place of Supply | Header extension fields `"GST Bill-to State Code"` 18150, `"GST Ship-to State Code"` 18151, `"Location State Code"` 18152, `State` 18166 (all Code[10]); posted line extension 18149 field 18141 `"GST Place of Supply"` enum 18051 means Bill-to Address / Ship-to Address / Location Address, not state itself. State table 18547 has Code Code[10], Description Text[50]. | Available as stored state-code candidates plus lookup for name. Select basis using posted value/transaction semantics; no single universal state field should be assumed. |
| IRN | Header extension 18148 field 18172 `"IRN Hash"` Text[64]. | Available if e-invoice integration populated it. |
| Acknowledgement number/date | Fields 18171 `"Acknowledgement No."` Text[30] and 18174 `"Acknowledgement Date"` DateTime. | Available if populated. |
| QR | Field 18173 `"QR Code"` Blob, Subtype Bitmap. | Blob exists. Symbol does not guarantee it is signed QR payload or provide an AL text field named Signed QR Code. |
| E-invoice status | No status field found on posted Sales Invoice Header extension 18148. `"E-Inv. Cancelled Date"` 18176 and `"Cancel Reason"` 18177 exist but do not establish a general generated status. | Unavailable/unverified in inspected posted schema. Do not print static “Generated” as a dynamic fact. |
| Bank IFSC | Base Application Company Information 79 has Bank Name, Bank Branch No., Bank Account No., Payment Routing No.; Bank Account 270 has Bank Account No. and Transit No. No field explicitly named IFSC was found in inspected Base Application or relevant India GST source. | IFSC unavailable/unverified; Transit No. must not be called IFSC absent explicit configuration evidence. |
| Website/email | Company Information 79: `"Home Page"` Text[255] (35), `"E-Mail"` Text[80] (34). | Available through Company Information lookup; not a posted snapshot. |
| Amount in words | No standard amount-in-words routine identified in the installed package source entries searched. | Unverified/unavailable from inspected symbols; do not promise standard helper. |

## 6. Remaining blockers ranked

1. **High — tenant component mapping:** actual GST component codes and their CGST/SGST/IGST meaning are not in installed package schemas; inspect the active configured component/use-case records and posted Own Sales ledger rows read-only.
2. **High — posted record semantics:** validate Source Type/Source No., entry types, reversal behavior, and GST component/rate rows on actual posted invoices. Package schema establishes fields/keys, not which rows a particular posting produced.
3. **High — inclusive/exclusive invoice text:** existing AL sets commercial Unit Price to Base Fare + Other Charges and does not set localized inclusive fields. Verify real posted Amount vs Amount Including VAT and `"Price Exclusive of Tax"` before deciding whether to retain the RDL statement.
4. **Medium — GSTIN/POS rendering:** choose appropriate seller/customer registration and state code snapshot for this invoice, resolve state name, and confirm actual values/format in tenant.
5. **Medium — e-invoice completion/status:** IRN, acknowledgement, QR fields exist, but runtime population and signed-QR semantics are not established; no general status field identified.
6. **Medium — IFSC and amount words:** no verified standard IFSC field/helper in searched packages.
7. **Medium — source PDF:** the referenced PDF itself was not found in the workspace; validate labels against the actual artifact before implementation.

## 7. Final implementation readiness checklist

- [ ] Drive report 50390 from posted Sales Invoice Header 112 and filter project extension `"Sales Type"` = Own Sales.
- [ ] Link child posted lines by `Sales Invoice Line."Document No."` = header `"No."`; use posted custom passenger/travel fields and posted Description for PNR.
- [ ] GST query uses enum 18021 `GST Document Type::Invoice` (not enum 18012), transaction enum 18014 `Sales`, header document no., and line no.; add source filters only after runtime confirmation.
- [ ] Decide and document initial/application/adjustment/reversal treatment against actual ledger rows; avoid duplicate rows and no double-counting with table 18005.
- [ ] Obtain configured component-code mapping before labels CGST/SGST/IGST; preserve multiple-rate groups.
- [ ] Bind GST amount/rate/base from posted Detailed GST Ledger Entry; never derive tax from Base Fare, line amount, or custom tax fields.
- [ ] Call header CalcFields for Amount and Amount Including VAT; independently reconcile to line totals and determine exact inclusive/exclusive PDF labels.
- [ ] Verify seller/customer GSTIN and Place of Supply source values; resolve State.Code to State.Description where needed.
- [ ] Bind e-invoice values only where fields are populated; remove unsupported static status/IRN/ack/QR sample facts and hide missing values.
- [ ] Confirm IFSC and amount-in-words approach or mark those fields absent; do not map unrelated fields by guess.
- [ ] Convert existing RDL tablix row members to repeating dataset-bound rows while preserving existing visual design; keep tax rows capable of multiple rates/components.
- [ ] Validate against actual PDF and at least one already-posted Own Sales invoice for intra-state and one inter-state case, read-only where possible; no GST posting or invoice-creation logic changes.

## 8. Source paths and precise evidence

Project:

- `src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al`: report 50390, Integer Number 1..3 sample dataset and literal columns (lines 1-83).
- `AIRIQDummyInvoice.rdl`: fixed passenger/tax rows, inclusive text, sample totals and tax labels (passenger tablix starts near 1179; tax tablix near 2770; inclusive label and totals in body).
- `src/Sales Invoice Creation/Own Sales/AIRIQCreateSalesInvoiceCodeUnit.al`: unit price Base Fare + Other Charges, passenger quantity, flight type and standard Tax Engine note; custom GST mapping removed (around lines 54-56, 181-207).
- `src/Sales Invoice Creation/Own Sales/AIRIQPostedSalesInvoiceMgtCodeUnit.al`: posted custom fields transferred; no assignment to custom posted CGST/SGST/IGST (lines 1-67).
- `src/Sales Invoice Creation/Own Sales/AIRIQSalesInvoiceHeaderTableExt.al`: Sales Header custom AQ number, Agency ID, Sales Type.
- `src/Base Table Extended/Posted Invoice Form/AIRIQPostedSalesInvoiceHeaderExt.al`: Sales Invoice Header custom fields and Own Sales OptionMember.
- `src/Base Table Extended/Posted Invoice Form/AIRIQPostedSalesInvoiceLineExt.al`: custom passenger/travel fields and unused custom tax fields.
- `AIRIQ-GST-README.md`: configured use-case notes and explicit pending live posted-ledger validation.
- Prior analyses: `AIRIQ_OwnSales_Report_Mapping_Analysis.md`, `AIRIQ_India_GST_Exact_Symbol_Mapping.md`.

Installed package archive paths:

- `.alpackages/Microsoft_India GST_28.5.54976.57206.app` → `src/GSTBase/src/Enum/GSTDocumentType.Enum.al` (enum 18021); `DetailGSTDocumentType.Enum.al` (enum 18012); `DetailLedgerTransactionType.Enum.al` (18014); `DetailLedgerEntryType.Enum.al` (18013); `GSTDependencyType.enum.al` (18051); `GSTLedgerEntry.table.al` (table 18005); `DetailedGSTLedgerEntry.table.al` (table 18001; fields, reversal and key14); `GSTPostingSetup.table.al` (table 18007); `GSTRegistrationNos.table.al` (table 18008); `GSTSales/src/tableextension/GSTSalesInvoiceHeaderExt.TableExt.al` (18148); `GSTSales/src/tableextension/GSTSalesInvoiceLineExt.TableExt.al` (18149).
- `.alpackages/Microsoft_India Tax Base_28.5.54976.56550.app` → `src/src/table/State.table.al` (table 18547).
- `.alpackages/Microsoft_Base Application_28.5.54976.57206.app` → `src/Sales/History/SalesInvoiceHeader.Table.al` (112); `SalesInvoiceLine.Table.al` (113); `src/Foundation/Company/CompanyInformation.Table.al` (79); `src/Bank/BankAccount/BankAccount.Table.al` (270).
