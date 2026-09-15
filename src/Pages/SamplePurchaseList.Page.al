page 50310 "Sample Purchase List"
{
    Caption = 'Sample Purchase Format';
    PageType = List;
    SourceTable = "Sample Purchase";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {

        area(content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Selection: Integer;
                    begin
                        Selection := StrMenu('Air India,IndiGo,SpiceJet', 1, 'Select Airline:');
                        if Selection <> 0 then begin
                            case Selection of
                                1:
                                    Text := 'Air India';
                                2:
                                    Text := 'IndiGo';
                                3:
                                    Text := 'SpiceJet';
                            end;
                            exit(true);
                        end;
                    end;
                }

                field("Supplier ID"; Rec."Supplier ID")
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("Total Pax"; Rec."Total Pax")
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("Create Purchase Invoice"; Rec."Create Purchase Invoice")
                {
                    ApplicationArea = All;
                }
                field("Invoice Created"; InvoiceCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Created';
                    Editable = false;
                }
                field("Item Created"; ItemCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Item Created';
                    Editable = false;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Import from API")
            {
                ApplicationArea = All;
                Caption = 'Import from API';
                Image = Import;

                trigger OnAction()
                var
                    APIManagement: Codeunit "Sample Purchase API Management";
                begin
                    APIManagement.ImportFromAPI();
                    CurrPage.Update(false);
                end;
            }

            action("Create Items")
            {
                ApplicationArea = All;
                Caption = 'Create Items';
                Image = NewItem;

                trigger OnAction()
                var
                    SamplePurchaseItemManagement: Codeunit "Sample Purchase Item Mngt";
                    SelectedSamplePurchase: Record "Sample Purchase";
                begin
                    CurrPage.SetSelectionFilter(SelectedSamplePurchase);

                    SamplePurchaseItemManagement.CreateItems(SelectedSamplePurchase);

                    CurrPage.Update(false);
                end;
            }
            action("Create Purchase Invoice action")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Invoice';
                Image = CreateDocument;

                trigger OnAction()
                var
                    SamplePurchaseInvoiceMgt: Codeunit "Sample Purchase Invoice Mngt";
                begin
                    SamplePurchaseInvoiceMgt.CreatePurchaseInvoices();
                    CurrPage.Update(false);
                end;
            }

        }

    }
    var
        InvoiceCreatedText: Text[3];
        ItemCreatedText: Text[3];

    trigger OnAfterGetRecord()
    begin
        if Rec."Purchase Invoice Created" then
            InvoiceCreatedText := 'Yes'
        else
            InvoiceCreatedText := 'No';

        if Rec."Item Created" then
            ItemCreatedText := 'Yes'
        else
            ItemCreatedText := 'No';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        SamplePurchase: Record "Sample Purchase";

    begin
        SamplePurchase.Reset();
        if SamplePurchase.FindLast() then
            if SamplePurchase."Serial No." >= 1 then
                Rec."Serial No." := SamplePurchase."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;
}
