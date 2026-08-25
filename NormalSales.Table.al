table 50400 "Normal Sales"
{
    Caption = 'Normal Sales';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }

        field(3; "Invoice Number"; Code[50])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
        }

        field(4; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(5; "Agency Name"; Text[100])
        {
            Caption = 'Agency Name';
            DataClassification = CustomerContent;
        }

        field(6; "Ref No./AQ Number"; Code[50])
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;
        }

        field(7; PNR; Code[20])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(8; Passenger; Text[100])
        {
            Caption = 'Passenger';
            DataClassification = CustomerContent;
        }

        field(9; Pax; Integer)
        {
            Caption = 'Pax';
            DataClassification = CustomerContent;
        }

        field(10; "Travel Date"; Date)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(11; Sector; Code[20])
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

        field(13; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(14; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(15; "Taxable Basis"; Decimal)
        {
            Caption = 'Taxable Basis';
            DataClassification = CustomerContent;
        }

        field(16; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
        }

        field(17; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
        }

        field(18; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
        }

        field(19; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        if "Entry No." <= 0 then
            "Entry No." := GetNextEntryNo();
    end;

    local procedure GetNextEntryNo(): Integer
    var
        NormalSales: Record "Normal Sales";
    begin
        NormalSales.Reset();
        if NormalSales.FindLast() then
            if NormalSales."Entry No." >= 1 then
                exit(NormalSales."Entry No." + 1);

        exit(1);
    end;
}