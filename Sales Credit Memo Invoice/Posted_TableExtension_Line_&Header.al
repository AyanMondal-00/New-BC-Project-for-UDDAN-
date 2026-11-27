tableextension 50718 "AIRIQ SR Posted Header" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(50715; "AIRIQ Return No."; Code[50])
        {
            Caption = 'AIRIQ Return No.';
            DataClassification = CustomerContent;
        }

        field(50716; "AIRIQ Return Serial"; Integer)
        {
            Caption = 'AIRIQ Return Serial';
            DataClassification = CustomerContent;
        }

        field(50717; "AIRIQ Bill No."; Code[50])
        {
            Caption = 'AIRIQ Bill No.';
            DataClassification = CustomerContent;
        }

        field(50718; "AIRIQ Original Invoice"; Code[50])
        {
            Caption = 'AIRIQ Original Invoice';
            DataClassification = CustomerContent;
        }

        field(50719; "AIRIQ Entry Date"; DateTime)
        {
            Caption = 'AIRIQ Entry Date';
            DataClassification = CustomerContent;
        }

        field(50720; "AIRIQ Reference"; Text[100])
        {
            Caption = 'AIRIQ Reference';
            DataClassification = CustomerContent;
        }

        field(50721; "AIRIQ Narration"; Text[250])
        {
            Caption = 'AIRIQ Narration';
            DataClassification = CustomerContent;
        }

        field(50722; "AIRIQ Supplier"; Code[30])
        {
            Caption = 'AIRIQ Supplier';
            DataClassification = CustomerContent;
        }

        field(50723; "AIRIQ Sale Type"; Option)
        {
            Caption = 'AIRIQ Sale Type';
            DataClassification = CustomerContent;
            OptionMembers = Own,ThirdParty;
        }
    }
}


tableextension 50719 "AIRIQ SR Posted Line" extends "Sales Cr.Memo Line"
{
    fields
    {
        // =========================================
        // ORIGINAL SALES LINE CUSTOM FIELDS
        // =========================================

        field(50424; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(50425; Sector; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(50426; FlightType; Text[50])
        {
            Caption = 'Flight Type';
            DataClassification = CustomerContent;
        }

        field(50427; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(50431; "Passenger Name"; Text[2048])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }

        field(50432; BaseFare; Text[50])
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        // =========================================
        // SALES RETURN / CREDIT MEMO CUSTOM FIELDS
        // =========================================

        field(50715; "AIRIQ Taxable Value"; Decimal)
        {
            Caption = 'AIRIQ Taxable Value';
            DataClassification = CustomerContent;
        }

        field(50716; "AIRIQ Source CGST"; Decimal)
        {
            Caption = 'AIRIQ Source CGST';
            DataClassification = CustomerContent;
        }

        field(50717; "AIRIQ Source SGST"; Decimal)
        {
            Caption = 'AIRIQ Source SGST';
            DataClassification = CustomerContent;
        }

        field(50718; "AIRIQ Source IGST"; Decimal)
        {
            Caption = 'AIRIQ Source IGST';
            DataClassification = CustomerContent;
        }

        field(50719; "AIRIQ Sold Value"; Decimal)
        {
            Caption = 'AIRIQ Sold Value';
            DataClassification = CustomerContent;
        }

        field(50720; "AIRIQ XXLN Charges"; Decimal)
        {
            Caption = 'AIRIQ XXLN Charges';
            DataClassification = CustomerContent;
        }

        field(50721; "AIRIQ Refund Amount"; Decimal)
        {
            Caption = 'AIRIQ Refund Amount';
            DataClassification = CustomerContent;
        }

        field(50722; "AIRIQ Country"; Text[50])
        {
            Caption = 'AIRIQ Country';
            DataClassification = CustomerContent;
        }

        field(50723; "AIRIQ State"; Text[50])
        {
            Caption = 'AIRIQ State';
            DataClassification = CustomerContent;
        }

        field(50724; "AIRIQ City"; Text[50])
        {
            Caption = 'AIRIQ City';
            DataClassification = CustomerContent;
        }

        field(50725; "AIRIQ Travel Time"; Time)
        {
            Caption = 'AIRIQ Travel Time';
            DataClassification = CustomerContent;
        }

        field(50726; "AIRIQ Airline"; Text[100])
        {
            Caption = 'AIRIQ Airline';
            DataClassification = CustomerContent;
        }

        field(50727; "AIRIQ Airline Code"; Code[20])
        {
            Caption = 'AIRIQ Airline Code';
            DataClassification = CustomerContent;
        }

        field(50728; "AIRIQ Reference"; Text[100])
        {
            Caption = 'AIRIQ Reference';
            DataClassification = CustomerContent;
        }

        field(50729; "AIRIQ Passenger Type"; Text[50])
        {
            Caption = 'AIRIQ Passenger Type';
            DataClassification = CustomerContent;
        }

        // AIRIQ Passenger SL intentionally not required.
    }
}