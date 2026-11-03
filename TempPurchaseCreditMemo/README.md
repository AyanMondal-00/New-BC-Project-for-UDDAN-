# AIRIQ Purchase Return → Purchase Credit Memo

Creates one standard, **unposted** Purchase Credit Memo from the current row on page 50312. It does not post, create Items/Vendors, alter source financial values, or change existing invoice/sales code. All module files are in this directory; app.json is unchanged.

## Inspected architecture and version

- Table 50302 and page 50312 `Purchase Return`, its Excel importer and table 50359 serial counter. Return financial values are imported independently: neither the table nor importer defines a return amount formula.
- Codeunit 50336 `Sample Purchase Invoice Mngt`: exact Vendor Name matching after Supplier ID, PNR in Item Description, quantity from Pax, unit cost from Rate, location SILIGURI. Its Other Charges branch calculates **invoice** Base Fare + Other Charges; this is not evidence of a return formula. Purchase Return has Airline ID, not Supplier ID, so Airline ID is preserved as metadata rather than assumed to be a Vendor No.
- Codeunit 50322 `Sample Purchase Item Mngt`: PNR item matching, PAX UOM, RESALE/RETAIL posting groups, GST group S1800 and HSN/SAC 998551. This module uses existing Items and their configuration; it never hardcodes tax percentages or creates GST setup.
- Purchase Line extensions 50323/50421 and posted invoice line extension 50340; invoice amount subscribers 50339; existing invoice-number counter 50338; Inventory Consumption return order flow 50422 (a different source/formula); commission posting subscriber 50455.
- No existing Purchase Header or posted credit memo custom fields overlapped this module. Existing line fields are reused. The existing commission subscriber remains active and updates commission from posted credit memo Line Amount. No new commission or GST calculation was added.
- Installed packages: application 28.5, Base Application 28.5.54976.57206, Business Foundation 28.5.54976.56550, India GST 28.5.54976.57206, runtime 17.0. Event signatures and page names were read from their SymbolReference.json files.

## Objects and files

All paths below are relative to `TempPurchaseCreditMemo/`. Object IDs are independent across AL object types.

| File | Object type / ID | Object name |
|---|---|---|
| AIRIQPurchaseReturnCreditMemoCU.al | Codeunit 50700 | AIRIQ Return Credit Memo |
| AIRIQPurchaseCreditMemoNoSeriesCU.al | Codeunit 50701 | AIRIQ AQPR No. Mgt |
| AIRIQPurchaseCreditMemoPostingSubscriber.al | Codeunit 50702 | AIRIQ Return Posting |
| AIRIQAQPRImplementation.al | EnumExtension 50700 | AIRIQ AQPR Implementation |
| AIRIQAQPRReservation.al | Table 50700 | AIRIQ AQPR Reservation |
| AIRIQPurchaseReturnTrackingExt.al | TableExtension 50704 | AIRIQ Return Tracking |
| AIRIQPurchCrMemoHeaderExt.al | TableExtension 50700 | AIRIQ Return Purch Header |
| AIRIQPurchCrMemoLineExt.al | TableExtension 50701 | AIRIQ Return Purch Line |
| AIRIQPostedPurchCrMemoHdrExt.al | TableExtension 50702 | AIRIQ Return Posted Header |
| AIRIQPostedPurchCrMemoLineExt.al | TableExtension 50703 | AIRIQ Return Posted Line |
| AIRIQPurchaseReturnPageExt.al | PageExtension 50704 | AIRIQ Return Create Memo |
| AIRIQPurchCrMemoPageExt.al | PageExtension 50700 | AIRIQ Return Cr Memo Page |
| AIRIQPurchCrMemoSubformExt.al | PageExtension 50702 | AIRIQ Return Memo Subform |
| AIRIQPostedPurchCrMemoPageExt.al | PageExtension 50701 | AIRIQ Posted Return Memo Page |
| AIRIQPostedPurchCrMemoLinePageExt.al | PageExtension 50703 | AIRIQ Posted Return Lines |
| AIRIQPurchaseReturnPermissions.al | PermissionSet 50700 | AIRIQ RETURN MEMO |

Supporting files: `README.md`, `Validate-Module.js` (repeatable structural audit), `validation-report.json` (audit output), `compile-results.json` (compiler diagnostics), `AIRIQ-validation.app` (compiled whole extension; **not** just this module).

## Field mapping and IDs

Header fields are added identically to Purchase Header (38) and Purch. Cr. Memo Hdr. (124):

| Source | Destination | Field ID / type |
|---|---|---|
| Airline | Unique exact Vendor.Name → validated Buy-from Vendor No. | Standard |
| Purchase Date | Document Date via DT2Date; original timestamp retained | Standard + below |
| Serial No. | AIRIQ Return Serial No. | 50700 Integer, indexed |
| Voucher Number | AIRIQ Voucher Number | 50701 Code[50] |
| Entry Date | AIRIQ Entry Date | 50702 DateTime |
| Purchase Date | AIRIQ Purchase Date | 50703 DateTime |
| Reference | AIRIQ Reference | 50704 Text[100] |
| Narration | AIRIQ Narration | 50705 Text[250] |
| Airline ID | AIRIQ Airline ID | 50706 Code[20] |
| AQPR generated number | Vendor Cr. Memo No. | Standard; generated value fits Code[20] |

Line fields map to Purchase Line (39) and Purch. Cr. Memo Line (125):

| Source | Destination | ID / type | Reuse |
|---|---|---|---|
| PNR | Unique Item.Description match → validated No.; AIRIQ PNR | Standard + 50700 Text[10] | New metadata |
| Sector | Sample Sector | 50329 Text[200] | Existing on 39; added on 125 |
| Country | AIRIQ Country | 50701 Text[50] | New |
| Type | Sample Flight Type | 50330 Text[50] | Existing on 39; added on 125 |
| Pax | validated Quantity; AIRIQ Pax | Standard + 50702 Integer | New metadata |
| Base Fare | Sample Base Fare | 50332 Decimal | Existing on 39; added on 125 |
| Others | Sample Other Charges | 50333 Decimal | Existing on 39; added on 125 |
| Rate | validated Direct Unit Cost; AIRIQ Rate | Standard + 50703 Decimal | New metadata |
| Discount | AIRIQ Discount | 50704 Decimal | New |
| XXLN Charges | AIRIQ XXLN Charges | 50705 Decimal | New |
| Amount | reconciled standard Line Amount; AIRIQ Return Amount | Standard + 50706 Decimal | New metadata |
| Travel Date | Sample Travel Date | 50326 DateTime | Existing on 39; added on 125 |
| Flight No. | AIRIQ Flight No. | 50707 Code[30] | New |
| Departure Time | AIRIQ Departure Time | 50708 Time | New |
| Arrival Time | AIRIQ Arrival Time | 50709 Time | New |
| Cost Revision | AIRIQ Cost Revision | 50710 Option Yes,No | New; source ordinal order preserved |

Existing Purchase Line Sample Purchase Date, Sample Entry Date and Sample Airline are also populated; their information is retained in posted header metadata. Source tracking fields on table 50302: 50700 `AIRIQ Credit Memo Created` Boolean, 50701 `AIRIQ Credit Memo No.` Code[20], 50702 `AIRIQ Vendor Cr. Memo No.` Code[20], 50703 `AIRIQ Posted Cr. Memo No.` Code[20]. Tracking and displayed source metadata are read-only on the module pages.

## Financial policy and unresolved business rules

There is **no verified Purchase Return formula** combining Rate, Amount, Base Fare, Discount and XXLN Charges. This module follows the ordinary AIRIQ invoice path (Quantity = Pax, Direct Unit Cost = Rate) and requires the resulting standard Line Amount to equal source Amount rounded using the document currency amount precision. Positive Pax and Amount and nonnegative Rate are required. Discount, Others and XXLN Charges are retained as source metadata; they are not independently added/subtracted. BC line and invoice discounts are disabled for this source line to avoid unintended Vendor price/discount adjustments.

If the amounts do not reconcile, creation fails and rolls back. It does not manufacture a unit cost from Amount/Pax, copy the unrelated Inventory Consumption Base Fare/Pax formula, or manually assign calculated Amount/GST fields. Business approval of a different return formula requires a subsequent explicit change. This guard means returns with independently calculated refunds may require that clarification before automation can create them.

Currency, Prices Including VAT and other purchase defaults follow the resolved Vendor/standard BC setup because the source has no currency/tax-inclusion fields. Document Date uses Purchase Date; Posting Date remains the standard work date. Review these defaults before posting. Location SILIGURI follows the existing invoice convention. Standard validation raises native setup/GST errors; tax rates and tax-engine calculation remain standard. Full GST/posting validation still occurs during manual BC posting/preview; creation does not claim that every posting condition is satisfied.

The existing 50339 subscribers bypass some Line Amount validation whenever Sample Other Charges is nonzero, including on credit memos. Creation validates standard financial fields **before** copying that metadata and never manually validates Line Amount afterward. Existing subscribers are unchanged; review subsequent manual edits and use posting preview.

## AQPR numbering

Lazy, idempotent setup on the first successful creation inserts No. Series `AIRIQ-AQPR` and a single line with starting number `AQPR000001`, increment 1, blank ending/warning/starting date, and implementation `AIRIQ AQPR`. Failed creation rolls back this setup as well. An existing series is never overwritten; incompatible setup produces a validation error. It is visible through standard No. Series administration.

The BC 28 `No. Series` codeunit `GetNextNo(Code[20], Date)` dispatches through enum 397 `No. Series Implementation` to the supported interface `No. Series - Single`. The custom implementation performs decimal character carry to grow the numeric suffix, independent of fixed-width standard increment behavior. It implements GetNextNo, PeekNextNo, GetLastNoUsed and MayProduceGaps. Persistent single-series allocation is supported; temporary/batch line allocation explicitly errors.

Expected transitions: `AQPR000001`, `AQPR000002`, `AQPR999999` → `AQPR1000000`. There is no configured business maximum. `AQPR9999999999999999` is the last representable value; the next request raises an explicit Code[20] technical-limit error. No truncation or wraparound occurs.

Allocation locks and rereads the persisted No. Series Line, checks the permanent reservation table and both standard purchase header tables, and inserts a primary-key reservation in the same transaction. The reservation remains after draft deletion/posting and is never automatically purged. Existing occupied numbers are skipped. Resetting the series does not permit reserved numbers to be reused. Do not manually delete reservations, alter used series state, use this series for unrelated modules, or generate AQPR values outside this allocator. Standard concurrent update/deadlock errors require retry; they cannot produce two successful allocations of the same number.

The standard Purchase Credit Memo No. is generated independently using Purchases & Payables Setup. AQPR populates **Vendor Cr. Memo No.**, not Voucher Number or the standard document No.

## Duplicate protection, transactions and posting

Creation locks the Purchase Return table before rereading the selected row. It checks posted and unposted headers by the indexed source serial, checks Vendor Cr. Memo No. when a link exists, and checks persistent source links/flags. Deleted drafts retain their source link and reservation; automatic recreation is intentionally blocked. Do not clear tracking fields to retry a failed posting: the original draft remains available.

All writes (series, reservation, header, line, tracking) occur in one transaction. There is no COMMIT, TryFunction write swallowing or automatic posting; CommitBehavior::Error rejects explicit commits within creation. A validation error rolls back the work. The action operates on the **current row**, not a multi-selection batch, saves the row, calls the codeunit, reports the document numbers, then opens standard page 52.

Verified codeunit 90 `Purch.-Post` subscribers:

- `OnBeforePurchCrMemoHeaderInsert(var PurchCrMemoHdr, var PurchHeader, CommitIsSupressed)` copies only custom header fields.
- `OnBeforePurchCrMemoLineInsert(var PurchCrMemoLine, var PurchCrMemoHdr, var PurchLine, CommitIsSupressed, var xPurchaseLine)` copies only custom/reused line fields before insertion.
- `OnAfterPurchCrMemoHeaderInsert(var PurchCrMemoHdr, var PurchHeader, CommitIsSupressed, PreviewMode)` records the posted number; preview is excluded. Standard posting transaction rollback also rolls back tracking on failure.
- `OnBeforePostPurchaseDoc(var PurchaseHeader, PreviewMode, CommitIsSupressed, var HideProgressWindow, var ItemJnlPostLine, var IsHandled)` rejects copied source links, changed AQPR references and an already posted source. It leaves standard posting decisions untouched.

BC transfers the standard Vendor Cr. Memo No. itself. The module does not replace that standard transfer. Posted page 140 `Posted Purchase Credit Memo` and subform 141 `Posted Purch. Cr. Memo Subform` display metadata. Source tracking preserves both original draft No. and posted No.

## Setup and deployment

1. Publish/synchronize the full extension in a BC **sandbox** and validate it there before production deployment. Existing workspace modifications are included in the compiled app; review them separately before publishing that artifact.
2. Assign `AIRIQ RETURN MEMO` together with normal AIRIQ Purchase Return and BC purchasing/posting permissions. This permission set supplements, rather than replaces, normal purchase, vendor, item, GST and posting permissions.
3. Configure Credit Memo Nos. and Posted Credit Memo Nos. in Purchases & Payables Setup and standard posting accounts. Ensure each Airline matches exactly one Vendor Name, and each PNR exactly one existing Item Description.
4. Confirm SILIGURI location, item UOM/posting groups, inventory posting setup where needed, Vendor posting group, General Posting Setup Purchase Credit Memo Account, GST group, HSN/SAC, GST registrations and tax-engine configuration. Existing item creation defaults are reused, not installed by this module.
5. No manual AQPR setup is required. If AIRIQ-AQPR already exists, review its compatibility; the module will not overwrite it. No existing business data is migrated/backfilled.

## Sandbox acceptance tests (not executed in this environment)

1. Happy path: existing Vendor and PNR Item, positive Pax and Rate, Amount = Pax × Rate, Purchase Date filled. Create from page 50312. Confirm standard draft No., AQPR000001 Vendor Cr. Memo No., correct quantities/cost, source metadata, standard GST setup, and no posting.
2. Repeat from the same source before posting: error names the existing draft. Post manually, verify all header/line metadata and AQPR on pages 140/141, then retry: error names the posted document.
3. Two sessions create the same source simultaneously: exactly one draft and source link. Two different sources: distinct AQPR numbers; retry any standard concurrency error.
4. Delete a created draft in the sandbox: original source stays blocked and its AQPR reservation remains. A new source must not reuse the deleted draft's AQPR.
5. In an isolated disposable test company, seed Last No. Used as AQPR999998: next values must be AQPR999999 and AQPR1000000. Test the 16-digit boundary and exhaustion error. Never change a live company's series for testing.
6. Missing/ambiguous Vendor or PNR Item, blank Airline/PNR/Purchase Date, nonpositive quantity/amount, negative rate, amount mismatch, missing posting account, missing item GST/HSN/SAC, missing location setup and invalid existing AQPR setup: readable error and no partial header, line, tracking or reservation.
7. Validate GST with real domestic/interstate/international cases, correct Vendor currency and Prices Including VAT defaults. Use posting preview and compare to the existing purchase flow. Confirm preview does not mark the source posted or consume a new AQPR.
8. Force a standard posting failure: draft remains, source is not marked posted. Correct setup and post the original draft. Confirm existing commission integration still runs once.
9. Copy a source-linked draft to another document: posting guard rejects the mismatched source document No. Editing its Vendor Cr. Memo No. must also prevent posting.

## Build and offline validation

Executed full-project compilation with AL Compiler 18.1.43.24897 and the existing `.alpackages`:

```powershell
& 'C:/Users/P.C/.vscode/extensions/ms-dynamics-smb.al-18.1.2842859/bin/alc.exe' /project:. /packagecachepath:.alpackages /out:TempPurchaseCreditMemo/AIRIQ-validation.app /errorlog:TempPurchaseCreditMemo/compile-results.json
node TempPurchaseCreditMemo/Validate-Module.js
```

Compilation passed with **zero errors and zero module warnings**. Three existing AL1025 warnings concern root Info.txt and two .snapshots license files. Structural audit scanned 139 AL files: no duplicate object IDs or table field IDs/names. Symbols resolved all referenced fields, tables, pages, interface methods and event signatures. No BC service/runtime is connected here: actual posting, GST results, permissions, UI and concurrency acceptance tests remain to be performed in the sandbox.
