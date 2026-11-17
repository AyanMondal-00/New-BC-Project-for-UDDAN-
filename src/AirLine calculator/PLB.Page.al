
page 50460 "PLB"
{
    Caption = 'PLB Statement';
    PageType = List;
    SourceTable = "PLB";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Automatically generated PLB serial number.';
                }

                field("PNR"; Rec."PNR")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the PNR reference.';
                }

                field("Airline"; Rec."Airline")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the airline.';
                }

                field("Airline ID's"; Rec."Airline ID's")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the airline IDs.';
                }

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the transaction type.';
                }

                field("Basis"; Rec."Basis")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the commission calculation basis.';
                }

                field("Period"; Rec."Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the commission period.';
                }

                field("Commission Base"; Rec."Commission Base")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the commission calculation base.';
                }

                field("Commission %"; Rec."Commission %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the commission percentage.';
                }

                field("Commission Amount"; Rec."Commission Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the calculated commission amount.';
                }

                field("GST"; Rec."GST")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the GST amount.';
                }

                field("Invoice Amount"; Rec."Invoice Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the commission invoice amount including GST.';
                }

                field("TDS"; Rec."TDS")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the TDS amount.';
                }

                field("Net Receivable"; Rec."Net Receivable")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                    ToolTip = 'Specifies the net receivable amount.';
                }

                field("Received On"; Rec."Received On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when payment was received.';
                }

                field("Received In"; Rec."Received In")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the bank or account where payment was received.';
                }

                field("Status"; Rec."Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyle;
                    ToolTip = 'Specifies whether payment is Received or Pending.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenPLBCalculator)
            {
                Caption = 'PLB Calculator';
                ApplicationArea = All;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Opens the PLB Commission Calculator.';

                trigger OnAction()
                begin
                    Page.Run(Page::"AIRIQ PLB Calculator");
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateStatusStyle();
    end;

    var
        StatusStyle: Text;

    local procedure UpdateStatusStyle()
    begin
        case Rec."Status" of
            'Received':
                StatusStyle := 'Favorable';
            'Pending':
                StatusStyle := 'Unfavorable';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
