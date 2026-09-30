pageextension 50422 "Purchase Order Subform Ext." extends "Purchase Order Subform"
{
    layout
    {
        addafter("Line Amount")
        {
            field("Other Charges"; Rec."Other Charges")
            {
                ApplicationArea = All;
            }

            field("Taxable Basis"; Rec."Taxable Basis")
            {
                ApplicationArea = All;
            }

            field("CGST Amount"; Rec."CGST Amount")
            {
                ApplicationArea = All;
            }

            field("SGST Amount"; Rec."SGST Amount")
            {
                ApplicationArea = All;
            }

            field("IGST Amount"; Rec."IGST Amount")
            {
                ApplicationArea = All;
            }

            field("Total Amount"; Rec."Total Amount")
            {
                ApplicationArea = All;
            }
        }
    }
}