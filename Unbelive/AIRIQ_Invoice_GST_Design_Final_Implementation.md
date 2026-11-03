# AIRIQ GST and design implementation

## Changed files and scope

Implementation changes are limited to the existing Report 50390 AL file (`src/Sales Invoice Creation/Own Sales/Sales Invoice Format Design/AIRIQDummyInvoice.Report.al`) and `AIRIQDummyInvoice.rdl`. This document is the requested deliverable; the local AIRIQ_validation.app was rebuilt. Existing mapping, formatting and audit notes were consulted. No posting codeunit, business table, tenant record or Microsoft GST configuration was changed. No publication or installation occurred.

## Component breakdown and amount summary

TaxGroup now groups by InvoiceNo, actual TaxComponent and TaxPercent. TaxAmount is Sum(Fields!TaxAmount.Value), with one row per component/rate. Component and percentage sort ascending: literal configured CGST sorts before SGST without hardcoded rates, amounts or component classification. IGST and other codes are supported. Configured aliases are displayed as stored; their semantic order is not inferred.

A new dynamic TablixTaxSummary replaces the four previously blank fixed CGST/SGST summary textboxes. It uses the same dataset, non-null TaxEntryNo filter, grouping expressions, sorting and signed sum as the breakdown. Its columns show actual component, @ percentage and amount. It retains the existing rupee/two-decimal formatting. The Value excl. GST field still reads posted header Amount; Invoice Total still reads Amount Including VAT after CalcFields. No tax is added to or subtracted from either FlowField.

The AL GST query retains Sales / Invoice / Initial Entry and exact header document linkage. It now skips explicitly flagged Reversal Entry rows, rejects non-Customer sources and customer numbers outside the posted header bill-to/sell-to identity, and requires each nonzero Document Line No. to exist on that same posted invoice. Zero line numbers are allowed for document-level entries. Every eligible ledger record is emitted once by Entry No.; sibling passenger data is not joined or multiplied. Both display tablixes independently sum the same eligible records, not each other, so they do not double-count in the dataset. Negative sales GST amounts are negated, not ABS; non-reversal opposite-signed correction entries stay negative in presentation.

**Verification limitation:** This is original-invoice presentation, not complete net-of-reversal reconciliation. Excluding a flagged reversal does not prove its original counterpart remains economically valid. Actual entry/source values, reversal linkage and whether zero-line and line-level entries represent independent tax still require tenant record evidence. Unknown/blank source identities are deliberately excluded and may reduce displayed tax if the tenant populates fields differently; compare against a read-only export before acceptance. No assertion is made that all four 103008 entries pass these new eligibility checks. If they do, CGST and SGST each sum to 810 from the posted records, without constants. The component rows remain dynamic, including multiple rates.

## Financial reconciliation

Existing PDF/audit evidence shows two commercial lines totaling 9000 and four GST entries totaling 1620, while both displayed commercial value and invoice total are 9000. Header Amount and Amount Including VAT are sums of posted lines, not DGLE. No current tenant record read establishes why localized GST is absent from the difference. A hypothetical 10620 was not substituted. The existing Value excl. GST label/value mismatch remains explicitly unresolved; so does the existing tax-inclusive/exclusive statement. Financial values and those existing mappings were preserved. Required evidence remains posted line Amount/Amount Including VAT, tax-inclusive settings, customer ledger amount and all GST/reversal records.

## Indian amount in words

Inspected standard Report Check InitTextVariable/FormatNoText, which uses check markers, fractional notation and thousand/million/billion scales. Replaced its call with local report-only RupeeWords/IndianNumber helpers. They use the actual calculated Amount Including VAT, round to two decimal places for wording, split rupees/paise, recursively express Crore, Lakh, Thousand, Hundred and smaller units, and output title-case words with Indian Rupees prefix and Only suffix. Whole rupees omit paise; fractional values include And … Paise; negative values include Minus. There is no hardcoded transaction sentence, check marker or /100 suffix. No stored or displayed numeric amount is recalculated. This requested INR wording assumes this report is used for INR invoices; foreign-currency usage requires a separately approved currency-aware wording policy.

The helper compiles but has not been executed in Business Central during this task. Sandbox cases should include 0, 9000, 9000.25, 100000, 10000000, negative corrections and rounding near a rupee boundary. Very large wording can grow the words panel and requires pagination review.

## Rule 32(3) note

TxtGSTNote contains exactly:

GST on Air Travel Agent's service under Rule 32(3), CGST Rules, 2017 (value deemed at 5% of basic fare for domestic / 10% for international). GST included in invoice value.

It is explicitly Hidden=true, immediately following the breakdown in design order. Configuration names and prior supplied base/amount evidence do not prove that both assertions hold for this invoice. Enabling it requires verified transaction tax basis and inclusive treatment. No domestic/international setup was modified.

## Fonts, corners and watermark

The client PDF's readable PDF font dictionaries identify subset DejaVuSans and DejaVuSans-Bold, with Helvetica and Times-Roman also declared. This proves declared fonts, not which font is used by every individual text run. Local installed fonts include Segoe UI, not DejaVu Sans. Existing Segoe UI styling and bold weights are retained as the available fallback; an exact font match is not claimed and no proprietary font was redistributed.

True rounded corners remain a documented limitation. Native RDLC Rectangle has no supported radius property. Fixed raster frames would not track dynamic narration/address/words growth safely; no such frames or unsupported XML were introduced. Existing supported rectangular panel styling remains. A renderer-tested growable shape technique is still needed for an exact rounded-panel match.

Added a transparent PNG EmbeddedImage named AIRIQWatermark, generated locally with System.Drawing: 794 × 1123 at 96 dpi, pale coral alpha 22/255, bold AIR IQ rotated -35 degrees and centered. Body Style uses supported BackgroundImage Source=Embedded, Value=AIRIQWatermark, BackgroundRepeat=Clip. It is background decoration, not an overlapping report item, so it reserves no page space and contains no SAMPLE text. Existing panel fills may conceal portions of the watermark; this preserves text legibility rather than making panels transparent. Background image behavior on longer body pages and final visible placement must be verified in Sandbox. Existing QR handling is unchanged.

## Validation results

- Complete project compilation passed after the final watermark changes: AL Compiler 18.1.43.24897, 123 files, `/project:. /packagecachepath:.alpackages /generatereportlayout- /out:AIRIQ_validation.app`. Zero errors; same three existing AL1025 warnings for Info.txt and runtime notice files.
- RDL XML parsing passed; all 32 distinct active Fields references resolve.
- PassengerGroup, TaxGroup and new TaxGroupSummary are present. Each of the three tablixes has exactly one DataSet_Result binding. Both tax group keys and sums match.
- Broader duplicate-child scan found no unexpected repeated singleton candidates after allowing known collection nodes. This is not full XSD validation or proof of schema ordering.
- ImgQRCode retains MIMEType image/png, Value=Nothing and Hidden=true. Watermark PNG has an explicit image/png EmbeddedImage MIME type. No QR bytes were invented or restored.
- No Globals!PageNumber/TotalPages references remain. A4 dimensions remain 21 × 29.7 cm; no page size, business expressions or passenger formatting were changed.
- No compatible local Business Central RDLC renderer or complete compatible XSD validator was available. AL compilation does not validate all RDL expression/rendering rules. No new Sandbox PDF rendering or exact visual match is claimed.

## Remaining evidence and approval items

1. Read-only ledger export and customer reconciliation before declaring reversal-safe totals or changing the exclusive label / tax note. Verify new source eligibility does not omit legitimate entries.
2. Sandbox preview of both tax tablixes, 0/1/multiple tax rates, long passenger lists and words, watermark layering, rupee glyphs and dynamic displacement of the total/lower panels.
3. Verify Rule 32(3) basis and inclusive treatment before enabling its note.
4. Decide whether exact DejaVu font deployment and a renderer-tested rounded-corner technique are required; these remain visual differences.
5. Review foreign-currency usage before extending this INR-specific report wording beyond INR documents.
