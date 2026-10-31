page 50312 "Purchase Return"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purchase Return";
    Caption = 'Purchase Return';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Voucher Number"; Rec."Voucher Number")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                }

                field("Airline ID"; Rec."Airline ID")
                {
                    ApplicationArea = All;
                }


                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                }

                field(Narration; Rec.Narration)
                {
                    ApplicationArea = All;
                }

                field(Pax; Rec.Pax)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field(Others; Rec.Others)
                {
                    ApplicationArea = All;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }

                field(Discount; Rec.Discount)
                {
                    ApplicationArea = All;
                }

                field("XXLN Charges"; Rec."XXLN Charges")
                {
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field("Departure Time"; Rec."Departure Time")
                {
                    ApplicationArea = All;
                }

                field("Arrival Time"; Rec."Arrival Time")
                {
                    ApplicationArea = All;
                }

                field("Flight No."; Rec."Flight No.")
                {
                    ApplicationArea = All;
                }

   

                field("Cost Revision"; Rec."Cost Revision")
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
            action("Import from Excel")
            {
                Caption = 'Import from Excel';
                ApplicationArea = All;
                Image = ImportExcel;

                trigger OnAction()
                var
                    PurchaseReturnExcelImport: Codeunit "Purchase Return Excel Import";
                begin
                    PurchaseReturnExcelImport.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
