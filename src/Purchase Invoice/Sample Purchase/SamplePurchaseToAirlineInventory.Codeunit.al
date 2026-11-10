codeunit 50321 "Sample Purchase Inventory Sync"
{
    procedure SyncAllSamplePurchases()
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        SamplePurchase.Reset();

        if SamplePurchase.FindSet() then
            repeat
                SyncSamplePurchase(SamplePurchase);
            until SamplePurchase.Next() = 0;
    end;

    local procedure SyncSamplePurchase(SamplePurchase: Record "Sample Purchase")
    var
        AirlineInventory: Record "Airline Inventory Payment Due";
    begin
        AirlineInventory.Reset();
        AirlineInventory.SetRange(PNR, SamplePurchase.PNR);

        if AirlineInventory.FindFirst() then begin
            UpdateTargetRecord(AirlineInventory, SamplePurchase);
            AirlineInventory.Modify(true);
        end else begin
            AirlineInventory.Init();

            AirlineInventory."Purchase Date" := SamplePurchase."Purchase Date";
            AirlineInventory."Travel Date" := SamplePurchase."Travel Date";
            AirlineInventory.Sector := SamplePurchase.Sector;
            AirlineInventory.PNR := SamplePurchase.PNR;
            AirlineInventory."PAX Count" := SamplePurchase."Total Pax";
            AirlineInventory."Per PAX Rate" := SamplePurchase.Rate;
            AirlineInventory.Airline := SamplePurchase.Airline;
            AirlineInventory."Agency ID" := SamplePurchase."Supplier ID";
            AirlineInventory.Insert(true);
        end;
    end;

    local procedure UpdateTargetRecord(
        var AirlineInventory: Record "Airline Inventory Payment Due";
        SamplePurchase: Record "Sample Purchase")
    begin
        AirlineInventory."Purchase Date" := SamplePurchase."Purchase Date";
        AirlineInventory."Travel Date" := SamplePurchase."Travel Date";
        AirlineInventory.Sector := SamplePurchase.Sector;
        AirlineInventory.PNR := SamplePurchase.PNR;
        AirlineInventory."PAX Count" := SamplePurchase."Total Pax";
        AirlineInventory."Per PAX Rate" := SamplePurchase.Rate;
        AirlineInventory.Airline := SamplePurchase.Airline;
        AirlineInventory."Agency ID" := SamplePurchase."Supplier ID";

        AirlineInventory."Total Value" :=
            AirlineInventory."PAX Count" * AirlineInventory."Per PAX Rate";

        AirlineInventory."Balance Due" :=
            AirlineInventory."Total Value" - AirlineInventory."Amount Paid";

        UpdateRemark(AirlineInventory);
    end;

    local procedure UpdateRemark(
        var AirlineInventory: Record "Airline Inventory Payment Due")
    begin
        if AirlineInventory."Balance Due" = 0 then
            AirlineInventory.Remark := 'NO DUE'
        else
            if AirlineInventory."Balance Due" > 0 then
                AirlineInventory.Remark := 'PAYMENT PENDING'
            else
                AirlineInventory.Remark := 'EXCESS PAYMENT';
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Sample Purchase",
        'OnAfterInsertEvent',
        '',
        false,
        false)]
    local procedure SamplePurchaseOnAfterInsert(
        var Rec: Record "Sample Purchase";
        RunTrigger: Boolean)
    begin
        SyncSamplePurchase(Rec);
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Sample Purchase",
        'OnAfterModifyEvent',
        '',
        false,
        false)]
    local procedure SamplePurchaseOnAfterModify(
        var Rec: Record "Sample Purchase";
        var xRec: Record "Sample Purchase";
        RunTrigger: Boolean)
    begin
        SyncSamplePurchase(Rec);
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Sample Purchase",
        'OnAfterDeleteEvent',
        '',
        false,
        false)]
    local procedure SamplePurchaseOnAfterDelete(
        var Rec: Record "Sample Purchase";
        RunTrigger: Boolean)
    var
        AirlineInventory: Record "Airline Inventory Payment Due";
    begin
        AirlineInventory.Reset();
        AirlineInventory.SetRange(PNR, Rec.PNR);

        if AirlineInventory.FindFirst() then
            AirlineInventory.Delete(true);
    end;
}