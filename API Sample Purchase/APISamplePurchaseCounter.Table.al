table 50306 "API Sample Purchase Counter"
{
    Caption = 'API Sample Purchase Counter';
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
