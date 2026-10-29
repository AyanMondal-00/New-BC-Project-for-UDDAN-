pageextension 50428 "AIRIQ Sales Invoice Line PgExt" extends "Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Passenger Name"; Rec."Passenger Name")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Travel Date"; Rec."Travel Date")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(Sector; Rec.Sector)
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(FlightType; Rec.FlightType)
            {
                ApplicationArea = All;
                Editable = false;
            }
            field(BaseFare; Rec.BaseFare)
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Other Charges"; Rec."Other Charges")
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
        }
    }
}