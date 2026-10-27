table 50345 "Commission Management"
{
    DataClassification = CustomerContent;
    Caption = 'Commission Management';

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(3; "Commission %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Commission %';
            DecimalPlaces = 0 : 2;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}