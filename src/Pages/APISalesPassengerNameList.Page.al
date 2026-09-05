page 50415 "API Sales Passenger Name List"
{
    Caption = 'API Sales Passenger Name List';
    PageType = List;
    SourceTable = "API Sales Passenger Name";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group("Reference")
            {
                Caption = 'Reference';

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
            }

            repeater(General)
            {
                field("SL No."; Rec."SL No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Passenger Name"; Rec."Passenger Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Passenger: Record "API Sales Passenger Name";
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

    procedure SetRefNoAQNumber(AQNumber: Code[50]; PNRNo: Code[10])
    begin
        CurrentRefNo_AQNumber := AQNumber;
        CurrentPNR := PNRNo;

        Rec.SetRange("Ref No./AQ Number", CurrentRefNo_AQNumber);
        Rec.SetRange(PNR, CurrentPNR);
    end;

    var
        CurrentRefNo_AQNumber: Code[50];
        CurrentPNR: Code[10];
}
