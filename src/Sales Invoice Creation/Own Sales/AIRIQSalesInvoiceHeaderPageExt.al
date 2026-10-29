pageextension 50427 "Sales Invoice Header PgExt" extends "Sales Invoice"
{
    layout
    {
        addafter("Document Date")
        {
            field("AQ Number"; Rec."AQ Number")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Agency ID"; Rec."Agency ID")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Sales Type"; Rec."Sales Type")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}