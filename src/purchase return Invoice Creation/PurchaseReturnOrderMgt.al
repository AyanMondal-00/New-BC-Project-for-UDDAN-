codeunit 50422 "Purchase Return Order Mgt."
{
    procedure CreatePurchaseReturnOrders(
        var SelectedConsumption: Record "Inventory Consumption")
    var
        ProcessRec: Record "Inventory Consumption";
        CreatedCount: Integer;
        SkippedCount: Integer;
        ErrorCount: Integer;
        SummaryMsg: Text;
    begin
        ProcessRec.Copy(SelectedConsumption);

        if ProcessRec.IsEmpty() then begin
            Message('No Inventory Consumption records selected.');
            exit;
        end;

        if ProcessRec.FindSet(true) then
            repeat
                if ProcessRec."Purchase Return Order Created" then
                    SkippedCount += 1
                else begin
                    if CreateSinglePurchaseReturn(ProcessRec) then
                        CreatedCount += 1
                    else
                        ErrorCount += 1;
                end;
            until ProcessRec.Next() = 0;

        SummaryMsg :=
            'Purchase Return Order Creation Summary:\';

        if CreatedCount > 0 then
            SummaryMsg +=
                StrSubstNo(
                    '\- Success: %1 Purchase Return Order(s) created.',
                    CreatedCount);

        if SkippedCount > 0 then
            SummaryMsg +=
                StrSubstNo(
                    '\- Skipped: %1 record(s) already had a Purchase Return Order.',
                    SkippedCount);

        if ErrorCount > 0 then
            SummaryMsg +=
                StrSubstNo(
                    '\- Failed: %1 record(s) could not be processed.',
                    ErrorCount);

        Message(SummaryMsg);
    end;

    local procedure CreateSinglePurchaseReturn(
        var Consumption: Record "Inventory Consumption"): Boolean
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        UnitCost: Decimal;
    begin
        // -------------------------
        // Validate Supplier
        // -------------------------
        if Consumption."Supplier Name" = '' then
            Error(
                'Supplier Name is missing for Serial No. %1.',
                Consumption."Serial No.");

        Vendor.Reset();
        Vendor.SetRange(Name, Consumption."Supplier Name");

        if not Vendor.FindFirst() then
            Error(
                'Vendor "%1" was not found for Serial No. %2.',
                Consumption."Supplier Name",
                Consumption."Serial No.");

        // -------------------------
        // Validate PNR
        // -------------------------
        if Consumption.PNR = '' then
            Error(
                'PNR is missing for Serial No. %1.',
                Consumption."Serial No.");

        // -------------------------
        // Find Item using PNR
        // -------------------------
        Item.Reset();
        Item.SetRange(Description, Consumption.PNR);

        if not Item.FindFirst() then
            Error(
                'Item was not found for PNR "%1" (Serial No. %2).',
                Consumption.PNR,
                Consumption."Serial No.");

        // -------------------------
        // Validate Pax
        // -------------------------
        if Consumption.Pax <= 0 then
            Error(
                'Pax must be greater than zero for Serial No. %1.',
                Consumption."Serial No.");

        // -------------------------
        // Calculate Unit Cost
        // Base Fare / Pax
        // -------------------------
        UnitCost :=
            Consumption."Base Fare" / Consumption.Pax;

        // -------------------------
        // Purchase Return Header
        // -------------------------
        PurchHeader.Init();

        PurchHeader."Document Type" :=
            PurchHeader."Document Type"::"Return Order";

        PurchHeader.Validate(
            "Buy-from Vendor No.",
            Vendor."No.");

        PurchHeader.Validate(
            "Document Date",
            DT2Date(Consumption.Date));

        if Consumption."Invoice Number" <> '' then
            PurchHeader.Validate(
                "Vendor Cr. Memo No.",
                Consumption."Invoice Number");

        PurchHeader.Insert(true);

        // -------------------------
        // Purchase Return Line
        // -------------------------
        PurchLine.Init();

        PurchLine."Document Type" :=
            PurchHeader."Document Type";

        PurchLine."Document No." :=
            PurchHeader."No.";

        PurchLine."Line No." := 10000;

        PurchLine.Insert(true);

        // Type = Item
        PurchLine.Validate(
            Type,
            PurchLine.Type::Item);

        // PNR -> Item
        PurchLine.Validate(
            "No.",
            Item."No.");

        // PNR -> Description
        PurchLine.Description :=
            Consumption.PNR;

        // Pax -> Quantity
        PurchLine.Validate(
            Quantity,
            Consumption.Pax);

        // Base Fare / Pax -> Direct Unit Cost
        PurchLine.Validate(
            "Direct Unit Cost",
            UnitCost);

        // Taxable Basis -> GST Assessable Value
       

        PurchLine.Modify(true);

        // -------------------------
        // Mark Source Record
        // -------------------------
        Consumption."Purchase Return Order Created" := true;
        Consumption.Select := false;
        Consumption.Modify(true);

        exit(true);
    end;
}