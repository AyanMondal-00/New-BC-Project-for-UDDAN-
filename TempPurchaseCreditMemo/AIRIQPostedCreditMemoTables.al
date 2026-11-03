tableextension 50702 "AIRIQ Return Posted Header" extends "Purch. Cr. Memo Hdr."
{
    fields
    {
        field(50700; "AIRIQ Return Serial No."; Integer)
        {
            Caption = 'Source Purchase Return Serial No.';
            DataClassification = CustomerContent;
        }
        field(50701; "AIRIQ Voucher Number"; Code[50])
        {
            Caption = 'Voucher Number';
            DataClassification = CustomerContent;
        }
        field(50702; "AIRIQ Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }
        field(50703; "AIRIQ Purchase Date"; DateTime)
        {
            Caption = 'Original Purchase Date';
            DataClassification = CustomerContent;
        }
        field(50704; "AIRIQ Reference"; Text[100])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }
        field(50705; "AIRIQ Narration"; Text[250])
        {
            Caption = 'Narration';
            DataClassification = CustomerContent;
        }
        field(50706; "AIRIQ Airline ID"; Code[20])
        {
            Caption = 'Airline ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(AIRIQReturn; "AIRIQ Return Serial No.") { }
    }
}


tableextension 50703 "AIRIQ Return Posted Line" extends "Purch. Cr. Memo Line"
{
    fields
    {
        field(50700; "AIRIQ PNR"; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }
        field(50329; "Sample Sector"; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }
        field(50701; "AIRIQ Country"; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(50330; "Sample Flight Type"; Text[50])
        {
            Caption = 'Travel Type';
            DataClassification = CustomerContent;
        }
        field(50702; "AIRIQ Pax"; Integer)
        {
            Caption = 'Source Pax';
            DataClassification = CustomerContent;
        }
        field(50332; "Sample Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }
        field(50333; "Sample Other Charges"; Decimal)
        {
            Caption = 'Others';
            DataClassification = CustomerContent;
        }
        field(50703; "AIRIQ Rate"; Decimal)
        {
            Caption = 'Source Rate';
            DataClassification = CustomerContent;
        }
        field(50704; "AIRIQ Discount"; Decimal)
        {
            Caption = 'Source Discount';
            DataClassification = CustomerContent;
        }
        field(50705; "AIRIQ XXLN Charges"; Decimal)
        {
            Caption = 'XXLN Charges';
            DataClassification = CustomerContent;
        }
        field(50706; "AIRIQ Return Amount"; Decimal)
        {
            Caption = 'Source Return Amount';
            DataClassification = CustomerContent;
        }
        field(50326; "Sample Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }
        field(50707; "AIRIQ Flight No."; Code[30])
        {
            Caption = 'Flight No.';
            DataClassification = CustomerContent;
        }
        field(50708; "AIRIQ Departure Time"; Time)
        {
            Caption = 'Departure Time';
            DataClassification = CustomerContent;
        }
        field(50709; "AIRIQ Arrival Time"; Time)
        {
            Caption = 'Arrival Time';
            DataClassification = CustomerContent;
        }
        field(50710; "AIRIQ Cost Revision"; Option)
        {
            Caption = 'Cost Revision';
            DataClassification = CustomerContent;
            OptionMembers = Yes,No;
        }
    }

}
