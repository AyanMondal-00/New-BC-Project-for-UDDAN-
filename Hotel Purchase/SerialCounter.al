
table 50443 "Hotel Purchase Serial Counter"
{
    Caption = 'Hotel Purchase Serial Counter';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Counter Code"; Code[20])
        {
            Caption = 'Counter Code';
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
