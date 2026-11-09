codeunit 50491 "AIRIQ Own Sales Fare Sync"
{
    [EventSubscriber(ObjectType::Table, Database::"Sample Purchase", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnSamplePurchaseInserted(var Rec: Record "Sample Purchase"; RunTrigger: Boolean)
    begin
        SyncByPNR(Rec.PNR);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sample Purchase", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnSamplePurchaseModified(var Rec: Record "Sample Purchase"; var xRec: Record "Sample Purchase"; RunTrigger: Boolean)
    begin
        if (Rec.PNR <> xRec.PNR) and (xRec.PNR <> '') then
            SyncByPNR(xRec.PNR);
        SyncByPNR(Rec.PNR);
    end;

    local procedure SyncByPNR(PNRValue: Text[10])
    var
        OwnSales: Record "Normal Sales";
    begin
        if PNRValue = '' then
            exit;
        OwnSales.SetRange(PNR, PNRValue);
        OwnSales.SetRange("API Calculation", true);
        if OwnSales.FindSet(true) then
            repeat
                OwnSales.CalculateAmounts();
                OwnSales.Modify(false);
            until OwnSales.Next() = 0;
    end;
}
