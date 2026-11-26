
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

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                    ToolTip = 'PNR must match the Sales Return PNR. This field is part of the passenger primary key; correct mismatches by recreating the affected passenger record.';
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Passenger: Record "Sales Return Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if EnforcePaxValidation then begin
            Passenger.LockTable();
            Passenger.SetRange("Return No.", CurrentReturnNo);
            Passenger.SetRange(PNR, CurrentPNR);
            PaxValidation.CheckInsertLimit(ExpectedPax, Passenger.Count());
        end;
        exit(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Passenger: Record "Sales Return Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if not EnforcePaxValidation then
            exit(true);

        Passenger.SetRange("Return No.", CurrentReturnNo);
        Passenger.SetRange(PNR, CurrentPNR);
        if Passenger.FindSet() then
            repeat
                PaxValidation.CheckFields(Passenger."Passenger Name", Passenger.ID, Passenger.Type, Passenger."SL No.");
            until Passenger.Next() = 0;

        PaxValidation.CheckExactCount(ExpectedPax, Passenger.Count());
        exit(true);
    end;

    procedure SetExpectedPax(PaxCount: Integer)
    begin
        ExpectedPax := PaxCount;
        EnforcePaxValidation := true;
    end;

    procedure SetReturnNoAndPNR(
        ReturnNo: Code[50];
        PNRNo: Text[10])
    begin
        CurrentReturnNo := ReturnNo;
        CurrentPNR := PNRNo;

        Rec.FilterGroup(2);
        Rec.SetRange("Return No.", CurrentReturnNo);
        Rec.SetRange(PNR, CurrentPNR);
        Rec.FilterGroup(0);
    end;

    var
        ExpectedPax: Integer;
        EnforcePaxValidation: Boolean;
        CurrentReturnNo: Code[50];
        CurrentPNR: Text[10];
}
