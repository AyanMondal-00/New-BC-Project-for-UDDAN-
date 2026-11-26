
page 50469 "TP Sales Return Passenger List"
{
    Caption = 'Third Party Sales Return Passenger';
    PageType = List;
    SourceTable = "TP Sales Return Passenger";
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            group(ReturnDetails)
            {
                Caption = 'Return Details';

                field(CurrentReturnNo; CurrentReturnNo)
                {
                    ApplicationArea = All;
                    Caption = 'Return No.';
                    Editable = false;
                }
                field(CurrentPNR; CurrentPNR)
                {
                    ApplicationArea = All;
                    Caption = 'PNR';
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
                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                    Caption = 'Passenger ID';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Caption = 'Passenger Type';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if CurrentReturnNo = '' then
            Error('Return No. is required.');

        if CurrentPNR = '' then
            Error('PNR is required.');

        Rec."Return No." := CurrentReturnNo;
        Rec.PNR := CurrentPNR;

        // SL No. generated in Table OnInsert.
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Passenger: Record "TP Sales Return Passenger";
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
        Passenger: Record "TP Sales Return Passenger";
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

    procedure SetReturnDetails(
        ReturnNumber: Code[50];
        PNRNumber: Text[50])
    begin
        CurrentReturnNo := ReturnNumber;
        CurrentPNR := PNRNumber;

        Rec.FilterGroup(2);
        Rec.SetRange("Return No.", CurrentReturnNo);
        Rec.SetRange(PNR, CurrentPNR);
        Rec.FilterGroup(0);
    end;

    var
        ExpectedPax: Integer;
        EnforcePaxValidation: Boolean;
        CurrentReturnNo: Code[50];
        CurrentPNR: Text[50];
}
