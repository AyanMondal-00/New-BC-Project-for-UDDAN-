
page 50416 "Third Party Name List"
{
    Caption = 'Third Party Passenger Name List';
    PageType = List;
    SourceTable = "Third Party Passenger Name";
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
        Passenger: Record "Third Party Passenger Name";
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

    procedure SetRefNoAQNumber(
        AQNumber: BigInteger;
        PNRNo: Text[10])
    begin
        CurrentRefNoAQNumber := AQNumber;
        CurrentPNR := PNRNo;

        Rec.FilterGroup(2);
        Rec.SetRange("Ref No./AQ Number", CurrentRefNoAQNumber);
        Rec.FilterGroup(0);
    end;

    var
        CurrentRefNoAQNumber: BigInteger;
        CurrentPNR: Text[10];
}
