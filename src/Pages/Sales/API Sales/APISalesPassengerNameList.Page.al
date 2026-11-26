
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
            group(Reference)
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

                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
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
        Passenger.SetRange(
            "Ref No./AQ Number", CurrentRefNo_AQNumber);
        Passenger.SetRange(PNR, CurrentPNR);

        if Passenger.FindLast() then
            Rec."SL No." := Passenger."SL No." + 1
        else
            Rec."SL No." := 1;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        Passenger: Record "API Sales Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if EnforcePaxValidation then begin
            Passenger.LockTable();
            Passenger.SetRange("Ref No./AQ Number", CurrentRefNo_AQNumber);
            Passenger.SetRange(PNR, CurrentPNR);
            PaxValidation.CheckInsertLimit(ExpectedPax, Passenger.Count());
        end;
        exit(true);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Passenger: Record "API Sales Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
    begin
        if not EnforcePaxValidation then
            exit(true);

        Passenger.SetRange("Ref No./AQ Number", CurrentRefNo_AQNumber);
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
        CurrentRefNo_AQNumber := AQNumber;
        CurrentPNR := PNRNo;

        Rec.FilterGroup(2);
        Rec.SetRange(
            "Ref No./AQ Number", CurrentRefNo_AQNumber);
        Rec.SetRange(PNR, CurrentPNR);
        Rec.FilterGroup(0);
    end;

    var
        ExpectedPax: Integer;
        EnforcePaxValidation: Boolean;
        CurrentRefNo_AQNumber: BigInteger;
        CurrentPNR: Text[10];
}
