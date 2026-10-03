table 50300 "Sample Purchase"
{
    Caption = 'Sample Purchase';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Purchase Date"; DateTime)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;
        }

        field(3; "Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;
        }

        field(4; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }
        //////////////////////////////////////////////////////////////////////////////
        field(5; "Agency ID"; Code[20])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
        }
        ///////////////////////////////////////////////////////////////////////////////        
        field(15; "Supplier ID"; Code[20])
        {
            Caption = 'Supplier ID';
            DataClassification = CustomerContent;
           

        }
  
                field(16; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
        }

        field(18; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Item Created"; Boolean)
        {
            Caption = 'Item Created';
            DataClassification = CustomerContent;
            Editable = false;
        }


        field(6; PNR; Text[10])
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

        field(8; "Travel Date"; DateTime)
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
        SamplePurchase: Record "Sample Purchase";
    begin
        SamplePurchase.Reset();
        if SamplePurchase.FindLast() then
            if SamplePurchase."Serial No." >= 1 then
                exit(SamplePurchase."Serial No." + 1);

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
        if Rec."Serial No." <> 0 then
            SamplePurchase.SetFilter("Serial No.", '<>%1', Rec."Serial No.");
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
