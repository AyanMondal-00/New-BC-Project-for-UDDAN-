table 50337 "AIRIQ Invoice Counter"
{
    Caption = 'AIRIQ Invoice Counter';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Financial Year"; Code[5])
        {
            Caption = 'Financial Year';
        }

        field(2; "Last Invoice No."; BigInteger)
        {
            Caption = 'Last Invoice No.';
        }
    }

    keys
    {
        key(PK; "Financial Year")
        {
            Clustered = true;
        }
    }
}