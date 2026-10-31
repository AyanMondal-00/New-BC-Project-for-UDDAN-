table 50407 "Sales Return Passenger Name"
{
    Caption = 'Sales Return Passenger Name';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Return No."; Code[50])
        {
            Caption = 'Return No.';
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

        field(5; "ID"; BigInteger)
        {
            Caption = 'Passenger ID';
            DataClassification = CustomerContent;
        }

        field(6; "Type"; Text[50])
        {
            Caption = 'Passenger Type';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Return No.", "PNR", "SL No.")
        {
            Clustered = true;
        }

        key(SLNoLookup; "SL No.")
        {
        }
    }
}