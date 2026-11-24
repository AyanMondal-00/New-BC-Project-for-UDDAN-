pageextension 50305 "AIRIQ API SP Bulk Ext" extends "API Sample Purchase List"
{
    actions
    {
        modify(CreateItems) { Visible = false; }
        modify(CreateInvoices) { Visible = false; }
        modify(CreateAndPost) { Visible = false; }

        addlast(Processing)
        {
            group(AIRIQTPNativeSelection)
            {
                Caption = 'Selected Rows - Bulk Actions';
                action(AIRIQTPBulkItems)
                {
                    ApplicationArea = All;
                    Caption = 'Create Items';
                    Image = NewItem;
                    trigger OnAction()
                    var
                        Selected: Record "API Sample Purchase";
                        ItemMgt: Codeunit "API SP Purchase Item Mgt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then Error('Select at least one row.');
                        ItemMgt.CreateItems(Selected);
                        CurrPage.Update(false);
                    end;
                }
                action(AIRIQTPBulkInvoices)
                {
                    ApplicationArea = All;
                    Caption = 'Create Purchase Invoice';
                    Image = CreateDocument;
                    trigger OnAction()
                    var
                        Selected: Record "API Sample Purchase";
                        InvoiceMgt: Codeunit "API SP Purchase Invoice Mgt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then Error('Select at least one row.');
                        InvoiceMgt.CreatePurchaseInvoices(Selected);
                        CurrPage.Update(false);
                    end;
                }
                action(AIRIQTPBulkCreateAndPost)
                {
                    ApplicationArea = All;
                    Caption = 'Create & Post Purchase Invoices';
                    Image = Post;
                    trigger OnAction()
                    var
                        Selected: Record "API Sample Purchase";
                        InvoiceMgt: Codeunit "API SP Purchase Invoice Mgt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then Error('Select at least one row.');
                        InvoiceMgt.CreateAndPostPurchaseInvoices(Selected);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
