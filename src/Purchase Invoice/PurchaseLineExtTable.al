tableextension 50323 "Purchase Line Ext" extends "Purchase Line"
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

        field(50329; "Sample Sector"; Code[20])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }
        field(50330; "Sample Flight Type"; Option)
        {
            Caption = 'Flight Type';
            OptionMembers = Domestic,International;
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