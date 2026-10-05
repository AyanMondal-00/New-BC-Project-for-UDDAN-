page 50410 "Normal Sales List"
{
    Caption = 'Normal Sales';
    PageType = List;
    SourceTable = "Normal Sales";
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
                        PassengerList: Page "Own Sales Passenger List Name";
                    begin
                        PassengerList.SetRefNoAQNumber(Rec."Ref No./AQ Number", Rec.PNR);
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
                    Editable = false;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Own Sales Data from API")
            {
                ApplicationArea = All;
                Caption = 'Import Own Sales Data from API';
                Image = Import;

                trigger OnAction()
                var
                    OwnSalesAPIMgt: Codeunit "Own Sales API Mgt.";
                begin
                    OwnSalesAPIMgt.ImportOneNormalSale();
                    CurrPage.Update(false);
                end;
            }
            action("Check BC Public IP")
            {
                ApplicationArea = All;
                Caption = 'Check BC Public IP';

                trigger OnAction()
                var
                    BCPublicIPTest: Codeunit "BC Public IP Test";
                begin
                    BCPublicIPTest.GetBCPublicIP();
                end;
            }
        }

    }


    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        NormalSales: Record "Normal Sales";
    begin
        NormalSales.Reset();
        if NormalSales.FindLast() then
            if NormalSales."Serial No." >= 1 then
                Rec."Serial No." := NormalSales."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;

    var
        ViewPassengerText: Text[30];
}













