pageextension 50433 "AIRIQ Posted Sales Inv Line" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Passenger Name"; Rec."Passenger Name")
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

            field(FlightType; Rec.FlightType)
            {
                ApplicationArea = All;
            }
            field(BaseFare; Rec.BaseFare)
            {
                ApplicationArea = All;
            }
      
            field("Other Charges"; Rec."Other Charges")
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
        }
    }
}