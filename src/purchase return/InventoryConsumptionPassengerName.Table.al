table 50422 "Inventory Consumption Pasenger"
{
    Caption = 'Inventory Consumption Passenger Name';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Ref No./AQ Number"; Code[50])
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;
        }

        field(2; PNR; Code[10])
        {
            Caption = 'PNR';
            DataClassification = SystemMetadata;
        }

        field(3; "SL No."; Integer)
        {
            Caption = 'SL No.';
            DataClassification = SystemMetadata;
        }

        field(4; "Passenger Name"; Text[100])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Ref No./AQ Number", PNR, "SL No.")
        {
            Clustered = true;
        }
    }
}