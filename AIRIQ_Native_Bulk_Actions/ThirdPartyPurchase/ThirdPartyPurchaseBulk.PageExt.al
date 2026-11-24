pageextension 50734 "AIRIQ TP Purch Bulk Ext" extends "TP Sample Purchase List"
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
                        Selected: Record "Third Party Sample Purchase";
                        ItemMgt: Codeunit "Third Party Purchase Item Mgt";
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
                        Selected: Record "Third Party Sample Purchase";
                        InvoiceMgt: Codeunit "TP Purchase Invoice Mgt";
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
                        Selected: Record "Third Party Sample Purchase";
                        InvoiceMgt: Codeunit "TP Purchase Invoice Mgt";
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
