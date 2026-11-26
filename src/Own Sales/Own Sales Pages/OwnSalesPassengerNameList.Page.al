
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
                field("SL No."; Rec."SL No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Ref No./AQ Number"; Rec."Ref No./AQ Number")
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
        Passenger: Record "Own Sales Passenger Name";
    begin
        if CurrentRefNoAQNumber = 0 then
            Error('Ref No./AQ Number is required.');

        Rec."Ref No./AQ Number" := CurrentRefNoAQNumber;
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
        Passenger: Record "Own Sales Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if EnforcePaxValidation then begin
            Passenger.LockTable();
            Passenger.SetRange("Ref No./AQ Number", CurrentRefNoAQNumber);
            Passenger.SetRange(PNR, CurrentPNR);
            PaxValidation.CheckInsertLimit(ExpectedPax, Passenger.Count());
        end;
        exit(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Passenger: Record "Own Sales Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if not EnforcePaxValidation then
            exit(true);

        Passenger.SetRange("Ref No./AQ Number", CurrentRefNoAQNumber);
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

    procedure SetRefNoAQNumber(
        AQNumber: BigInteger;
        PNRNo: Text[10])
    begin
        CurrentRefNoAQNumber := AQNumber;
        CurrentPNR := PNRNo;

        Rec.FilterGroup(2);
        Rec.SetRange("Ref No./AQ Number", CurrentRefNoAQNumber);
        Rec.SetRange(PNR, CurrentPNR);
        Rec.FilterGroup(0);
    end;

    var
        ExpectedPax: Integer;
        EnforcePaxValidation: Boolean;
        CurrentRefNoAQNumber: BigInteger;
        CurrentPNR: Text[10];
}
