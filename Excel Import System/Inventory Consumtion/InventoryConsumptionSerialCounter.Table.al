
table 50452 "Inv. Cons. Serial Cnt."
{
    Caption = 'Inventory Consumption Serial Counter';
    DataClassification = SystemMetadata;

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
            DataClassification = SystemMetadata;
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
