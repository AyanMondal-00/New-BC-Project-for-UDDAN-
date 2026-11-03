tableextension 50700 "AIRIQ Return Purch Header" extends "Purchase Header"
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


tableextension 50701 "AIRIQ Return Purch Line" extends "Purchase Line"
{
    fields
    {
        field(50700; "AIRIQ PNR"; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }
        field(50701; "AIRIQ Country"; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }
        field(50702; "AIRIQ Pax"; Integer)
        {
            Caption = 'Source Pax';
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


tableextension 50704 "AIRIQ Return Tracking" extends "Purchase Return"
{
    fields
    {
        field(50700; "AIRIQ Credit Memo Created"; Boolean)
        {
            Caption = 'Purchase Credit Memo Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50701; "AIRIQ Credit Memo No."; Code[20])
        {
            Caption = 'Purchase Credit Memo No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50702; "AIRIQ Vendor Cr. Memo No."; Code[20])
        {
            Caption = 'Vendor Credit Memo No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50703; "AIRIQ Posted Cr. Memo No."; Code[20])
        {
            Caption = 'Posted Purchase Credit Memo No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
