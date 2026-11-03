# AIRIQ Report 50390 — data correction and financial audit

## Evidence and scope

Inspected current report/RDL, posted header extension 50429 and line extension 50430, Own Sales creator source (read-only), prior mapping/validation reports, and installed Microsoft 28.5 source symbols. Rendered and visually inspected both pages of `AIRIQ Dummy Invoice (1).pdf`: page 1 contains invoice 103008; page 2 is blank. The client sample was previously rendered and inspected; no transaction values were copied from it. No tenant connection, publication or installation occurred.

Implementation files modified:

- `src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al`
- `AIRIQDummyInvoice.rdl`

This document is the additional requested deliverable. Local validation package was rebuilt. No business tables, codeunits, posting setup or accounting calculations changed.

## Phase A — changes

| Presentation | Before | After / implementation |
|---|---|---|
| Passenger serial | Posted line numbers 10000, 20000 | RDL RowNumber("TablixPassengers") gives 1, 2, … within the filtered passenger tablix. Stored numbers and dataset line-number field unchanged. |
| Invoice date | 01-11-2026 00:00:00 | Text-run format `dd MMM yyyy`, e.g. 01 Nov 2026. Underlying posted date unchanged. |
| Travel date | Date and time on two lines | Same date-only text-run format, e.g. 30 Oct 2026; stored DateTime unchanged. |
| Rate / Amount / Total / commercial summary / GST amount | Unformatted 4500, 9000, 405 | Text-run numeric format `₹#,##0.00;-₹#,##0.00`, e.g. ₹4,500.00, ₹9,000.00, ₹405.00. Negative display signs preserved. No arithmetic changes. |
| GST registration | Bare actual number | Added static `GSTIN: ` prefix to existing seller/customer expressions. No registration values invented. |
| Addresses | Concatenation inserts commas for empty fields | AL builds CRLF-separated nonempty Address, Address 2 and City/Post Code lines. Trims boundary spaces/commas; preserves actual stored content within components. No geographic data invented. |
| Amount in words | Blank | Uses standard Report Check public procedures InitTextVariable and FormatNoText against calculated posted Amount Including VAT and posted Currency Code. Concatenates the helper's two text lines. |

The helper is verified in `.alpackages/Microsoft_Base Application_28.5.54976.57206.app`, `src/Bank/Check/Check.Report.al`, and its public API compiled successfully. It supplies standard check-style wording, including fractional units, rather than the sample's bespoke Indian Rupees sentence. It uses thousand/million/billion scales; no custom lakh/crore wording or currency name was invented. Blank posted Currency Code is passed through unchanged. Negative or trillion-and-above totals remain blank because this helper is not suitable for those values. Extremely long wording may exceed its two Text[80] lines and requires Sandbox edge-case review. Existing event subscribers/localization can affect output. The helper was not executed in a tenant during this task.

## Phase B — GST grouping decision

**No grouping change.** Current dataitem uses table 18001, Transaction Type Sales, Document Type Invoice, Entry Type Initial Entry and Document No. linked to posted header No. It exposes Document Line No., component code, GST %, signed-negated GST Amount and GST Base Amount. Sales sign normalization uses negation, not ABS; opposite-signed corrections retain opposite display signs.

Installed India GST symbols confirm Source Type, Source No., Reversal Entry and Document Line No. fields. They do not establish actual invoice 103008 record values. The current document-level query does not restrict source identity, exclude Reversal Entry, or validate each entry's line against the passenger records. Initial Entry excludes application/adjustment types but does not by itself prove reversal artifacts are absent. These limitations are preserved rather than hidden by aggregation.

The generated PDF shows SGST/CGST/SGST/CGST, each 9% and 405. Conditional arithmetic gives CGST 810 and SGST 810 if all four are valid, unreversed and attributable to the invoice. This is not sufficient record-level verification. Required evidence: read-only export with entry number, transaction/document/entry types, document/line numbers, Source Type/No., Reversal Entry, component, percentage, signed base/amount and related reversal records; compare source customer and line identity to posted header/lines. No fixed component mapping or 9% rate was added.

## Phase C — audit only

| Area | Findings and unresolved evidence |
|---|---|
| Posted Amount vs Amount Including VAT | AL calls CalcFields for both FlowFields. CommercialAmount reads header Amount; TotalAmount reads Amount Including VAT. The PDF shows 9000 in each corresponding location. This is evidence of printed values, not an independent tenant record read. |
| GST vs total | Two printed line amounts of 4500 sum to 9000. Four printed GST amounts of 405 sum to 1620. A hypothetical exclusive-plus-GST amount would be 10620, but it is not the printed/verified posted total and was not substituted. Verify line Amount/Amount Including VAT, localized tax fields, customer ledger entry and GST records before concluding why both header totals agree. |
| Value excl. GST | Still labels CommercialAmount. Its tax meaning is not proven by the PDF or standard FlowField name alone in this localized posting. Label remains unchanged per audit-only scope. |
| Tax note | Existing text says rate/amount exclude tax and total includes posted tax. The printed totals do not independently support that claim. Marked unresolved; no wording change. |
| Narration | Posted header Posting Description; PDF prints Invoice 102051. No richer persisted business narration field was found in inspected custom posted header/line or Own Sales source. Line Description is deliberately PNR, not narration. Standard comments or additional source records would require a separately specified retrieval rule. Mapping unchanged. |
| Place of Supply | Report looks up posted header State in standard State and prints Description (Code), yielding West Bengal (WB). Installed India Tax Base State source defines Code, Description and State Code for eTDS/TCS. That last field is specifically for eTDS/TCS, not automatically a GST state number. No verified GST numeric-state mapping establishes 19 here; unchanged. Bill-to/ship-to/location place-of-supply basis also needs record verification. |
| Website/email/IFSC | Website/email map to Company Information Home Page/E-Mail and appear blank in this PDF. Company bank fields are current company configuration, not posted snapshots. No explicitly verified IFSC field exists in the inspected mapping evidence; no alternative routing/transit field was relabeled. No changes. |
| E-invoice | IRN Hash, Acknowledgement No./Date and QR Code are verified standard posted fields. Printed IRN/ack fields are empty, which does not prove why they are unpopulated. QR is intentionally hidden with null image value, so its actual availability cannot be inferred visually. Encoding remains unverified. No QR/e-invoice changes. |
| Rule 32(3) | Earlier supplied export evidence described GST base 4500 per passenger and negative sales GST at 9% per component. Current PDF confirms displayed component amounts but does not expose base, reversal flags or Tax Engine basis. This does not establish consistency with the configured deemed-value rule. The domestic 5%/international 10% configuration is untouched. Tax-owner review needs actual base/computation records; no legal or configuration conclusion is asserted. |

## Validation

Complete project compilation succeeded: AL Compiler 18.1.43.24897, 123 files, `/project:. /packagecachepath:.alpackages /generatereportlayout- /out:AIRIQ_validation.app`. Initial new range guard used an integer literal too large for AL (AL0103); corrected to a decimal literal. Final compilation: zero errors; three existing AL1025 warnings for Info.txt and two runtime notice files under .snapshots.

RDL XML parses. All 32 active field references resolve (RowNumber dataset reference was replaced by the display-only RowNumber function). PassengerGroup and TaxGroup remain dynamic. Both tablixes retain exactly one DataSet_Result binding. QR remains =Nothing, hidden, MIMEType image/png. No PageNumber/TotalPages globals occur. Approved layout dimensions, positioning and groups were preserved; text formats and address/words content may affect wrapping.

No updated Sandbox PDF was rendered. Existing supplied PDF has a blank second page; this task did not change layout dimensions to address it. Full compatible RDL schema/renderer validation remains unavailable locally. Date month language, rupee glyph, separators, multiline addresses, standard helper wording and pagination require Sandbox preview before acceptance.

## Items needing evidence and approval before subsequent changes

1. Obtain read-only posted invoice/customer/GST records and settle reconciliation before changing tax note, exclusive label, totals or GST grouping.
2. Confirm numeric GST place-of-supply mapping and address basis before replacing WB with 19.
3. Specify richer narration, IFSC/contact sources and desired Indian amount-in-words convention before changing those mappings beyond the standard helper implemented here.
4. Verify actual QR bytes/integration population before restoring the QR image.
5. Approve any further pagination/layout change separately after reviewing the new Sandbox PDF.
