# Proposal only ? do not apply yet

Codeunit 50715 "AIRIQ SR Create Memo", local procedure AddLine, existing lines 155?158:

```al
Line.Validate(FlightType, Source.Type);
Line.Validate(Quantity, Qty);
Line.BaseFare := Format(Source."Base Fare");
Line."AIRIQ GST Base Fare" := Source."Base Fare"; // proposed new assignment
Line.Validate("Unit Price", Source."Base Fare");
```

Existing Line.Modify(true) at line 180 persists the value before CallTaxEngineOnSalesLine at line 181. Keep both.

Per-passenger meaning is NOT confirmed: existing code uses Base Fare as Unit Price, quantity 1 per passenger or PAX in the fallback. This suggests per-passenger fare but does not establish source/import semantics. Reconcile real source rows before approval.

Tableextension 50425 field 50433 is Decimal; BaseFare field 50432 is text. FlightType field 50426 OnValidate only supports Invoice. No trigger extension is needed for 50715 creation because it explicitly recalculates at the end. Manual Credit Memo FlightType/fare edits need a separately approved recalculation design.
