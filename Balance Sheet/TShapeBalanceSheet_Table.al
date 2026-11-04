
table 50461 "AIRIQ Vertical Balance Sheet"
{
    Caption = 'AIRIQ Vertical Balance Sheet';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Liability Account"; Text[100])
        {
            Caption = 'Liability Account';
            DataClassification = CustomerContent;
        }

        field(3; "Liability Amount"; Decimal)
        {
            Caption = 'Liability Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }

        field(4; "Asset Account"; Text[100])
        {
            Caption = 'Asset Account';
            DataClassification = CustomerContent;
        }

        field(5; "Asset Amount"; Decimal)
        {
            Caption = 'Asset Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }

        field(6; "Is Total"; Boolean)
        {
            Caption = 'Is Total';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
