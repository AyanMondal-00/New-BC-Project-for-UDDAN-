codeunit 50664 "Third Party Purchase Item Mgt"
{
    procedure CreateItems(var SelectedPurchases: Record "Third Party Sample Purchase")
    var
        Purchase: Record "Third Party Sample Purchase";
        Item: Record Item;
        CreatedCount: Integer;
        ReusedCount: Integer;
        FailedCount: Integer;
    begin
        Purchase.Copy(SelectedPurchases);
        if Purchase.FindSet(true) then
            repeat
                if Purchase.PNR = '' then
                    FailedCount += 1
                else begin
                    Clear(Item);
                    if Item.Get(Purchase.PNR) then begin
                        ReusedCount += 1;
                    end else begin
                        Item.SetRange(Description, Purchase.PNR);
                        if Item.FindFirst() then
                            ReusedCount += 1
                        else begin
                            Clear(Item);
                            Item.Init();
                            Item."No." := Purchase.PNR;
                            Item.Description := Purchase.PNR;
                            Item.Validate(Type, Item.Type::Inventory);
                            Item.Validate("Inventory Posting Group", 'RESALE');
                            Item.Validate("Gen. Prod. Posting Group", 'RETAIL');
                            Item.Validate("GST Group Code", 'S1800');
                            Item.Validate("HSN/SAC Code", '998551');
                            Item.Validate("GST Credit", Item."GST Credit"::Availment);
                            Item.Insert(true);
                            Item.Validate("Base Unit of Measure", 'PAX');
                            Item.Modify(true);
                            CreatedCount += 1;
                        end;
                    end;
                    if not Purchase."Item Created" then begin
                        Purchase."Item Created" := true;
                        Purchase.Modify(true);
                    end;
                end;
            until Purchase.Next() = 0;
        Message('Item creation complete. Created: %1, reused: %2, failed: %3.', CreatedCount, ReusedCount, FailedCount);
    end;
}
