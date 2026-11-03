table 50661 "Third Party Purchase Counter"
{
    Caption = 'Third Party Purchase Counter';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Counter Code"; Code[20]) { DataClassification = SystemMetadata; }
        field(2; "Last Serial No."; Integer) { DataClassification = SystemMetadata; }
    }
    keys
    {
        key(PK; "Counter Code") { Clustered = true; }
    }
}
