# AIRIQ Native Row-Selection Bulk Actions (add-only package)

Source reviewed: `BC new project AIR IQ(20261123-072228).zip` (23 Nov 2026).

## Scope and behavior

This package adds **four pageextension AL files**. It does not change any original table, page, or codeunit source file. Existing `Select` checkbox columns remain present and editable; the new processing buttons operate on the rows highlighted in the BC list with Ctrl+A or Ctrl+Click, independently of checkbox values.

Page extensions *hide* the existing checkbox/current-row processing buttons (`modify(ActionName) { Visible = false; }`) and add same-caption replacements. Thus the visible UI changes even though original files are untouched.

| New AL file | Original page | Replaced actions |
|---|---|---|
| SamplePurchase/SamplePurchaseBulk.PageExt.al | src/Pages/SamplePurchaseList.Page.al | Create Items; Create Purchase Invoice; Create & Post Purchase Invoices |
| ThirdPartyPurchase/ThirdPartyPurchaseBulk.PageExt.al | src/Third Party Sample Purchase/ThirdPartySamplePurchaseList.Page.al | Create Items; Create Purchase Invoice; Create & Post Purchase Invoices |
| InventoryConsumption/InventoryConsumptionBulk.PageExt.al | Excel Import/Inventory Consumtion/InventoryConsumption.page.al | Create Purchase Return Order |
| SalesReturn/SalesReturnBulk.PageExt.al | src/Sales Return/SalesReturnList.Page.al | Refresh Posted Invoice Values |

Existing native selection support already present in original pages:
- `src/Own Sales/Own Sales Pages/NormalSalesList.Page.al`: Create Own Sales Invoice
- `src/Pages/Sales/API Sales/APISalesFormatList.Page.al`: Create Sales Invoice
- `src/Pages/Sales/Third Party Sales/ThirdPartySupplierSalesList.Page.al`: Create Sales Invoice
- `Sample Purchase Cose Revision Report/AIRIQCostRevisionStatement.Page.al`: Delete Selected Revision

Other custom list pages have import, diagnostic, navigation, report, checkbox maintenance or no per-row processing action, therefore **no universal all-tables wrapper is meaningful**. This package does not add a generic processing button to every table.

## Install

1. Extract files directly into your existing AL workspace, e.g. `src/AIRIQ Native Bulk Actions/` while retaining subfolders. Do **not** replace your existing source files.
2. Run **AL: Download Symbols**, compile with **AL: Package**, and resolve any version-specific diagnostics before deploying.
3. Test on sandbox with 1 selected row, Ctrl+Click for sparse selection, and Ctrl+A in focused list grid. Confirm the selected record count and original validations.
4. Test already processed, invalid, and mixed valid/invalid records. Posting may be irreversible; use only test data first.

## Technical limitations

- `CurrPage.SetSelectionFilter(Selected)` applies to the *page* context; it cannot be called from an unrelated generic codeunit to read the list's current highlighted rows.
- A pageextension cannot transparently replace the original action `OnAction` body across all pages. The reliable add-only approach here is to hide the original action and add a replacement action.
- Posting/calculation behavior comes from existing codeunits. No codeunit business logic has been altered.
- This package was checked against the uploaded AL source definitions, but **was not compiled against Microsoft symbols or published to a BC sandbox in this environment**.
- Object IDs 50733–50736 were not occupied in the supplied source; check app.json ID range and other installed apps before compile.
