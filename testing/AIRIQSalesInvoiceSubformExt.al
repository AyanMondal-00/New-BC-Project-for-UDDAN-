
pageextension 50595 "Air Sales Invoice Subform Ext"
    extends "Sales Invoice Subform"
{
    layout
    {
        addafter("No.")
        {
            field(AIRIQFlightType; Rec.FlightType)
            {
                ApplicationArea = All;
                Caption = 'Flight Type';
                ToolTip = 'Enter Domestic or International for AIRIQ GST calculation.';

                trigger OnValidate()
                begin
                    CurrPage.Update(true);
                end;
            }
        }
    }
}
