table 50732 "AIRIQ FS Preview Buffer"
{
    Caption = 'AIRIQ FS Preview Buffer';
    TableType = Temporary;
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; }
        field(2; "Statement Code"; Code[10]) { Caption = 'Statement'; }
        field(3; "Note No."; Code[10]) { Caption = 'Note'; }
        field(4; "Financial Heading"; Text[150]) { Caption = 'Financial Heading'; }
        field(5; "G/L Account No."; Code[20]) { Caption = 'G/L Account'; }
        field(6; "G/L Account Name"; Text[100]) { Caption = 'Account Name'; }
        field(7; Amount; Decimal) { Caption = 'Amount as at Date'; DecimalPlaces = 2 : 2; }
        field(8; "Finance Approved"; Boolean) { Caption = 'Mapping Approved'; }
    }
    keys { key(PK; "Entry No.") { Clustered = true; } }
}
