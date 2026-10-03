table 50403 "Sales Return"
{
    Caption = 'Sales Return';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }

        field(3; "Bill No."; Code[50])
        {
            Caption = 'Bill No.';
            DataClassification = CustomerContent;
        }

        field(4; "Invoice No."; Code[50])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }

        field(5; "Return No."; Code[50])
        {
            Caption = 'Return No.';
            DataClassification = CustomerContent;
        }

        field(6; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(7; "A/C Name"; Text[100])
        {
            Caption = 'A/C Name';
            DataClassification = CustomerContent;
        }

        field(8; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }

        field(9; State; Text[50])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }

        field(10; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
        }

        field(11; Sector; Text[100])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(12; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Domestic,International;
            DataClassification = CustomerContent;
        }

        field(13; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(14; Time; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }

        field(15; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(16; "Airline Code"; Code[20])
        {
            Caption = 'Airline Code';
            DataClassification = CustomerContent;
        }

        field(17; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(18; Reference; Text[100])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(19; Narration; Text[250])
        {
            Caption = 'Narration';
            DataClassification = CustomerContent;
        }

        field(20; PAX; Integer)
        {
            Caption = 'PAX';
            DataClassification = CustomerContent;
        }

        field(21; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(22; "Taxable Value"; Decimal)
        {
            Caption = 'Taxable Value';
            DataClassification = CustomerContent;
        }

        field(23; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
        }

        field(24; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
        }

        field(25; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
        }

        field(26; "Sold Value"; Decimal)
        {
            Caption = 'Sold Value';
            DataClassification = CustomerContent;
        }

        field(27; "XXLN Charges"; Decimal)
        {
            Caption = 'XXLN Charges';
            DataClassification = CustomerContent;
        }

        field(28; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DataClassification = CustomerContent;
        }

        field(29; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionMembers = Own,ThirdParty;
            DataClassification = CustomerContent;
        }

        field(30; Supplier; Code[30])
        {
            Caption = 'Supplier';
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(PK; "Serial No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Serial No." <= 0 then
            "Serial No." := GetNextSerialNo();
    end;

    local procedure GetNextSerialNo(): Integer
    var
        SalesReturn: Record "Sales Return";
    begin
        SalesReturn.Reset();

        if SalesReturn.FindLast() then
            if SalesReturn."Serial No." >= 1 then
                exit(SalesReturn."Serial No." + 1);

        exit(1);
    end;
}
