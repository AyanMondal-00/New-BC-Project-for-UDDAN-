
pageextension 50428 "AIRIQ Sales Invoice Line PgExt"
    extends "Sales Invoice Subform"
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

            // New GST Amendment Field
            field("AIRIQ GST Base Fare"; Rec."AIRIQ GST Base Fare")
            {
                ApplicationArea = All;
                Caption = 'AIRIQ GST Base Fare';
                Editable = false;
                ToolTip = 'Specifies the base fare per unit used for AIRIQ GST taxable base calculation.';
            }

            field("Other Charges"; Rec."Other Charges")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}
