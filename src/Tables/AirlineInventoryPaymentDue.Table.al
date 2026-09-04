table 50303 "Airline Inventory Payment Due"
{
    Caption = 'Airline Inventory and Payment Due Format';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }

        field(3; "Travel Date"; Date)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(4; Sector; Code[20])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(5; PNR; Code[20])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(6; "PAX Count"; Integer)
        {
            Caption = 'PAX Count';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(7; "Per PAX Rate"; Decimal)
        {
            Caption = 'Per PAX Rate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(8; "Total Value"; Decimal)
        {
            Caption = 'Total Value';
            DataClassification = CustomerContent;
        }

        field(9; "Amount Paid"; Decimal)
        {
            Caption = 'Amount Paid';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateBalanceDue();
            end;
        }

        field(10; "Balance Due"; Decimal)
        {
            Caption = 'Balance Due';
            DataClassification = CustomerContent;
        }

        field(11; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(12; "Agency ID"; Code[20])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(13; Remark; Text[50])
        {
            Caption = 'Remark';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Serial No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Serial No." <= 0 then
            "Serial No." := GetNextSerialNo();

        CalculateAmounts();
    end;

    local procedure GetNextSerialNo(): Integer
    var
        AirlineInventoryPaymentDue: Record "Airline Inventory Payment Due";
    begin
        AirlineInventoryPaymentDue.Reset();

        if AirlineInventoryPaymentDue.FindLast() then
            if AirlineInventoryPaymentDue."Serial No." >= 1 then
                exit(AirlineInventoryPaymentDue."Serial No." + 1);

        exit(1);
    end;

    local procedure CalculateAmounts()
    begin
        "Total Value" := "PAX Count" * "Per PAX Rate";
        CalculateBalanceDue();
    end;

    local procedure CalculateBalanceDue()
    begin
        "Balance Due" := "Total Value" - "Amount Paid";

        if "Balance Due" = 0 then
            Remark := 'NO DUE'
        else
            if "Balance Due" > 0 then
                Remark := 'PAYMENT PENDING'
            else
                Remark := 'EXCESS PAYMENT';
    end;
}
