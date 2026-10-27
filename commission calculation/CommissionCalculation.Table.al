
table 50451 "Commission Calculation"
{
    Caption = 'Commission Calculation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(3; PNR; Text[100])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(4; Purchase; Decimal)
        {
            Caption = 'Purchase';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCommissions();
            end;
        }

        field(5; "Purchase Return"; Decimal)
        {
            Caption = 'Purchase Return';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCommissions();
            end;
        }

        field(6; "Available Commission"; Decimal)
        {
            Caption = 'Available Commission';
            DataClassification = CustomerContent;
        }

        field(7; "Commission Percentage"; Decimal)
        {
            Caption = 'Commission Percentage';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateTotalCommission();
            end;
        }

        field(8; "Total Commission"; Decimal)
        {
            Caption = 'Total Commission';
            DataClassification = CustomerContent;
        }

        field(9; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
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
        if "Serial No." = 0 then
            "Serial No." := GetNextSerialNo();

        CalculateCommissions();
    end;

    trigger OnModify()
    begin
        CalculateCommissions();
    end;

    local procedure GetNextSerialNo(): Integer
    var
        CommissionRec: Record "Commission Calculation";
    begin
        CommissionRec.LockTable();
        CommissionRec.Reset();
        CommissionRec.SetCurrentKey("Serial No.");

        if CommissionRec.FindLast() then
            exit(CommissionRec."Serial No." + 1)
        else
            exit(1);
    end;

    local procedure CalculateCommissions()
    begin
        "Available Commission" := Purchase - "Purchase Return";
        CalculateTotalCommission();
    end;

    local procedure CalculateTotalCommission()
    begin
        "Total Commission" :=
            "Available Commission" * "Commission Percentage" / 100;
    end;
}
