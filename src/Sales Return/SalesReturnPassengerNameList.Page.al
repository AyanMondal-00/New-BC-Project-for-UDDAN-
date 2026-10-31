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
            repeater(General)
            {
                field("SL No."; Rec."SL No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Passenger Name"; Rec."Passenger Name")
                {
                    ApplicationArea = All;
                }

                field("Passenger ID"; Rec.ID)
                {
                    ApplicationArea = All;
                    Caption = 'Passenger ID';
                }

                field("Passenger Type"; Rec.Type)
                {
                    ApplicationArea = All;
                    Caption = 'Passenger Type';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("SL No.");
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Passenger: Record "Sales Return Passenger Name";
    begin
        if CurrentReturnNo = '' then
            Error('Return No. is required to add a passenger.');

        Rec."Return No." := CurrentReturnNo;
        Rec.PNR := CurrentPNR;

        Passenger.LockTable();
        Passenger.Reset();
        Passenger.SetCurrentKey("SL No.");

        if Passenger.FindLast() then
            Rec."SL No." := Passenger."SL No." + 1
        else
            Rec."SL No." := 1;
    end;

    procedure SetReturnNoAndPNR(
        ReturnNo: Code[50];
        PNRNo: Text[10])
    begin
        CurrentReturnNo := ReturnNo;
        CurrentPNR := PNRNo;

        Rec.FilterGroup(2);
        Rec.SetRange("Return No.", CurrentReturnNo);
        Rec.FilterGroup(0);
    end;

    var
        CurrentReturnNo: Code[50];
        CurrentPNR: Text[10];
}