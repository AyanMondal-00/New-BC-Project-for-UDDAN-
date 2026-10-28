
tableextension 50340 "Posted Purch Inv Subform Ext" extends "Purch. Inv. Line"
{
    fields
    {
        field(50324; "Sample Purchase Date"; DateTime)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }

        field(50325; "Sample Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }

        field(50326; "Sample Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(50327; "Sample Airline"; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(50329; "Sample Sector"; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(50330; "Sample Flight Type"; Text[50])
        {
            Caption = 'Flight Type';
            DataClassification = CustomerContent;
        }

        field(50331; "Sample Supplier ID"; Code[20])
        {
            Caption = 'Supplier ID';
            DataClassification = CustomerContent;
        }

        field(50332; "Sample Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(50333; "Sample Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }
    }
}
