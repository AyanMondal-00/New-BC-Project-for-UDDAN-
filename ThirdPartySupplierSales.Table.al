table 50402 "Third-Party Supplier Sales"
{
    Caption = 'Third-Party Supplier Sales';
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

            trigger OnValidate()
            begin
                CalculateGST();
            end;
        }

        field(13; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateGST();
            end;
        }

        field(14; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateGST();
            end;
        }

        field(15; "Taxable Basis"; Decimal)
        {
            Caption = 'Taxable Basis';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(16; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(17; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(18; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(19; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
            Editable = false;
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
        ThirdPartySupplierSales: Record "Third-Party Supplier Sales";
    begin
        ThirdPartySupplierSales.Reset();
        if ThirdPartySupplierSales.FindLast() then
            if ThirdPartySupplierSales."Entry No." >= 1 then
                exit(ThirdPartySupplierSales."Entry No." + 1);

        exit(1);
    end;

    procedure CalculateGST()
    begin
        if Type = Type::Domestic then begin
            "Taxable Basis" := "Base Fare" * 0.05;
            CGST := "Taxable Basis" * 0.09;
            SGST := "Taxable Basis" * 0.09;
            IGST := 0;
        end else begin
            "Taxable Basis" := "Base Fare" * 0.10;
            CGST := 0;
            SGST := 0;
            IGST := "Taxable Basis" * 0.18;
        end;

        "Total Amount" := "Base Fare" + "Other Charges" + CGST + SGST + IGST;
    end;
}