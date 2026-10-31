table 50600 "hello"
{
    Caption = 'hello';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Agent ID"; Integer)
        {
            Caption = 'Agent ID';
            DataClassification = SystemMetadata;
            Editable = false;
        }
    }
}