# Sales Return → Sales Credit Memo

Five AL files add an unposted credit memo action to page 50413. Existing objects and business calculations are unchanged.

| File | Objects |
|---|---|
| AIRIQSalesReturnCreditMemoCU.al | Codeunit 50715: creation, Customer/PNR matching, passengers, GST comparison |
| AIRIQSalesCreditMemoTables.al | TableExtensions 50715–50717: Sales Header, Sales Line, Sales Return |
| AIRIQSalesCreditMemoPages.al | PageExtensions 50715–50717: Sales Credit Memo (44), Sales Cr. Memo Subform (96), Sales Return List (50413) |
| AIRIQSalesReturnIntegrity.al | Registry table 50715, integrity codeunit 50716, install codeunit 50717, upgrade codeunit 50718, permission set 50715 |
| AIRIQSalesCreditMemoPosting.al | Posted header/line TableExtensions 50718–50719 and posting codeunit 50719 |

## Mapping

Header: exact unique Customer.Name = A/C Name, as in codeunit 50426. Agency ID uses existing header Agency ID (20 characters); longer source values error rather than truncate. Existing Sales Type maps Own/ThirdParty. New fields 50715–50723 retain Return No., source Serial, Bill No., original Invoice No., Entry Date, Reference, Narration, Supplier and source Sale Type. Standard Credit Memo Nos. generates the document number. Location SILIGURI and Document Date Today follow 50426; Customer defaults govern currency and place of supply; Prices Including VAT is explicitly false.

Lines: unique Item.Description = PNR; actual matched Item No. is validated. Existing Travel Date, Sector, FlightType, BaseFare and Passenger Name fields are reused. Fields 50715–50730 retain source Taxable Value, CGST, SGST, IGST, Sold Value, XXLN Charges, Refund Amount, Country, State, City, Travel Time, Airline, Airline Code, Reference, Passenger Type and Passenger SL No. Source financial fields are metadata, copied unchanged on each passenger line; do not sum that metadata across passenger lines. Standard line fields supply financial totals.

Passengers are filtered by both Return No. and PNR and ordered by their existing composite key/SL No. As in 50426, each passenger produces one item line with quantity 1. Passenger details do not create additional financial lines. Count must match PAX when passenger records exist. With no matching passengers, one line uses source Passenger Name and quantity PAX. Type and SL No. are retained separately. A failed operation rolls back all lines; repeat creation is blocked.

## Financial mapping

Passenger Name, Passenger Type and Passenger SL are displayed immediately after Description in the credit memo lines. Creation rejects blank passenger names and a Return No. whose passenger records exist but have no matching PNR. If no passenger detail records exist, the source Passenger Name must be populated for the existing fallback. View Passenger is a navigation link, not proof that passenger data exists. Existing drafts are not rebuilt or automatically backfilled by this change.

Confirmed business rule: **Sales Return Base Fare = Unit Price Excl. VAT**. Creation validates Unit Price from Base Fare directly and sets header Prices Including VAT to false after Customer validation and before creating lines. Each passenger line has quantity 1; the fallback line has quantity PAX. Standard BC computes line amounts and GST. Positive Base Fare and PAX are required; generated line and invoice discounts are disabled.

Sold Value, Taxable Value, XXLN Charges and Refund Amount remain source metadata and do not change Unit Price. Refund Amount is displayed for review against the resulting standard total. The temporary reviewed-price fields (50717/50718 on Sales Return) are retained as obsolete pending to preserve schema/data compatibility, removed from the page, and unused by creation.

## GST

Existing Customer/location/item GST setup, GST Group and HSN/SAC are reused. FlightType is populated before price as in 50426. Because the existing FlightType tax trigger runs only for invoices, the new flow calls the standard Calculate Tax sales-line API after final line modification. No custom tax formula, percentage or posting entry is added. Source tax metadata never overwrites BC tax results.

After creation, standard GST component amounts are totalled from Tax Transaction Value using Tax Component names CGST/SGST/IGST. Differences above 0.01 are reported, with source and BC values. Missing component results produce a review message, not a claim of zero GST. Confirm tax component names in customized configurations. Full posting preview and domestic/interstate/international sandbox checks remain required; the module never auto-posts.

## Return No. uniqueness and duplicates

No live business-data connector is available here, so historical duplicates have not been inspected. Adding a unique secondary key directly through a tableextension is unsupported, and a plain unique key would also prohibit multiple blank Return Nos. Instead, registry table 50715 has a database **primary key on nonblank Return No.**, claimed transactionally through Sales Return insert/modify/rename/delete database event subscribers. These run even when RunTrigger is false; temporary records are excluded. Blank source Return Nos. are allowed but cannot create a memo. A conflicting claim raises `Sales Return with Return No. %1 already exists.` Concurrent inserts cannot both commit the same registry key; a concurrent key conflict can require retry.

Install/upgrade audits every company's historical rows and seeds the registry. Any duplicate nonblank Return No. aborts that company's operation without deleting or changing historical source rows. Migration plan: test installation/upgrade against a sandbox copy, list duplicates by Return No., have the business owner decide the correct identifiers and matching passenger references, correct them through an approved data repair, then retry. No automatic merge, deletion or renumbering is performed. Do not delete registry rows manually or disable the extension's database subscribers.

Creation locks and rereads the source, checks open and posted credit headers by Return No., and checks the permanent source tracking fields. Source links remain after deleting a draft, preventing accidental recreation. Linked source Return Nos. cannot change and linked sources cannot be deleted. No explicit COMMIT or automatic posting is used; creation rejects explicit commits from nested calls. Posting subscribers copy only custom fields using BC 28 symbol-verified OnBeforeSalesCrMemoHeaderInsert and OnBeforeSalesCrMemoLineInsert events. Standard posting remains responsible for all financial fields.

## Setup and validation

Assign AIRIQ SALES RETURN alongside normal AIRIQ and BC sales/GST permissions. Configure Sales & Receivables Setup Credit Memo Nos., Customer/item posting groups, SILIGURI, GST registrations, GST Groups, HSN/SAC and standard tax configuration. No number series is created or replaced. Deploy through a sandbox first; no live records have been accessed or migrated here.

AL Compiler 18.1.43.24897 compiled the entire project (136 AL files) against existing BC 28.5 .alpackages successfully: zero errors and zero module warnings. Three existing AL1025 warnings concern Info.txt and snapshot license files. An offline project audit found no duplicate object IDs or field IDs/names. Generated build artifacts were removed. Runtime testing is not available here. Test: successful one/multiple-passenger returns; no-passenger fallback; wrong PNR and mismatched passenger counts; missing/ambiguous Customer/Item; Base Fare price mapping and positive-value guard; standard number generation; GST differences and absent tax results; duplicate entries including Insert(false)/Modify(false); simultaneous same Return No. creation; deleted draft links; manually posted memo duplicate detection; historical duplicate upgrade failure. Posting preview must confirm document totals and actual tax treatment before manual posting.
