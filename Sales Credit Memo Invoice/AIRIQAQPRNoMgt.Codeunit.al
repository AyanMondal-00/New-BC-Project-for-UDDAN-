table 50700 "AIRIQ AQPR Reservation"
{
    Caption = 'AIRIQ AQPR Reservation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Number"; Code[20])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Number")
        {
            Clustered = true;
        }
    }
}