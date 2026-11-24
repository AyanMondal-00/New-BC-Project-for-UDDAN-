page 50662 "TP Sample Purchase List"
{
    Caption = 'Third Party Sample Purchase Format';
    PageType = List;
    SourceTable = "Third Party Sample Purchase";
    DelayedInsert = true;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.") { ApplicationArea = All; Editable = false; }
                field("Purchase Date"; Rec."Purchase Date") { ApplicationArea = All; }
                field("Entry Date"; Rec."Entry Date") { ApplicationArea = All; }
                field(Airline; Rec.Airline) { ApplicationArea = All; }
                field("Supplier ID"; Rec."Supplier ID") { ApplicationArea = All; }
                field(Select; Rec.Select) { ApplicationArea = All; }
                field("Invoice Created"; Rec."Invoice Created") { ApplicationArea = All; Editable = false; }
                field("Invoice Posted"; Rec."Invoice Posted") { ApplicationArea = All; Editable = false; }
                field("Item Created"; Rec."Item Created") { ApplicationArea = All; Editable = false; }
                field(PNR; Rec.PNR) { ApplicationArea = All; }
                field("Total Pax"; Rec."Total Pax") { ApplicationArea = All; }
                field("Travel Date"; Rec."Travel Date") { ApplicationArea = All; }
                field(Sector; Rec.Sector) { ApplicationArea = All; }
                field(Type; Rec.Type) { ApplicationArea = All; }
                field(Rate; Rec.Rate) { ApplicationArea = All; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; Editable = false; }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportExcel)
            {
                Caption = 'Import from Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                trigger OnAction()
                var
                    Importer: Codeunit "TP Purchase Excel Import";
                begin
                    Importer.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
            action(CreateItems)
            {
                Caption = 'Create Items';
                ApplicationArea = All;
                Image = NewItem;
                trigger OnAction()
                var
                    Purchase: Record "Third Party Sample Purchase";
                    ItemMgt: Codeunit "Third Party Purchase Item Mgt";
                begin
                    GetSelectedPurchases(Purchase);
                    ItemMgt.CreateItems(Purchase);
                    CurrPage.Update(false);
                end;
            }
            action(CreateInvoices)
            {
                Caption = 'Create Purchase Invoice';
                ApplicationArea = All;
                Image = CreateDocument;
                trigger OnAction()
                var
                    Purchase: Record "Third Party Sample Purchase";
                    InvoiceMgt: Codeunit "TP Purchase Invoice Mgt";
                begin
                    GetSelectedPurchases(Purchase);
                    InvoiceMgt.CreatePurchaseInvoices(Purchase);
                    CurrPage.Update(false);
                end;
            }
            action(CreateAndPost)
            {
                Caption = 'Create & Post Purchase Invoices';
                ApplicationArea = All;
                Image = Post;
                trigger OnAction()
                var
                    Purchase: Record "Third Party Sample Purchase";
                    InvoiceMgt: Codeunit "TP Purchase Invoice Mgt";
                begin
                    GetSelectedPurchases(Purchase);
                    InvoiceMgt.CreateAndPostPurchaseInvoices(Purchase);
                    CurrPage.Update(false);
                end;
            }
        }   
    }

    local procedure GetSelectedPurchases(var Purchase: Record "Third Party Sample Purchase")
    begin
        Purchase.SetRange(Select, true);
        if Purchase.IsEmpty() then
            Error('Select at least one Third Party Sample Purchase record.');
    end;

}
