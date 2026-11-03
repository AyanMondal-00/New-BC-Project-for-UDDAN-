# Report 50390 implementation result

Modified existing report `src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al` and `AIRIQDummyInvoice.rdl` only, plus this deliverable. No publishing or tenant operations.

The report reads posted Own Sales headers, linked invoice lines and initial Sales/Invoice Detailed GST Ledger Entries. It requires exactly one selected invoice per run to preserve the existing single-invoice body design. Passenger lines and tax entries repeat dynamically. Existing branding, styles, and section positions remain. Header/customer/company/e-invoice data now bind to dataset fields. Sample facts and unsupported Generated status were removed. Company information supplies bank, website and email. Narration uses posted Posting Description.

GST rows display the actual posted component code and rate without inferring CGST/SGST/IGST labels. Tax amounts use signed negation of sales credit entries, not ABS; negative corrections remain negative. Tax base is exposed separately and is never substituted for commercial Amount. Initial Entry filter excludes application/adjustment entries. Reversal handling requires validation against real records: this implementation preserves original initial invoice entries and does not attempt net-of-reversal accounting. Tax rows currently retain ledger-entry detail rather than collapsing multiple rows into a component/rate subtotal; this avoids duplicate aggregation but may show repeated component/rate labels.

Validation: RDL parsed successfully as XML. All Fields! references resolve to declared dataset fields. Passenger and tax tablixes each have one static header and one repeating detail row. AL compilation was attempted with installed alc.exe 18.1.2842859 and stopped before compilation because required .NET 10 runtime is missing. No compile success is claimed. RDLC renderer/schema validation and actual Business Central preview remain outstanding.

Remaining blockers:

- No local 103008 export found. Sales credit sign negation follows the user-provided negative CGST/SGST evidence; confirm amounts, reversal records and source identity on actual posted invoices.
- Component configuration is inaccessible; report prints exact posted component codes. No invented component mapping or fixed 9% labels.
- Amount-in-words and IFSC are blank because no verified source/helper was established. These requested fields remain incomplete.
- Header Amount and Amount Including VAT are standard posted FlowFields. GST/customer-ledger reconciliation must be checked before acceptance; no tax is recomputed. Rate and line Amount use Unit Price and Amount. The inclusive statement was replaced with an explicit exclusive/tax-total statement; confirm localized totals support it.
- Place of supply uses posted header State lookup. Mixed line dependency bases need runtime review before acceptance.
- IRN/acknowledgement/QR read standard fields; empty values remain empty. QR bitmap rendering and MIME type must be confirmed in RDLC preview.
- PDF unavailable; current visual styling retained, but variable-row pagination/section overlap requires actual rendering review.
- Multiple invoices per run intentionally blocked pending a per-invoice container/page grouping implementation.

This is an implementation draft requiring successful compilation and rendered preview before deployment. Codeunits 50426/50471, tax configuration and business tables were not changed.
