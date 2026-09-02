table 50300 "Sample Purchase"
{
    Caption = 'Sample Purchase';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Purchase Date"; Date)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }

        field(3; "Entry Date"; Date)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }

        field(4; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(5; "Agency ID"; Code[20])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(6; PNR; Code[20])
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

                    CheckDuplicatePNR();
                end;
            end;
        }

        field(7; "Total Pax"; Integer)
        {
            Caption = 'Total Pax';
            DataClassification = CustomerContent;
        }

        field(8; "Travel Date"; Date)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;
        }

        field(9; Sector; Code[20])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(10; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;
        }

        field(11; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
        }

        field(12; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(13; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }

        field(14; Type; Option)
        {
            Caption = 'Type';
            OptionMembers = Domestic,International;
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
        SamplePurchase: Record "Sample Purchase";
    begin
        SamplePurchase.Reset();
        if SamplePurchase.FindLast() then
            if SamplePurchase."Entry No." >= 1 then
                exit(SamplePurchase."Entry No." + 1);

        exit(1);
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

        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, Rec.PNR);
        if Rec."Entry No." <> 0 then
            SamplePurchase.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
        if not SamplePurchase.IsEmpty() then
            Error('The PNR %1 already exists in Sample Purchase.', Rec.PNR);

        NormalSales.Reset();
        NormalSales.SetRange(PNR, Rec.PNR);
        if not NormalSales.IsEmpty() then
            Error('The PNR %1 already exists in Normal Sales.', Rec.PNR);

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