table 50747 "AIRIQ BS Party Balance Buffer"
{
    Caption = 'AIRIQ BS Party Balance Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Party Type"; Option)
        {
            Caption = 'Party Type';
            OptionMembers = Customer,Vendor;
            OptionCaption = 'Customer,Vendor';
            DataClassification = SystemMetadata;
        }
        field(2; "Party No."; Code[20])
        {
            Caption = 'Party No.';
            DataClassification = CustomerContent;
        }
        field(3; "Party Name"; Text[100])
        {
            Caption = 'Party Name';
            DataClassification = CustomerContent;
        }
        field(4; "Balance (LCY)"; Decimal)
        {
            Caption = 'Balance (LCY)';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Party Type", "Party No.") { Clustered = true; }
    }
}
