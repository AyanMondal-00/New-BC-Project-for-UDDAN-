table 50337 "AIRIQ Invoice Counter"
{
    Caption = 'AIRIQ Invoice Counter';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Financial Year"; Code[5])
        {
            Caption = 'Financial Year';

            trigger OnValidate()
            begin
                if StrLen("Financial Year") <> 5 then
                    Error('Financial Year format must be YY-YY (e.g. 24-25).');

                if CopyStr("Financial Year", 3, 1) <> '-' then
                    Error('Financial Year format must be YY-YY (e.g. 24-25).');
            end;
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