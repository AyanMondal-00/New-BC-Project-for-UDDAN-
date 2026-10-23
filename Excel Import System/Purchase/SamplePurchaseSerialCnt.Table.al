table 50331 "Sample Purchase Serial Cnt."
{
    Caption = 'Sample Purchase Serial Counter';
    DataClassification = CustomerContent;

    fields
    {
          field(1; "Counter Code"; Code[20])
        {
            Caption = 'Counter Code';
            DataClassification = SystemMetadata;
        }

        field(2; "Last Serial No."; Integer)
        {
            Caption = 'Last Serial No.';
        }
    }

    keys
    {
        key(PK; "Counter Code")
        {
            Clustered = true;
        }
    }
}