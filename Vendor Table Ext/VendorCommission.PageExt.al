pageextension 50351 "Vendor Commission Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {
            field("Vendor Commision"; Rec."Vendor Commision")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the vendor commission amount.';
            }
        }
    }
}