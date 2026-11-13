table 50731 "AIRIQ FS Statement"
{
    Caption = 'AIRIQ Financial Statement Definition';
    DataClassification = CustomerContent;
    LookupPageId = "AIRIQ FS Statements";

    fields
    {
        field(1; Code; Code[10]) { Caption = 'Code'; }
        field(2; Description; Text[100]) { Caption = 'Description'; }
    }
    keys { key(PK; Code) { Clustered = true; } }
}
