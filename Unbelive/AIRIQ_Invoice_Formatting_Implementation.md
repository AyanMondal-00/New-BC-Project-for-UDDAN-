# AIRIQ invoice formatting implementation

## Scope

Updated only `AIRIQDummyInvoice.rdl` as implementation, plus this requested document. Reviewed the Phase 1 comparison, both previously rendered PDFs and current report/layout. No AL source, business logic, dataset values or expressions were changed. Compilation rebuilt the local validation package; nothing was published.

## Formatting changes

- Removed unused tablix design space: passenger Height 4.51 → 1.55 cm (0.81 cm header + 0.74 cm detail template); GST Height 1.87 → 1.27 cm (0.67 + 0.60 cm). These are template dimensions, not fixed record counts. PassengerGroup and TaxGroup still repeat all matching records.
- Repositioned following body sections with small positive gaps after the tablix templates, allowing standard RDLC sibling displacement as tables grow. Passenger top is now 11.0 cm; GST heading 12.85 cm; tax table 13.3 cm; tax note 14.65 cm; summary begins 15.15 cm. No maximum row count, data hiding, clipping or new fixed-height wrapper was introduced.
- Passenger header now uses #1A74BA blue, white bold 6.4 pt captions. GST header retains #EAF3FA pale blue with blue bold 6.4 pt captions.
- Both tablixes use 6 pt horizontal cell padding and subtle #DCE6F0 0.5 pt bottom borders instead of boxed cell grids. Column widths and data/date/currency expressions remain unchanged to avoid destabilizing content fit.
- Logo and title moved down from 0.9 to 1.15 cm; tagline to 2.25 cm; e-invoice panel to 2.85 cm. Invoice metadata panels begin at 5.4 cm and seller/bill-to panels at 7.1 cm. Existing horizontal content edges and panel widths are retained.
- Reference value is left aligned within its reference area (Left 4.85 cm, Width 3.6 cm).
- Amount-in-words panel height reduced from 2.15 to 1.8 cm and given a pale #F6F9FC fill. Values remain unchanged, including blanks.
- Total bar moved to Left 11.79 cm, Width 7.80 cm, Top 16.8 cm. Existing height, branding and monetary expression remain intact.
- Narration top is 17.9 cm; bank/contact 19.25 cm; declaration/signature 21.15 cm. Existing internal content and panel heights are retained.
- Signature company heading is left aligned at 0.42 cm inset, Width 8.09 cm.
- Legal footer rule moved from 27.86 to 23.1 cm and footer text from 28.05 to 23.3 cm in template coordinates. These remain body items and follow growth above; they are not fixed page-bottom furniture. This removes unnecessary reserved vertical space that contributed to the almost-empty overflow page.
- Used supported rectangular borders and text styles. No border-radius properties, sample watermark/warning, new page globals or QR modifications were introduced.

## Validation

- All Value element contents were compared before/after the main transformation and were identical. The subsequent adjustment only added reference text alignment.
- XML parsing passed. All 33 distinct active dataset references resolve. QRImage remains declared but inactive as required by the earlier QR fallback.
- Each tablix retains exactly one DataSet_Result binding. PassengerGroup and TaxGroup remain dynamic; no group expressions or filters changed.
- ImgQRCode remains hidden with Value =Nothing and MIMEType image/png. No page-number/total-pages globals occur in the layout.
- Page size remains 21 × 29.7 cm, zero page margins, body width 21 cm. Main content remains between 1.41 and 19.59 cm; the branding strip spans exactly 21 cm. The static template footer ends at 23.7 cm, leaving approximately 6 cm for dynamic expansion before the A4 page boundary. Growth beyond a page must paginate; it is not clipped or suppressed.
- AL Compiler 18.1.43.24897 compiled all 123 project files successfully with `/project:. /packagecachepath:.alpackages /generatereportlayout- /out:AIRIQ_validation.app`. No errors. Three existing AL1025 warnings concern Info.txt and two .snapshots runtime notice files.
- Full compatible XSD/Business Central renderer validation remains unavailable locally as documented in prior validation. XML checks and AL compilation do not prove renderer acceptance or final pagination.

## Remaining visual verification

The supplied PDFs can be rasterized locally, but no local Business Central RDLC-to-PDF renderer is available. The new RDL has not been rendered to PDF. Sandbox preview must confirm dynamic sibling displacement, actual row wrapping, footer placement and absence of overlap for the two-passenger/four-GST-row example, the five-passenger example, and longer multipage invoices. One page cannot be guaranteed for arbitrary record counts.

Rounded target corners and expanded caption letter spacing were not simulated using unsupported XML or sample artwork. Existing signature line treatment, most internal typography and rectangular panel shapes remain. The footer is content-relative rather than anchored at the bottom of every page. These are remaining differences from the client PDF, not claims of an exact visual match. No content/format expression was changed to make different invoice data resemble the sample.
