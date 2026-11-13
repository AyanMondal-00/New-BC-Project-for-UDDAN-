# AIRIQ Financial Statements — Phase 1 (safe starter)

Inspected source: `BC new project AIR IQ(1).zip`, 175 AL files, application 28/runtime 17, object IDs permitted 50300–50749. Existing financial pages 50461 (Vertical Balance Sheet) and 50462 (P&L Vertical Format) are not modified. Object numbers 50730–50732 are unused in the uploaded source for each corresponding object type.

## Delivered
- Table 50730 AIRIQ FS Mapping (one posting G/L account per mapping row, note number, heading, reverse sign, finance approval)
- Table 50731 AIRIQ FS Statement (statement code definitions)
- Table 50732 AIRIQ FS Preview Buffer (temporary)
- Page 50730 AIRIQ FS Mapping List
- Page 50731 AIRIQ FS Statements
- Page 50732 AIRIQ FS G/L Preview
- Codeunit 50730 AIRIQ FS GL Calculation

## How to test in BC sandbox
1. Copy FinancialStatements folder under your AL project and compile/publish in sandbox.
2. Search **AIRIQ Financial Statement Definitions**, create `BS` and `PL` as appropriate.
3. Search **AIRIQ Financial Statement Mapping**, enter note number, financial heading and one verified *Posting* G/L Account number per line. Use additional mapping rows for additional accounts. Set Reverse Sign where credits should display positive. Mark Finance Approved only after finance validates.
4. Search **AIRIQ Financial Statement G/L Mapping Preview**. Default as-at date is 31/03/2026 and statement code `BS`. Recalculate and drill into G/L Entries.

## Critical financial controls / scope boundaries
- This is an **account-to-note G/L preview**, NOT a fully implemented restated BS, notes 3–23, audit-ready disclosure, or 13-sheet Excel export. No hardcoded candidate mappings are inserted.
- G/L amount = sum of G/L Entries with Posting Date <= selected as-at date, with optional display sign reversal. **P&L flow periods, closing entries, balance-sheet retained earnings and ledger reconciliations require separate logic.**
- No restatement postings or adjustments are assumed. No double counting prevention yet: do not map same account to multiple financial headings unless Finance explicitly approves allocation methodology.
- Notes 3/3.1/3.2 and 4–23 require specific asset/customer/vendor/bank/lease/loan/equity supporting schedules. Historical opening costs and classification must be reconciled, not guessed.
- This package has not been compiled against the customer's BC symbol packages; use VS Code AL compile against sandbox. Resolve symbol/version warnings before production.
- No old AL files changed.
