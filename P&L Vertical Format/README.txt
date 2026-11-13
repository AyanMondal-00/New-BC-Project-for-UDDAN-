AIR IQ — P&L VERTICAL FORMAT (CLICKABLE T-SHAPE)

New objects only. Does not replace or modify existing Balance Sheet 50461.

OBJECTS
  Table 50462: AIRIQ P&L Vertical
  Page 50462: P&L Vertical Format
  Control Add-in: AIRIQ P&L Tree AddIn
  JS/CSS: PLControlAddIn/main.js, startup.js, styles.css

INSTALLATION
  1. Back up your AL extension project.
  2. Copy the two .al object files, the controladdin .al file, and the
     PLControlAddIn folder into the project (retain relative paths).
  3. Confirm Table/Page IDs 50462 are free in your extension.
  4. Download symbols, compile, and publish to a sandbox.
  5. In BC, Alt+Q > P&L Vertical Format.

FUNCTIONAL DESIGN
  - Left: expenses, right: income; chart-of-accounts Begin-Total / End-Total tree.
  - Expand/Collapse and Expand all/Collapse all in JavaScript (no page refresh).
  - Clicking a Posting account opens G/L Entries filtered by selected start/end.
  - Default period: starting date of latest New Fiscal Year Accounting Period
    at/before WorkDate, ending WorkDate. User can choose Custom Date Range.
  - If no fiscal-year accounting period exists, a calendar-year fallback is
    shown with a warning (not silently declared to be the actual FY).
  - Posting-account Net Change is the amount source. Group totals sum children;
    End-Total amounts are never added a second time.
  - Zero-balance Posting accounts remain visible.
  - Income credit balances display positive; expense debit balances positive.
    Reversals/negative postings remain signed (not absolute-valued).
  - Net Profit (Income - Expenses) adds to expenses side when positive;
    Net Loss adds to income side when negative. Grand totals then match.
  - Parent COA hierarchy takes precedence over leaf category, and account
    category conflicts appear in View Validation Issues.

IMPORTANT ACCOUNTING NOTES
  - The display is based on the live BC G/L Accounts and G/L Entries; the
    Excel file was used for validating COA structure, not importing amounts.
  - For the supplied COA, root 30000 = Income and 40000 = Expenses.
  - Chart item 40475 Rounding Off is category Income under Expenses hierarchy;
    it will be shown on expenses side and flagged for review.
  - The grand totals can still be equal even when unclassified accounts are
    excluded; review validation issues and reconcile P&L against trial balance.
  - If you use Dimensions, Closing Entries, additional COA roots, or special
    posting filters, test these behaviors against BC financial reports.

VERIFICATION STATUS
  - JS syntax checked with Node.js.
  - COA root and category labels inspected from supplied Excel.
  - No Microsoft AL compiler or Business Central sandbox is available in this
    runtime. Compile/publish and accounting reconciliation are NOT claimed.

GROSS PROFIT ADDITION (OPTION B)
  - Direct Income = group 30010 + Sales Accounts group 30101.
  - Direct Expenses = group 40010 + Purchase Accounts group 40301.
  - Gross Profit/(Loss) = Direct Income - Direct Expenses.
  - Gross Profit shown on expense side, Gross Loss on income side.
  - Gross result is a PRESENTATION subtotal only; it does not affect Net Profit
    or grand totals (avoids double counting).
  - Expanded root tree: direct trading groups, gross result, then remaining groups.
  - Collapsed root tree: gross result stays visible after root row.
  - Summary includes Direct Income, Direct Expenses, Gross Profit/(Loss).
  - Validate group numbers if Chart of Accounts is restructured.
  - Requires AL compilation and BC sandbox testing.
