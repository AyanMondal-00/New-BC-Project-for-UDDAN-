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

        if ProcessRec.IsEmpty() then begin
            Message('No Sample Purchase records selected.');
            exit;
        end;

        if ProcessRec.FindSet(true) then
            repeat
                if ProcessRec.PNR = '' then begin
                    SkippedCount += 1;
                end else begin
                    Clear(Item);
                    Item.SetRange(
                        Description,
                        ProcessRec.PNR);

                    if Item.FindFirst() then begin

                        if not ProcessRec."Item Created" then begin
                            ProcessRec."Item Created" := true;
                            ProcessRec.Modify(true);
                        end;

                        AlreadyExistCount += 1;

                    end else begin

                        Clear(Item);
                        Item.Init();

                        Item."No." :=
                            NoSeries.GetNextNo('ITEM');

                        Item.Description :=
                            ProcessRec.PNR;

                        Item.Validate(
                            Type,
                            Item.Type::"Non-Inventory");

                        Item.Validate(
                            "Gen. Prod. Posting Group",
                            'RETAIL');

                        Item.Insert(true);

                        Item.Validate(
                            "Base Unit of Measure",
                            'PAX');

                        Item.Modify(true);

                        ProcessRec."Item Created" := true;
                        ProcessRec.Modify(true);

                        CreatedCount += 1;
                    end;
                end;

            until ProcessRec.Next() = 0;

        // -------------------------
        // Result
        // -------------------------
        if (CreatedCount > 0) and
           (AlreadyExistCount = 0) and
           (SkippedCount = 0) then begin

            Message(
                'Success! %1 new Item(s) created successfully.',
                CreatedCount);

        end else if (CreatedCount = 0) and
                   (AlreadyExistCount > 0) and
                   (SkippedCount = 0) then begin

            Message(
                'Already Exists! All %1 selected item(s) already exist.',
                AlreadyExistCount);

        end else if (CreatedCount = 0) and
                   (AlreadyExistCount = 0) and
                   (SkippedCount > 0) then begin

            Message(
                'Not Created! %1 selected record(s) were skipped because PNR was missing.',
                SkippedCount);

        end else begin

            SummaryMsg :=
                'Item Creation Summary:\';

            if CreatedCount > 0 then
                SummaryMsg +=
                    StrSubstNo(
                        '\- Success: %1 new item(s) created.',
                        CreatedCount);

            if AlreadyExistCount > 0 then
                SummaryMsg +=
                    StrSubstNo(
                        '\- Already Exists: %1 item(s) already exist.',
                        AlreadyExistCount);

            if SkippedCount > 0 then
                SummaryMsg +=
                    StrSubstNo(
                        '\- Not Created: %1 record(s) skipped (Missing PNR).',
                        SkippedCount);

            Message(SummaryMsg);
        end;
    end;
}