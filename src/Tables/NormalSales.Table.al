table 50400 "Normal Sales"
{
    Caption = 'Normal Sales';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
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

        field(4; "Supplier ID"; Code[30])
        {
            Caption = 'Supplier ID';
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

            trigger OnValidate()
            var
                ContainsLetter: Boolean;
                ContainsDigit: Boolean;
                i: Integer;
            begin
                if PNR <> '' then begin
                    if StrLen(PNR) <> 6 then
                        Error('The PNR length must be exactly 6 characters.');

                    for i := 1 to StrLen(PNR) do begin
                        if PNR[i] in ['A' .. 'Z'] then
                            ContainsLetter := true
                        else if PNR[i] in ['0' .. '9'] then
                            ContainsDigit := true
                        else
                            Error('The PNR must only contain alphanumeric characters.');
                    end;

                    if not (ContainsLetter and ContainsDigit) then
                        Error('The PNR must contain a mix of letters and numbers.');

                    
                end;
            end;
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
        NormalSales: Record "Normal Sales";
    begin
        NormalSales.Reset();
        if NormalSales.FindLast() then
            if NormalSales."Serial No." >= 1 then
                exit(NormalSales."Serial No." + 1);

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

    local procedure CheckDuplicatePNR()
    var
        SamplePurchase: Record "Sample Purchase";
        NormalSales: Record "Normal Sales";
        APISalesFormat: Record "API Sales Format";
        ThirdPartySupplierSales: Record "Third-Party Supplier Sales";
    begin
        if PNR = '' then
            exit;

        NormalSales.Reset();
        NormalSales.SetRange(PNR, Rec.PNR);
        if Rec."Serial No." <> 0 then
            NormalSales.SetFilter("Serial No.", '<>%1', Rec."Serial No.");
        if not NormalSales.IsEmpty() then
            Error('The PNR %1 already exists in Normal Sales.', Rec.PNR);

        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, Rec.PNR);
        if not SamplePurchase.IsEmpty() then
            Error('The PNR %1 already exists in Sample Purchase.', Rec.PNR);

        APISalesFormat.Reset();
        APISalesFormat.SetRange(PNR, Rec.PNR);
        if not APISalesFormat.IsEmpty() then
            Error('The PNR %1 already exists in API Sales Format.', Rec.PNR);

        ThirdPartySupplierSales.Reset();
        ThirdPartySupplierSales.SetRange(PNR, Rec.PNR);
        if not ThirdPartySupplierSales.IsEmpty() then
            Error('The PNR %1 already exists in Third-Party Supplier Sales.', Rec.PNR);
    end;
}
