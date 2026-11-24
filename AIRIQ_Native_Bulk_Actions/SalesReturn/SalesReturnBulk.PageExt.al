pageextension 50736 "AIRIQ Sales Return Bulk Ext" extends "Sales Return List"
{
    actions
    {
        modify("Refresh Posted Invoice Values") { Visible = false; }
        addlast(Processing)
        {
            action(AIRIQBulkRefreshPostedValues)
            {
                ApplicationArea = All;
                Caption = 'Refresh Posted Invoice Values';
                Image = Refresh;
                ToolTip = 'Refresh posted invoice values for each highlighted sales return row.';
                trigger OnAction()
                var
                    Selected: Record "Sales Return";
                begin
                    CurrPage.SaveRecord();
                    CurrPage.SetSelectionFilter(Selected);
                    if Selected.IsEmpty() then Error('Select at least one row.');
                    if Selected.FindSet(true) then
                        repeat
                            Selected.RefreshPostedInvoiceData();
                            Selected.Modify(true);
                        until Selected.Next() = 0;
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
