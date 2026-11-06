
pageextension 50715 "AIRIQ SR Memo Page" extends "Sales Credit Memo"
{
    layout
    {
        addafter(General)
        {
            group(AIRIQReturn)
            {
                Caption = 'AIRIQ Sales Return Details';

                field("AIRIQ Return No."; Rec."AIRIQ Return No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Return Serial"; Rec."AIRIQ Return Serial")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Bill No."; Rec."AIRIQ Bill No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Original Invoice"; Rec."AIRIQ Original Invoice")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Entry Date"; Rec."AIRIQ Entry Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Reference"; Rec."AIRIQ Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Narration"; Rec."AIRIQ Narration")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Supplier"; Rec."AIRIQ Supplier")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
                field("AIRIQ Sale Type"; Rec."AIRIQ Sale Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the source return information.';
                }
            }
        }
    }
}

pageextension 50716 "AIRIQ SR Memo Lines" extends "Sales Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Passenger Name"; Rec."Passenger Name")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Passenger Type"; Rec."AIRIQ Passenger Type")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Passenger SL"; Rec."AIRIQ Passenger SL")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Taxable Value"; Rec."AIRIQ Taxable Value")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Source CGST"; Rec."AIRIQ Source CGST")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Source SGST"; Rec."AIRIQ Source SGST")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Source IGST"; Rec."AIRIQ Source IGST")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Sold Value"; Rec."AIRIQ Sold Value")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ XXLN Charges"; Rec."AIRIQ XXLN Charges")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Refund Amount"; Rec."AIRIQ Refund Amount")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Country"; Rec."AIRIQ Country")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ State"; Rec."AIRIQ State")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ City"; Rec."AIRIQ City")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Travel Time"; Rec."AIRIQ Travel Time")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Airline"; Rec."AIRIQ Airline")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Airline Code"; Rec."AIRIQ Airline Code")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Reference"; Rec."AIRIQ Reference")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field(Sector; Rec.Sector)
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field(FlightType; Rec.FlightType)
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("Travel Date"; Rec."Travel Date")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field(BaseFare; Rec.BaseFare)
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
        }
    }
}

pageextension 50717 "AIRIQ SR Action" extends "Sales Return List"
{
    layout
    {
        addafter("Serial No.")
        {
            field("AIRIQ Memo Created"; Rec."AIRIQ Memo Created")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
            field("AIRIQ Memo No."; Rec."AIRIQ Memo No.")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the source return information.';
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(AIRIQCreateMemo)
            {
                Caption = 'Create Sales Credit Memo';
                Image = CreditMemo;
                ApplicationArea = All;
                ToolTip = 'Creates an unposted credit memo for this return.';

                trigger OnAction()
                var
                    Creator: Codeunit "AIRIQ SR Create Memo";
                    Header: Record "Sales Header";
                begin
                    CurrPage.SaveRecord();
                    Creator.Create(Rec."Serial No.", Header);
                    CurrPage.Update(false);
                    Page.Run(Page::"Sales Credit Memo", Header);
                end;
            }
        }

        addlast(Promoted)
        {
            actionref(AIRIQCreateMemoPromoted; AIRIQCreateMemo)
            {
            }
        }
    }
}
