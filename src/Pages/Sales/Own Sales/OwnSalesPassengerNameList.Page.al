page 50412 "Own Sales Passenger List Name"
{
    Caption = 'Own Sale Passenger Name List';
    PageType = List;
    SourceTable = "Own Sales Passenger Name";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Ref No./AQ Number"; Rec."Ref No./AQ Number")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("SL No."; Rec."SL No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Passenger Name"; Rec."Passenger Name")
                {
                    ApplicationArea = All;
                }

                field("ID"; Rec."ID")
                {
                    ApplicationArea = All;
                }

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Passenger: Record "Own Sales Passenger Name";
    begin
        Rec."Ref No./AQ Number" := CurrentRefNo_AQNumber;
        Rec.PNR := CurrentPNR;

        Passenger.Reset();
        Passenger.SetRange("Ref No./AQ Number", CurrentRefNo_AQNumber);
        Passenger.SetRange(PNR, CurrentPNR);

        if Passenger.FindLast() then
            Rec."SL No." := Passenger."SL No." + 1
        else
            Rec."SL No." := 1;
    end;

    procedure SetRefNoAQNumber(AQNumber: Integer; PNRNo: Text[10])
    begin
        CurrentRefNo_AQNumber := AQNumber;
        CurrentPNR := PNRNo;

        Rec.SetRange("Ref No./AQ Number", CurrentRefNo_AQNumber);
        Rec.SetRange(PNR, CurrentPNR);
    end;

    var
        CurrentRefNo_AQNumber: Integer;
        CurrentPNR: Text[10];
}