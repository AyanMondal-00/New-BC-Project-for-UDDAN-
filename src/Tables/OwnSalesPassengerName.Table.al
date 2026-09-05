table 50404 "Own Sales Passenger Name"
{
    Caption = 'Own Sales Passenger Name';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Ref No./AQ Number"; Code[50])
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;
        }

        field(2; "PNR"; Code[10])
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

        field(10; "Invoice Number"; Code[50])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Field is obsolete. Replaced by Ref No./AQ Number.';
        }

        field(11; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Field is obsolete. Replaced by SL No.';
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
