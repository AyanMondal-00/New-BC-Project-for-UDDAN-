
table 50359 "Purchase Return Serial Counter"
{
    Caption = 'Purchase Return Serial Counter';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }

        field(2; "Last Serial No."; Integer)
        {
            Caption = 'Last Serial No.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
