table 50420 "Inventory Consumption"
{
    Caption = 'Inventory Consumption';
    DataClassification = CustomerContent;

    fields
    {
        field(20; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
        }
        field(21; "Purchase Return Order Created"; Boolean)
        {
            Caption = 'Purchase Return Order Created';
            DataClassification = CustomerContent;
        }

        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Date"; DateTime)
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
        
        field(22; "Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
            DataClassification = CustomerContent;
        }

        field(6; "Ref No./AQ Number"; Integer)
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;
        }

        field(7; PNR; Text[10])
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

        field(10; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(11; Sector; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(12; Type; Text[50])
        {
            Caption = 'Type';
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
        InventoryConsumption: Record "Inventory Consumption";
    begin
        InventoryConsumption.Reset();

        if InventoryConsumption.FindLast() then
            if InventoryConsumption."Serial No." >= 1 then
                exit(InventoryConsumption."Serial No." + 1);

        exit(1);
    end;
}