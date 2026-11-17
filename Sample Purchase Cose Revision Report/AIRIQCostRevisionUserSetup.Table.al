table 50540 "AIRIQ Cost Rev User Setup"
{
    Caption = 'Cost Revision User Setup';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "User ID"; Code[100])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(2; "Cost Revision Enable"; Boolean)
        {
            Caption = 'Cost Revision Enable';
            DataClassification = SystemMetadata;
        }
    }
    keys
    {
        key(PK; "User ID") { Clustered = true; }
    }
}
