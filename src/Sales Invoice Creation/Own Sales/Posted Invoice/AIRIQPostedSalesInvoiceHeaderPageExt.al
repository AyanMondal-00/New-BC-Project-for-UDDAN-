pageextension 50432 "AIRIQ Posted Sales Inv Header" extends "Posted Sales Invoice"
{
    layout
    {
        addafter("Document Date")
        {
            field("AQ Number"; Rec."AQ Number")
            {
                ApplicationArea = All;
            }

            field("Agency ID"; Rec."Agency ID")
            {
                ApplicationArea = All;
            }

            field("Sales Type"; Rec."Sales Type")
            {
                ApplicationArea = All;
            }
        }
    }
}