# Third Party Sample Purchase Format

The Tell Me page is **Third Party Sample Purchase Format** (page 50662). It imports the 16 supplied columns in their stated order. The Excel Serial No. is validated but a separate persistent counter assigns the stored number. Invoice Created is a stored Boolean derived from the Purchase Invoice No.; imported Yes values for Invoice Created or Invoice Posted fail because the file has no BC invoice reference. Blank status values mean No. Item Created = Yes is accepted only when a matching global Item exists.

Total Amount is calculated as `Rate * Total Pax` without early rounding. An imported Total Amount must match that calculation exactly. Business Central applies its own purchase-line and currency rounding when the invoice is created. The source Rate is retained as entered.

Within this module, PNR + Supplier ID + exact Purchase Date/Time identifies one purchase. The invoice worker also checks existing Sample Purchase records and open/posted purchase invoice lines for the same PNR, resolved vendor, and purchase date. This allows a reused PNR for a different supplier or purchase date. Confirm with the business whether the purchase date should be compared to the minute, to the day, or with another external transaction identifier; the source format provides no unique supplier invoice ID.

The vendor lookup tries Supplier ID as Vendor No., then Airline as Vendor Name, matching the original module. Item creation reuses a global Item with No. or Description matching PNR and never rewrites its setup. Purchase lines reuse the existing Sample custom fields for dates, airline, sector, flight type and supplier. No Base Fare or Other Charges are assigned. The standard purchase posting codeunit calculates tax and posts the invoice.

Create Purchase Invoice stores an open document number. Create & Post can post a selected open document or create and post a new one. If posting fails, it keeps the draft and source reference so a user can inspect and retry; it does not silently delete the invoice. Only records with Select = Yes are processed. The actions do not change the original Sample Purchase module.

The named source workbook was not present in the workspace during development. The column order and data types came from the task specification. An actual workbook import and BC runtime item, invoice and posting checks remain to be performed in a Sandbox.
