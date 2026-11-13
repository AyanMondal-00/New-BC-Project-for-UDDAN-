table 50462 "AIRIQ P&L Vertical"
{
    Caption = 'AIRIQ P&L Vertical';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Expense Account"; Text[100])
        {
            Caption = 'Expense Account';
            DataClassification = CustomerContent;
        }
        field(3; "Expense Amount"; Decimal)
        {
            Caption = 'Expense Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(4; "Income Account"; Text[100])
        {
            Caption = 'Income Account';
            DataClassification = CustomerContent;
        }
        field(5; "Income Amount"; Decimal)
        {
            Caption = 'Income Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 2;
        }
        field(6; "Is Total"; Boolean)
        {
            Caption = 'Is Total';
            DataClassification = SystemMetadata;
        }
        field(7; "Expense Node ID"; Integer)
        {
            Caption = 'Liability Node ID';
            DataClassification = SystemMetadata;
        }
        field(8; "Income Node ID"; Integer)
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
