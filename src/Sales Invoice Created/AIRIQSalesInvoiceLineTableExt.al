tableextension 50425 "AIRIQ Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50424; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(50425; Sector; Code[20])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(50426; FlightType; Option)
        {
            Caption = 'Flight Type';
            OptionMembers = Domestic,International;
            DataClassification = CustomerContent;
        }

        field(50427; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(50428; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
        }

        field(50429; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
        }

        field(50430; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
        }

        field(50431; "Passenger Name"; Text[2048])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }
    }
}