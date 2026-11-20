
table 50541 "AIRIQ Cost Revision History"
{
    Caption = 'Purchase Cost Revision Statement';
    DataClassification = CustomerContent;
    DrillDownPageId = "AIRIQ Cost Revision Statement";
    LookupPageId = "AIRIQ Cost Revision Statement";

    fields
    {
        field(1; "Cost Revision No."; Code[20])
        {
            Caption = 'Cost Revision No.';
            DataClassification = CustomerContent;
        }
        field(2; "Revision Date & Time"; DateTime)
        {
            Caption = 'Revision Date & Time';
            DataClassification = CustomerContent;
        }
        field(3; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }
        field(4; "Revision No."; Integer)
        {
            Caption = 'Revision No.';
            DataClassification = CustomerContent;
        }
        field(5; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            OptionMembers = Opening,Increase,Decrease,Adjustment;
            OptionCaption = 'Opening,Increase,Decrease,Adjustment';
            DataClassification = CustomerContent;
        }
        field(6; "Previous Base Fare"; Decimal)
        {
            Caption = 'Previous Base Fare';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(7; "Revised Base Fare"; Decimal)
        {
            Caption = 'Revised Base Fare';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(8; "Fare Difference"; Decimal)
        {
            Caption = 'Fare Difference (+/-)';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(9; "Total Pax"; Integer)
        {
            Caption = 'Total Pax';
            DataClassification = CustomerContent;
        }
        field(10; "Previous Other Charges"; Decimal)
        {
            Caption = 'Previous Other Charges';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(11; "Revised Other Charges"; Decimal)
        {
            Caption = 'Revised Other Charges';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(12; "Previous Rate"; Decimal)
        {
            Caption = 'Previous Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(13; "Revised Rate"; Decimal)
        {
            Caption = 'Revised Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(14; "Previous Total Amount"; Decimal)
        {
            Caption = 'Previous Total Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(15; "Revised Total Amount"; Decimal)
        {
            Caption = 'Revised Total Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 2 : 5;
        }
        field(16; "Revision Source"; Text[50])
        {
            Caption = 'Revision Source';
            DataClassification = CustomerContent;
        }
        field(17; "Changed By"; Code[100])
        {
            Caption = 'Changed By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; "Purchase Serial No."; Code[20])
        {
            Caption = 'Purchase Serial No.';
            DataClassification = CustomerContent;
        }
        field(19; "Previous Total Pax"; Integer)
        {
            Caption = 'Previous Total Pax';
            DataClassification = CustomerContent;
        }
        field(20; AirLine; Text[100])
        {
            Caption = 'AirLine';
            DataClassification = CustomerContent;
        }
        field(21; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Cost Revision No.")
        {
            Clustered = true;
        }
        key(PNRRevision; PNR, "Revision No.")
        {
            Unique = true;
        }
        key(DateOrder; "Revision Date & Time")
        {
        }
        key(PurchaseSource; "Purchase Serial No.", "Revision No.")
        {
        }
    }
}
