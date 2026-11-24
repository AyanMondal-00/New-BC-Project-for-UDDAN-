pageextension 50733 "AIRIQ Sample Purch Bulk Ext" extends "Sample Purchase List"
{
    actions
    {
        modify("Create Items") { Visible = false; }
        modify("Create Purchase Invoice action") { Visible = false; }
        modify("Create & Post Purchase Invoices") { Visible = false; }

        addlast(Processing)
        {
            group(AIRIQNativeSelection)
            {
                Caption = 'Selected Rows - Bulk Actions';

                action(AIRIQBulkCreateItems)
                {
                    ApplicationArea = All;
                    Caption = 'Create Items';
                    Image = NewItem;
                    ToolTip = 'Create items for the highlighted rows, independent of the Select checkbox.';
                    trigger OnAction()
                    var
                        Selected: Record "Sample Purchase";
                        ItemMgt: Codeunit "Sample Purchase Item Mngt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then
                            Error('Select at least one row.');
                        ItemMgt.CreateItems(Selected);
                        CurrPage.Update(false);
                    end;
                }

                action(AIRIQBulkCreateInvoice)
                {
                    ApplicationArea = All;
                    Caption = 'Create Purchase Invoice';
                    Image = CreateDocument;
                    ToolTip = 'Create purchase invoices for the highlighted rows.';
                    trigger OnAction()
                    var
                        Selected: Record "Sample Purchase";
                        InvoiceMgt: Codeunit "Sample Purchase Invoice Mngt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then
                            Error('Select at least one row.');
                        InvoiceMgt.CreatePurchaseInvoices(Selected);
                        CurrPage.Update(false);
                    end;
                }

                action(AIRIQBulkCreateAndPost)
                {
                    ApplicationArea = All;
                    Caption = 'Create & Post Purchase Invoices';
                    Image = Post;
                    ToolTip = 'Create and post invoices for highlighted rows using existing validations.';
                    trigger OnAction()
                    var
                        Selected: Record "Sample Purchase";
                        InvoiceMgt: Codeunit "Sample Purchase Invoice Mngt";
                    begin
                        CurrPage.SaveRecord();
                        CurrPage.SetSelectionFilter(Selected);
                        if Selected.IsEmpty() then
                            Error('Select at least one row.');
                        InvoiceMgt.CreateAndPostPurchaseInvoices(Selected);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }
}
