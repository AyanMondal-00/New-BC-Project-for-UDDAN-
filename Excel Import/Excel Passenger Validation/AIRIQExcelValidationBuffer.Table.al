table 50745 "AIRIQ Excel Validation Buffer"
{
    Caption = 'Excel Import Validation Error';
    TableType = Temporary;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Excel Row No."; Integer) { }
        field(3; "Excel Column No."; Integer) { }
        field(4; "Cell Reference"; Text[20]) { }
        field(5; PNR; Text[250]) { }
        field(6; "Passenger No."; Integer) { }
        field(7; "Field Name"; Text[100]) { }
        field(8; "Current Value"; Text[250]) { }
        field(9; "Error Reason"; Text[250]) { }
        field(10; "Correction Required"; Text[250]) { }
    }
    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ExcelLocation; "Excel Row No.", "Excel Column No.", "Passenger No.") { }
    }
}
