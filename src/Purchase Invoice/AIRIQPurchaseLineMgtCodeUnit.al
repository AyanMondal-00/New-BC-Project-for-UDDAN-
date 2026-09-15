codeunit 50339 "AIRIQ Purchase Line Mgt"
{
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeCheckLineAmount', '', false, false)]
    local procedure OnBeforeCheckLineAmount(
        var PurchaseLine: Record "Purchase Line";
        MaxLineAmount: Decimal;
        var IsHandled: Boolean;
        CalledByFieldNo: Integer)
    begin
        if PurchaseLine."Sample Other Charges" <> 0 then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnValidateLineAmountBeforeValidateLineDiscountAmount', '', false, false)]
    local procedure OnValidateLineAmountBeforeValidateLineDiscountAmount(
        var PurchLine: Record "Purchase Line";
        Currency: Record Currency;
        var IsHandled: Boolean;
        CurrFieldNo: Integer)
    begin
        if PurchLine."Sample Other Charges" <> 0 then
            IsHandled := true;
    end;
}