table 50406 "Third Party Passenger Name"
{
    Caption = 'Third Party Passenger Name';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Ref No./AQ Number"; Integer)
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;
        }

        field(2; "PNR"; Text[10])
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
        key(PK; "Ref No./AQ Number", "PNR", "SL No.")
        {
            Clustered = true;
        }
    }
}
