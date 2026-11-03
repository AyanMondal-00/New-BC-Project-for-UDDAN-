pageextension 50704 "AIRIQ Return Create Memo" extends "Purchase Return"
{
    layout
    {
        addafter("Serial No.")
        {
                field("AIRIQ Credit Memo Created"; Rec."AIRIQ Credit Memo Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the purchase credit memo created flag copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Credit Memo No."; Rec."AIRIQ Credit Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the purchase credit memo number copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Vendor Cr. Memo No."; Rec."AIRIQ Vendor Cr. Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the vendor credit memo number copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Posted Cr. Memo No."; Rec."AIRIQ Posted Cr. Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the posted purchase credit memo number copied from the AIRIQ Purchase Return.';
                }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(AIRIQCreateCreditMemo)
            {
                Caption = 'Create Purchase Credit Memo';
                ApplicationArea = All;
                Image = CreditMemo;
                ToolTip = 'Creates an unposted purchase credit memo for the current Purchase Return.';
                trigger OnAction()
                var
                    Creator: Codeunit "AIRIQ Return Credit Memo";
                    Header: Record "Purchase Header";
                begin
                    CurrPage.SaveRecord();
                    Creator.Create(Rec."Serial No.", Header);
                    CurrPage.Update(false);
                    Message('Purchase Credit Memo %1 created with Vendor Credit Memo No. %2. Review and post it manually.', Header."No.", Header."Vendor Cr. Memo No.");
                    Page.Run(Page::"Purchase Credit Memo", Header);
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(AIRIQCreateCreditMemoPromoted; AIRIQCreateCreditMemo) { }
        }
    }
}


pageextension 50700 "AIRIQ Return Cr Memo Page" extends "Purchase Credit Memo"
{
    layout
    {
        addafter(General)
        {
            group(AIRIQReturnDetails)
            {
                Caption = 'AIRIQ Purchase Return Details';
                field("AIRIQ Return Serial No."; Rec."AIRIQ Return Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source purchase return serial no. copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Voucher Number"; Rec."AIRIQ Voucher Number")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the voucher number copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Entry Date"; Rec."AIRIQ Entry Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the entry date copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Purchase Date"; Rec."AIRIQ Purchase Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the original purchase date copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Reference"; Rec."AIRIQ Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the reference copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Narration"; Rec."AIRIQ Narration")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the narration copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Airline ID"; Rec."AIRIQ Airline ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the airline id copied from the AIRIQ Purchase Return.';
                }
            }
        }
    }
}


pageextension 50702 "AIRIQ Return Memo Subform" extends "Purch. Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
                field("AIRIQ PNR"; Rec."AIRIQ PNR")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the pnr copied from the AIRIQ Purchase Return.';
                }
                field("Sample Sector"; Rec."Sample Sector")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sector copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Country"; Rec."AIRIQ Country")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the country copied from the AIRIQ Purchase Return.';
                }
                field("Sample Flight Type"; Rec."Sample Flight Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the travel type copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Pax"; Rec."AIRIQ Pax")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source pax copied from the AIRIQ Purchase Return.';
                }
                field("Sample Base Fare"; Rec."Sample Base Fare")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the base fare copied from the AIRIQ Purchase Return.';
                }
                field("Sample Other Charges"; Rec."Sample Other Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the others copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Rate"; Rec."AIRIQ Rate")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source rate copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Discount"; Rec."AIRIQ Discount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source discount copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ XXLN Charges"; Rec."AIRIQ XXLN Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the xxln charges copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Return Amount"; Rec."AIRIQ Return Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return amount copied from the AIRIQ Purchase Return.';
                }
                field("Sample Travel Date"; Rec."Sample Travel Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the travel date copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Flight No."; Rec."AIRIQ Flight No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the flight no. copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Departure Time"; Rec."AIRIQ Departure Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the departure time copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Arrival Time"; Rec."AIRIQ Arrival Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the arrival time copied from the AIRIQ Purchase Return.';
                }
                field("AIRIQ Cost Revision"; Rec."AIRIQ Cost Revision")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the cost revision copied from the AIRIQ Purchase Return.';
                }
        }
    }
}
