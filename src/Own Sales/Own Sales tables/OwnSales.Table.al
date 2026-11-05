
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

        field(2; "Date"; DateTime)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Date");

                if DT2Time(Rec."Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Date");

                Rec."Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
            end;
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
            ObsoleteState = Removed;
        }

        field(22; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(5; "Agency Name"; Text[100])
        {
            Caption = 'Agency Name';
            DataClassification = CustomerContent;
        }

        field(6; "Ref No./AQ Number"; BigInteger)
        {
            Caption = 'Ref No./AQ Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckDuplicateRefNoAQNumber();
            end;
        }

        field(23; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
        }

        field(24; "Sales Invoice Created"; Boolean)
        {
            Caption = 'Sales Invoice Created';
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

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(10; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Travel Date");

                if DT2Time(Rec."Travel Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Travel Date");

                Rec."Travel Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
            end;
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

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(13; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(14; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        // NEW RATE FIELD
        field(25; "Rate"; Decimal)
        {
            Caption = 'Rate';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(15; "Taxable Basis"; Decimal)
        {
            Caption = 'Taxable Basis';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(16; CGST; Decimal)
        {
            Caption = 'CGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(17; SGST; Decimal)
        {
            Caption = 'SGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(18; IGST; Decimal)
        {
            Caption = 'IGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(19; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
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

        CalculateAmounts();
    end;

    trigger OnModify()
    begin
        CalculateAmounts();
    end;

    // ==========================================
    // SERIAL NUMBER GENERATION
    // ==========================================

    local procedure GetNextSerialNo(): Integer
    var
        NormalSales: Record "Normal Sales";
    begin
        NormalSales.Reset();
        NormalSales.SetCurrentKey("Serial No.");

        if NormalSales.FindLast() then
            exit(NormalSales."Serial No." + 1);

        exit(1);
    end;

    // ==========================================
    // RATE AND GST CALCULATION
    // ==========================================

    procedure CalculateAmounts()
    var
        TotalBaseFare: Decimal;
    begin
        TotalBaseFare := "Base Fare" * Pax;

        // Rate Calculation
        Rate := ("Base Fare" + "Other Charges") * Pax;

        // Total Amount excludes separately calculated GST
        "Total Amount" := Rate;

        // Reset GST Values
        "Taxable Basis" := 0;
        CGST := 0;
        SGST := 0;
        IGST := 0;

        case UpperCase(DelChr(Type, '<>', ' ')) of

            'DOMESTIC':
                begin
                    // Taxable Basis = Base Fare * Pax * 5%
                    "Taxable Basis" := TotalBaseFare * 5 / 100;

                    // CGST = Taxable Basis * 9%
                    CGST := "Taxable Basis" * 9 / 100;

                    // SGST = Taxable Basis * 9%
                    SGST := "Taxable Basis" * 9 / 100;
                end;

            'INTERNATIONAL':
                begin
                    // Taxable Basis = Base Fare * Pax * 10%
                    "Taxable Basis" := TotalBaseFare * 10 / 100;

                    // IGST = Taxable Basis * 18%
                    IGST := "Taxable Basis" * 18 / 100;
                end;
        end;
    end;

    // ==========================================
    // DUPLICATE PNR CHECK
    // ==========================================

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
            NormalSales.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not NormalSales.IsEmpty() then
            Error(
                'The PNR %1 already exists in Normal Sales.',
                Rec.PNR);

        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, Rec.PNR);

        if not SamplePurchase.IsEmpty() then
            Error(
                'The PNR %1 already exists in Sample Purchase.',
                Rec.PNR);

        APISalesFormat.Reset();
        APISalesFormat.SetRange(PNR, Rec.PNR);

        if not APISalesFormat.IsEmpty() then
            Error(
                'The PNR %1 already exists in API Sales Format.',
                Rec.PNR);

        ThirdPartySupplierSales.Reset();
        ThirdPartySupplierSales.SetRange(PNR, Rec.PNR);

        if not ThirdPartySupplierSales.IsEmpty() then
            Error(
                'The PNR %1 already exists in Third-Party Supplier Sales.',
                Rec.PNR);
    end;

    // ==========================================
    // DUPLICATE AQ NUMBER CHECK
    // ==========================================

    local procedure CheckDuplicateRefNoAQNumber()
    var
        NormalSales: Record "Normal Sales";
        APISalesFormat: Record "API Sales Format";
        ThirdPartySupplierSales: Record "Third-Party Supplier Sales";
    begin
        if "Ref No./AQ Number" = 0 then
            exit;

        NormalSales.Reset();
        NormalSales.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if Rec."Serial No." <> 0 then
            NormalSales.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not NormalSales.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in Normal Sales.',
                Rec."Ref No./AQ Number");

        APISalesFormat.Reset();
        APISalesFormat.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if not APISalesFormat.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in API Sales Format.',
                Rec."Ref No./AQ Number");

        ThirdPartySupplierSales.Reset();
        ThirdPartySupplierSales.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if not ThirdPartySupplierSales.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in Third-Party Supplier Sales.',
                Rec."Ref No./AQ Number");
    end;
}
