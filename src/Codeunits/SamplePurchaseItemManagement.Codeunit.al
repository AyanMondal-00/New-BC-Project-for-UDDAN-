codeunit 50322 "Sample Purchase Item Mngt"
{
    procedure CreateItems()
    var
        SamplePurchase: Record "Sample Purchase";
        Item: Record Item;
        NoSeries: Codeunit "No. Series";
    begin
        if SamplePurchase.FindSet() then
            repeat
                if SamplePurchase.PNR <> '' then begin
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
                    end;
                end;
            until SamplePurchase.Next() = 0;
    end;
}