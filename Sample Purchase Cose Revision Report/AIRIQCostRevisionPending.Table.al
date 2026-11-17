table 50544 "AIRIQ Cost Revision Pending"
{
    Caption = 'Cost Revision Pending Snapshot';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "User ID"; Code[100]) { DataClassification = EndUserIdentifiableInformation; }
        field(2; "Purchase Serial No."; Code[20]) { DataClassification = CustomerContent; }
        field(3; "Previous Base Fare"; Decimal) { DataClassification = CustomerContent; }
        field(4; "Previous Other Charges"; Decimal) { DataClassification = CustomerContent; }
        field(5; "Previous Rate"; Decimal) { DataClassification = CustomerContent; }
        field(6; "Previous Total Amount"; Decimal) { DataClassification = CustomerContent; }
        field(7; "Previous Total Pax"; Integer) { DataClassification = CustomerContent; }
        field(8; "Started At"; DateTime) { DataClassification = CustomerContent; }
    }
    keys { key(PK; "User ID", "Purchase Serial No.") { Clustered = true; } }
}
