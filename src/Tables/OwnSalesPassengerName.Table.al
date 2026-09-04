table 50404 "Own Sales Passenger Name"
{
    Caption = 'Own Sales Passenger Name';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Invoice Number"; Code[50])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
        }

        field(2; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(3; "Passenger Name"; Text[100])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Invoice Number", "Serial No.")
        {
            Clustered = true;
        }
    }
}
