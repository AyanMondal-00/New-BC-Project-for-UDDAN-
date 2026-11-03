# AIRIQ typography and watermark update

Implementation file changed: `AIRIQDummyInvoice.rdl` only. This document is the requested additional deliverable. AL source and dataset/business logic were not changed; a local validation package was rebuilt. Nothing was published.

## Typography

Specified text elements now request FontFamily DejaVu Sans and explicit Bold or Normal weights. Sizes use 1 px = 0.75 pt:

| Elements | px | RDLC pt | Weight |
|---|---:|---:|---|
| TAX INVOICE | 23 | 17.25 | Bold |
| TRAVEL PLATFORM; sample subtitle | 8 | 6 | Bold |
| E-INVOICE DETAILS | 9 | 6.75 | Bold |
| IRN / Ack labels | 10 | 7.5 | Bold |
| IRN / Ack values | 10 | 7.5 | Normal |
| QR caption | 7 | 5.25 | Normal |
| Invoice metadata labels; seller/buyer captions | 9 | 6.75 | Bold |
| Invoice number and reference value | 17 | 12.75 | Bold |
| Invoice date; seller and buyer names | 16 | 12 | Bold |
| Place of supply | 14 | 10.5 | Bold |
| Addresses | 11 | 8.25 | Normal |
| Combined GSTIN label/value expressions | 10 | 7.5 | Normal |
| INVOICE DETAILS; TAX BREAKDOWN | 10 | 7.5 | Bold |
| Passenger and tax table headers | 9 | 6.75 | Bold |
| Passenger name; passenger amount | 12 | 9 | Bold |
| Passenger serial, PNR, travel date, SAC, quantity, rate | 11 | 8.25 | Normal |
| GST components, including summary | 10 | 7.5 | Bold |
| GST rates/amounts; commercial summary | 10 | 7.5 | Normal |
| Amount-in-words caption | 9 | 6.75 | Bold |
| Amount-in-words value; INVOICE TOTAL caption | 11 | 8.25 | Bold |
| Invoice total value | 18 | 13.5 | Bold |
| Narration, bank/contact, declaration captions | 9 | 6.75 | Bold |
| Narration; bank/contact values | 10 | 7.5 | Normal |
| Bank/contact field labels | 10 | 7.5 | Bold |
| Declaration text | 9 | 6.75 | Normal |
| Footer text | 8 | 6 | Normal |

Custom AIRiQ logo runs remain unchanged. Unspecified annotation/signature styles remain unchanged. Existing text values, expressions, formats, colors, positions, dimensions, borders, groups and filters were preserved. Before/after comparison confirmed all textbox Value contents identical.

**GSTIN limitation:** each existing GSTIN caption and number is a single concatenated expression. With the strict prohibition on changing expressions or structure, the caption cannot independently be 11 px Bold while its value is 10 px Normal. The combined run uses the requested value style. Exact separate styling requires approval to split the expression into two runs.

## Font availability

Client PDF font dictionaries declare DejaVuSans and DejaVuSans-Bold. The latest supplied generated PDF (`AIRIQ Dummy Invoice (2).pdf`) declares Segoe UI and Segoe UI Bold. DejaVu Sans is not installed locally. Tenant renderer font inventory is not accessible, and the supplied PDF cannot prove availability for this updated RDL. The layout requests DejaVu Sans as explicitly specified; exact font rendering is not claimed. Segoe UI is the observed compatible fallback in prior generated output, but RDLC has no CSS-style ordered font fallback list, so substitution is controlled by the renderer. If the tenant lacks DejaVu Sans, approve an explicit Segoe UI fallback or provide renderer font availability evidence before expecting an exact match. No fonts were installed, bundled or redistributed.

## Watermark removal

Removed the body Style BackgroundImage binding to AIRIQWatermark and removed EmbeddedImage AIRIQWatermark including its PNG payload. Zero watermark-named items and zero BackgroundImage elements remain. No replacement watermark or hidden watermark element was added. Ordinary sample subtitle text was preserved, as requested; actual header logo and QR handling were untouched. The unused QRCodeImage asset was not removed because it is unrelated to this scope.

## Validation

- RDL parses as XML; all 32 active dataset field references resolve.
- PassengerGroup, TaxGroup and TaxGroupSummary remain; all three tablixes have one DataSet_Result binding each.
- ImgQRCode retains image/png MIMEType, hidden state and null value. No PageNumber/TotalPages globals were introduced.
- No unsupported typography/radius/opacity properties were introduced. A full compatible RDL XSD validator is unavailable locally, so complete renderer schema acceptance is not claimed.
- Complete AL project compiled successfully with AL Compiler 18.1.43.24897, 123 files, existing .alpackages, /generatereportlayout-, output AIRIQ_validation.app. Zero errors; three existing AL1025 warnings for Info.txt and runtime notices.
- A4 remains 21 × 29.7 cm. No page/element dimensions or layout hierarchy were changed. Smaller converted sizes reduce some clipping pressure, but exact font metrics, address/words wrapping, table growth and pagination require Sandbox PDF preview. No new PDF was rendered in Business Central during this task.

Remaining limitations: unknown renderer DejaVu availability, combined GSTIN styling constraint, and unverified final text clipping/pagination. No financial or posting changes are needed to assess these typography limits.
