page 50420 "Inventory Consumption List"
{
    Caption = 'Inventory Consumption';
    PageType = List;
    SourceTable = "Inventory Consumption";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Select; Rec.Select)
                {
                    ApplicationArea = All;
                    Caption = 'Select';
                }

                field("Purchase Return Order Created"; PurchaseReturnOrderCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Return Order Created';
                    Editable = false;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }

                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = All;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field("Agency Name"; Rec."Agency Name")
                {
                    ApplicationArea = All;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("Ref No./AQ Number"; Rec."Ref No./AQ Number")
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("View Passenger"; ViewPassengerText)
                {
                    ApplicationArea = All;
                    Caption = 'View Passenger';
                    Editable = false;

                    trigger OnDrillDown()
                    var
                        PassengerList: Page "Inventory Consumption Pasenger";
                    begin
                        PassengerList.SetRefNoAQNumber(
                            Rec."Ref No./AQ Number",
                            Rec.PNR);

                        PassengerList.RunModal();
                    end;
                }

                field(Pax; Rec.Pax)
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

                field(Type; Rec.Type)
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

                field("Taxable Basis"; Rec."Taxable Basis")
                {
                    ApplicationArea = All;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create Purchase Return Order")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Return Order';
                Image = ReturnReceipt;

                trigger OnAction()
                var
                    SelectedConsumption: Record "Inventory Consumption";
                    PurchaseReturnOrderMgt: Codeunit "Purchase Return Order Mgt.";
                begin
                    SelectedConsumption.Reset();
                    SelectedConsumption.SetRange(Select, true);

                    if SelectedConsumption.IsEmpty() then begin
                        Message('Please select at least one record.');
                        exit;
                    end;

                    PurchaseReturnOrderMgt.CreatePurchaseReturnOrders(
                        SelectedConsumption);

                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        PurchaseReturnOrderCreatedText: Text[40];
        ViewPassengerText: Text[40];

    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';

        if Rec."Purchase Return Order Created" then
            PurchaseReturnOrderCreatedText := 'No'
        else
            PurchaseReturnOrderCreatedText := 'Yes';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        InventoryConsumption: Record "Inventory Consumption";
    begin
        InventoryConsumption.Reset();

        if InventoryConsumption.FindLast() then
            if InventoryConsumption."Serial No." >= 1 then
                Rec."Serial No." := InventoryConsumption."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;
}