
page 50482 "API Sales Return"
{
    Caption = 'API Sales Return';
    PageType = List;
    SourceTable = "API Sales Return";
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Select"; Rec."Select")
                {
                    ApplicationArea = All;
                }
                field("Sales Credit Memo Created"; Rec."Sales Credit Memo Created")
                {
                    ApplicationArea = All;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }
                field("Bill No."; Rec."Bill No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                }
                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }
                field("A/C Name"; Rec."A/C Name")
                {
                    ApplicationArea = All;
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                }
                field(City; Rec.City)
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
                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }
                field("Flight Time"; Rec."Flight Time")
                {
                    ApplicationArea = All;
                }
                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                }
                field("Airline Code"; Rec."Airline Code")
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
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        PassengerList: Page "API Sales Return Pax List";
                    begin
                        if Rec."Return No." = '' then
                            Error('Return No. is blank.');

                        if Rec.PNR = '' then
                            Error('PNR is blank.');

                        Clear(PassengerList);

                        PassengerList.SetReturnDetails(
                            Rec."Return No.",
                            Rec.PNR);

                        PassengerList.RunModal();
                    end;
                }
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = All;
                }
                field(PAX; Rec.PAX)
                {
                    ApplicationArea = All;
                }
                field(RATE; Rec.RATE)
                {
                    ApplicationArea = All;
                }
                field("Sold Value"; Rec."Sold Value")
                {
                    ApplicationArea = All;
                }
                field("XXLN Charges"; Rec."XXLN Charges")
                {
                    ApplicationArea = All;
                }
                field("Refund Amount"; Rec."Refund Amount")
                {
                    ApplicationArea = All;
                }
                field("Sale Type"; Rec."Sale Type")
                {
                    ApplicationArea = All;
                }
                field(Supplier; Rec.Supplier)
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
            action(ImportExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ImportMgt: Codeunit "API Sales Return Excel Import";
                begin
                    ImportMgt.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';
    end;

    var
        ViewPassengerText: Text[30];
}
