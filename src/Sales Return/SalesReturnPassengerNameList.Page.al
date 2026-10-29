page 50418 "Sales Return Passenger List"
{
    Caption = 'Sales Return Passenger Name List';
    PageType = List;
    SourceTable = "Sales Return Passenger Name";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group("Reference")
            {
                Caption = 'Reference';

                field("Return No."; Rec."Return No.")
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
        Passenger: Record "Sales Return Passenger Name";
    begin
        Rec."Return No." := CurrentReturnNo;
        Rec.PNR := CurrentPNR;

        Passenger.Reset();
        Passenger.SetRange("Return No.", CurrentReturnNo);
        Passenger.SetRange(PNR, CurrentPNR);

        if Passenger.FindLast() then
            Rec."SL No." := Passenger."SL No." + 1
        else
            Rec."SL No." := 1;
    end;

    procedure SetReturnNoAndPNR(ReturnNo: Code[50]; PNRNo: Text[10])
    begin
        CurrentReturnNo := ReturnNo;
        CurrentPNR := PNRNo;

        Rec.SetRange("Return No.", CurrentReturnNo);
        Rec.SetRange(PNR, CurrentPNR);
    end;

    var
        CurrentReturnNo: Code[50];
        CurrentPNR: Text[10];
}
