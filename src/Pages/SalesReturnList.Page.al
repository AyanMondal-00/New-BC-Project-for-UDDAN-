page 50413 "Sales Return List"
{
    Caption = 'Sales Return / Cancellation Charge Format';
    PageType = List;
    SourceTable = "Sales Return";
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

                field(Time; Rec.Time)
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

                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                }

                field(Narration; Rec.Narration)
                {
                    ApplicationArea = All;
                }

                field(PAX; Rec.PAX)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field("Taxable Value"; Rec."Taxable Value")
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

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        SalesReturn: Record "Sales Return";
    begin
        SalesReturn.Reset();

        if SalesReturn.FindLast() then
            if SalesReturn."Serial No." >= 1 then
                Rec."Serial No." := SalesReturn."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;
}
