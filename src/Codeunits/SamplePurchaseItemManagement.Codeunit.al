codeunit 50322 "Sample Purchase Item Mngt"
{
    procedure CreateItems(var SelectedSamplePurchase: Record "Sample Purchase")
    var
        ProcessRec: Record "Sample Purchase";
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
        CreatedCount: Integer;
        AlreadyExistCount: Integer;
        SkippedCount: Integer;
        SummaryMsg: Text;
    begin
        ProcessRec.Copy(SelectedSamplePurchase);

        if (ProcessRec.Count = 1) and (not ProcessRec."Select") then begin
            ProcessRec.Reset();
            ProcessRec.SetRange("Select", true);
            if ProcessRec.IsEmpty() then
                ProcessRec.Copy(SelectedSamplePurchase);
        end;

        if ProcessRec.IsEmpty() then begin
            Message('No Sample Purchase records found to process.');
            exit;
        end;

        if ProcessRec.FindSet() then
            repeat
                if ProcessRec.PNR <> '' then begin
                    Item.Reset();
                    Item.SetRange(Description, ProcessRec.PNR);

                    if not Item.FindFirst() then begin
                        Item.Init();
                        Item."No." := NoSeries.GetNextNo('ITEM');
                        Item.Description := ProcessRec.PNR;
                        Item.Validate(Type, Item.Type::"Non-Inventory");
                        Item.Validate("Gen. Prod. Posting Group", 'RETAIL');
                        Item.Insert(true);

                        Item.Validate("Base Unit of Measure", 'PAX');
                        Item.Modify(true);

                        ProcessRec."Item Created" := true;
                        ProcessRec.Modify(true);

                        CreatedCount += 1;
                    end else begin
                        if not ProcessRec."Item Created" then begin
                            ProcessRec."Item Created" := true;
                            ProcessRec.Modify(true);
                        end;

                        AlreadyExistCount += 1;
                    end;
                end else
                    SkippedCount += 1;
            until ProcessRec.Next() = 0;

        if (CreatedCount > 0) and (AlreadyExistCount = 0) and (SkippedCount = 0) then
            Message('Success! %1 new Item(s) created successfully.', CreatedCount)
        else if (CreatedCount = 0) and (AlreadyExistCount > 0) and (SkippedCount = 0) then
            Message('Already Exists! All %1 selected item(s) are already created.', AlreadyExistCount)
        else if (CreatedCount = 0) and (AlreadyExistCount = 0) and (SkippedCount > 0) then
            Message('Not Created! %1 selected record(s) were skipped because PNR was missing.', SkippedCount)
        else begin
            SummaryMsg := 'Item Creation Summary:\';
            if CreatedCount > 0 then
                SummaryMsg += StrSubstNo('\- Success: %1 new item(s) created.', CreatedCount);
            if AlreadyExistCount > 0 then
                SummaryMsg += StrSubstNo('\- Already Exists: %1 item(s) already exist.', AlreadyExistCount);
            if SkippedCount > 0 then
                SummaryMsg += StrSubstNo('\- Not Created: %1 record(s) skipped (Missing PNR).', SkippedCount);

            Message(SummaryMsg);
        end;
    end;
}