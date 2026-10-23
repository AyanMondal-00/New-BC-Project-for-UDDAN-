table 50302 "Purchase Return"
{
    Caption = 'Purchase Return';
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

        field(3; "Purchase Date"; DateTime)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }

        field(4; "Voucher Number"; Code[50])
        {
            Caption = 'Voucher Number';
            DataClassification = CustomerContent;
        }

        field(5; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(6; "Airline ID"; Code[20])
        {
            Caption = 'Airline ID';
            DataClassification = CustomerContent;
        }

        field(7; "Airline Code"; Code[20])
        {
            Caption = 'Airline Code';
            DataClassification = CustomerContent;
        }

        field(8; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }

        field(9; Type; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        field(10; Sector; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(11; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(12; Reference; Text[100])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(13; Narration; Text[250])
        {
            Caption = 'Narration';
            DataClassification = CustomerContent;
        }

        field(14; Pax; Integer)
        {
            Caption = 'Pax';
            DataClassification = CustomerContent;
        }

        field(15; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(16; Others; Decimal)
        {
            Caption = 'Others';
            DataClassification = CustomerContent;
        }

        field(17; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;
        }

        field(18; Discount; Decimal)
        {
            Caption = 'Discount';
            DataClassification = CustomerContent;
        }

        field(19; "XXLN Charges"; Decimal)
        {
            Caption = 'XXLN Charges';
            DataClassification = CustomerContent;
        }

        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }

        field(21; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(22; "Departure Time"; Time)
        {
            Caption = 'Departure Time';
            DataClassification = CustomerContent;
        }

        field(23; "Arrival Time"; Time)
        {
            Caption = 'Arrival Time';
            DataClassification = CustomerContent;
        }

        field(24; "Flight No."; Code[30])
        {
            Caption = 'Flight No';
            DataClassification = CustomerContent;
        }

        field(25; "Name List"; Text[100])
        {
            Caption = 'Name List';
            DataClassification = CustomerContent;
        }

        field(26; "Cost Revision"; Option)
        {
            Caption = 'Cost Revision';
            OptionMembers = Yes,No;
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
        PurchaseReturn: Record "Purchase Return";
    begin
        PurchaseReturn.Reset();

        if PurchaseReturn.FindLast() then
            if PurchaseReturn."Serial No." >= 1 then
                exit(PurchaseReturn."Serial No." + 1);

        exit(1);
    end;
}
