pageextension 50735 "AIRIQ Inv Cons Bulk Ext" extends "Inv. Consumption List"
{
    actions
    {
        modify("Create Purchase Return Order") { Visible = false; }
        addlast(Processing)
        {
            action(AIRIQBulkPurchaseReturns)
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Return Order';
                Image = ReturnReceipt;
                ToolTip = 'Create purchase return orders for highlighted rows, not ticked checkboxes.';
                trigger OnAction()
                var
                    Selected: Record "Inventory Consumption";
                    OrderMgt: Codeunit "Purchase Return Order Mgt.";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(Selected);
                    if Selected.IsEmpty() then Error('Select at least one row.');
                    OrderMgt.CreatePurchaseReturnOrders(Selected);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
