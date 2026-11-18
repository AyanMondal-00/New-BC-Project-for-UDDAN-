
pageextension 50351 "Vendor Commission Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {


            field(PLB; Rec.PLB)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the PLB amount for the vendor.';
            }

            field(MLB; Rec.MLB)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the MLB amount for the vendor.';
            }

            field("Annual PLB"; Rec."Annual PLB")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the annual PLB amount for the vendor.';
            }

            field("Target Incentive"; Rec."Target Incentive")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the target incentive amount for the vendor.';
            }

            field(Cashback; Rec.Cashback)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the cashback amount for the vendor.';
            }

            field("CMF/TFEE"; Rec."CMF/TFEE")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the CMF/TFEE amount for the vendor.';
            }
        }
    }
}
