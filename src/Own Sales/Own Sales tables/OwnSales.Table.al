table 50400 "Normal Sales"
{
    Caption = 'Normal Sales';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
            Editable = false;
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
            trigger OnValidate()
            begin
                if "API Calculation" then
                    CalculateAmounts();
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

            trigger OnValidate()
            begin
                if "API Calculation" then
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
                if "API Calculation" then
                    CalculateAmounts();
            end;
        }

        field(13; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "API Calculation" then
                    CalculateAmounts();
            end;
        }

        field(14; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "API Calculation" then
                    CalculateAmounts();
            end;
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
    DataClassification = CustomerContent;
    Editable = true;

    trigger OnValidate()
    begin
        if "API Calculation" then
            CalculateAmounts();
    end;
}
        field(26; "API Calculation"; Boolean)
        {
            Caption = 'API Calculation';
            DataClassification = SystemMetadata;
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

    // ==========================================
    // INSERT - BC STANDARD NO. SERIES
    // ==========================================

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Serial No." = '' then
            "Serial No." :=
                NoSeries.GetNextNo('AIR-IQ-OS');

        if "API Calculation" then
            CalculateAmounts();
    end;

    trigger OnModify()
    begin
        if "API Calculation" then
            CalculateAmounts();
    end;

    // ==========================================
    // DELETE MATCHING OWN SALES PASSENGERS
    // ==========================================

    trigger OnDelete()
    var
        OwnSalesPassenger: Record "Own Sales Passenger Name";
    begin
        if Rec."Ref No./AQ Number" = 0 then
            exit;

        OwnSalesPassenger.Reset();

        OwnSalesPassenger.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        OwnSalesPassenger.SetRange(
            PNR,
            Rec.PNR);

        OwnSalesPassenger.DeleteAll(true);
    end;

    // ==========================================
    // RATE AND GST CALCULATION
    // ==========================================

    procedure CalculateAmounts()
    var
        SamplePurchase: Record "Sample Purchase";
        TotalBaseFare: Decimal;
        TotalGST: Decimal;
    begin
        if not "API Calculation" then
            exit;

        "Base Fare" := 0;
        "Taxable Basis" := 0;
        CGST := 0;
        SGST := 0;
        IGST := 0;
        "Other Charges" := 0;

        if (PNR = '') or (Pax <= 0) then
            exit;

        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, PNR);
        if not SamplePurchase.FindFirst() then
            exit; // Pending: subscriber will recalculate when purchase arrives.

        "Base Fare" := SamplePurchase."Base Fare";
        TotalBaseFare := "Base Fare" * Pax;

        case UpperCase(DelChr(Type, '<>', ' ')) of
            'DOMESTIC':
                begin
                    "Taxable Basis" := Round(TotalBaseFare * 0.05, 0.01);
                    CGST := Round("Taxable Basis" * 0.09, 0.01);
                    SGST := Round("Taxable Basis" * 0.09, 0.01);
                end;
            'INTERNATIONAL':
                begin
                    "Taxable Basis" := Round(TotalBaseFare * 0.10, 0.01);
                    IGST := Round("Taxable Basis" * 0.18, 0.01);
                end;
        end;

        TotalGST := CGST + SGST + IGST;
        "Other Charges" := Round("Total Amount" - TotalBaseFare - TotalGST, 0.01);
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

        if Rec."Serial No." <> '' then
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

        if Rec."Serial No." <> '' then
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
