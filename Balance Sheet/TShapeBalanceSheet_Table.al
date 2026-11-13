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
        field(7; "Liability Node ID"; Integer)
        {
            Caption = 'Liability Node ID';
            DataClassification = SystemMetadata;
        }
        field(8; "Asset Node ID"; Integer)
        {
            Caption = 'Asset Node ID';
            DataClassification = SystemMetadata;
        }
        field(9; "Node Parent ID"; Integer)
        {
            Caption = 'Node Parent ID';
            DataClassification = SystemMetadata;
        }
        field(10; "Node Level"; Integer)
        {
            Caption = 'Node Level';
            DataClassification = SystemMetadata;
        }
        field(11; "Node Side"; Integer)
        {
            Caption = 'Node Side';
            DataClassification = SystemMetadata;
        }
        field(12; "Node Is Group"; Boolean)
        {
            Caption = 'Node Is Group';
            DataClassification = SystemMetadata;
        }
        field(13; "Node Expanded"; Boolean)
        {
            Caption = 'Node Expanded';
            DataClassification = SystemMetadata;
        }
        field(14; "Node G/L Account No."; Code[20])
        {
            Caption = 'Node G/L Account No.';
            DataClassification = SystemMetadata;
        }
        field(15; "Node Name"; Text[100])
        {
            Caption = 'Node Name';
            DataClassification = CustomerContent;
        }
        field(16; "Node Amount"; Decimal)
        {
            Caption = 'Node Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(17; "Node Is Profit"; Boolean)
        {
            Caption = 'Node Is Profit';
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
