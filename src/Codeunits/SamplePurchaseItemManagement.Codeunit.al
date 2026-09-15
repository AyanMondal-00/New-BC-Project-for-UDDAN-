codeunit 50322 "Sample Purchase Item Mngt"
{
    procedure CreateItems(var SamplePurchase: Record "Sample Purchase")
    var
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
        CreatedCount: Integer;
        AlreadyExistCount: Integer;
        SkippedCount: Integer;
        SummaryMsg: Text;
    begin
        if SamplePurchase.IsEmpty() then begin
            Message('No Sample Purchase records selected.');
            exit;
        end;

        SamplePurchase.FindSet();

        repeat
            if (SamplePurchase.PNR <> '') and
               (not SamplePurchase."Item Created") then begin

                Item.Reset();
                Item.SetRange(Description, SamplePurchase.PNR);

                if not Item.FindFirst() then begin
                    Item.Init();
                    Item."No." := NoSeries.GetNextNo('ITEM');
                    Item.Description := SamplePurchase.PNR;
                    Item.Validate(Type, Item.Type::"Non-Inventory");
                    Item.Validate("Gen. Prod. Posting Group", 'RETAIL');
                    Item.Insert(true);

                    Item.Validate("Base Unit of Measure", 'PAX');
                    Item.Modify(true);

                    SamplePurchase."Item Created" := true;
                    SamplePurchase.Modify(true);

                    CreatedCount += 1;
                end else begin
                    SamplePurchase."Item Created" := true;
                    SamplePurchase.Modify(true);

                    AlreadyExistCount += 1;
                end;

            end else
                if SamplePurchase.PNR = '' then
                    SkippedCount += 1
                else
                    AlreadyExistCount += 1;

        until SamplePurchase.Next() = 0;

        if (CreatedCount > 0) and
           (AlreadyExistCount = 0) and
           (SkippedCount = 0) then
            Message(
                'Success! %1 new Item(s) created successfully.',
                CreatedCount)

        else
            if (CreatedCount = 0) and
               (AlreadyExistCount > 0) and
               (SkippedCount = 0) then
                Message(
                    'Already Exists! This %1 selected item(s) are already created.',
                    AlreadyExistCount)

            else
                if (CreatedCount = 0) and
                   (AlreadyExistCount = 0) and
                   (SkippedCount > 0) then
                    Message(
                        'Not Created! %1 selected record(s) were skipped because PNR was missing.',
                        SkippedCount)

                else begin
                    SummaryMsg := 'Item Creation Summary:\';

                    if CreatedCount > 0 then
                        SummaryMsg += StrSubstNo(
                            '\- Success: %1 new item(s) created.',
                            CreatedCount);

                    if AlreadyExistCount > 0 then
                        SummaryMsg += StrSubstNo(
                            '\- Already Exists: %1 item(s) already exist.',
                            AlreadyExistCount);

                    if SkippedCount > 0 then
                        SummaryMsg += StrSubstNo(
                            '\- Not Created: %1 record(s) skipped (Missing PNR).',
                            SkippedCount);

                    Message(SummaryMsg);
                end;
    end;
}