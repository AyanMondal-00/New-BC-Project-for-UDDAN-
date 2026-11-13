
table 50402 "Third-Party Supplier Sales"
{
    Caption = 'Third-Party Supplier Sales';
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
            begin
                SetCurrentTimeForDate(Rec."Date");
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
                CalculateTotalAmount();
            end;
        }

        field(10; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                SetCurrentTimeForDate(Rec."Travel Date");
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
        }

        field(13; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateTotalAmount();
            end;
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

    // ==========================================
    // BC STANDARD NO. SERIES - TP-SALES
    // ==========================================

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Serial No." = '' then
            "Serial No." :=
                NoSeries.GetNextNo('TP-SALES');

        CalculateTotalAmount();
    end;

    // ==========================================
    // AUTOMATIC PASSENGER DELETE
    // ==========================================

    trigger OnDelete()
    var
        ThirdPartyPassenger:
            Record "Third Party Passenger Name";
    begin
        if Rec."Ref No./AQ Number" = 0 then
            exit;

        ThirdPartyPassenger.Reset();

        ThirdPartyPassenger.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        ThirdPartyPassenger.SetRange(
            PNR,
            Rec.PNR);

        ThirdPartyPassenger.DeleteAll(true);
    end;

    // ==========================================
    // CURRENT TIME FOR DATE / TRAVEL DATE
    // ==========================================

    local procedure SetCurrentTimeForDate(
        var DateTimeValue: DateTime)
    var
        SelectedDate: Date;
        SelectedTime: Time;
    begin
        if DateTimeValue = 0DT then
            exit;

        SelectedDate := DT2Date(DateTimeValue);
        SelectedTime := DT2Time(DateTimeValue);

        if SelectedTime = 000000T then
            SelectedTime := DT2Time(CurrentDateTime());

        DateTimeValue :=
            CreateDateTime(
                SelectedDate,
                SelectedTime);
    end;

    // ==========================================
    // TOTAL AMOUNT = PAX * RATE
    // ==========================================

    local procedure CalculateTotalAmount()
    begin
        Rec."Total Amount" :=
            Rec.Pax * Rec.Rate;
    end;

    // ==========================================
    // EXISTING DUPLICATE PNR CHECK
    // ==========================================

    local procedure CheckDuplicatePNR()
    var
        SamplePurchase: Record "Sample Purchase";
        NormalSales: Record "Normal Sales";
        APISalesFormat: Record "API Sales Format";
        ThirdPartySupplierSales:
            Record "Third-Party Supplier Sales";
    begin
        if PNR = '' then
            exit;

        ThirdPartySupplierSales.Reset();

        ThirdPartySupplierSales.SetRange(
            PNR,
            Rec.PNR);

        if Rec."Serial No." <> '' then
            ThirdPartySupplierSales.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not ThirdPartySupplierSales.IsEmpty() then
            Error(
                'The PNR %1 already exists in Third-Party Supplier Sales.',
                Rec.PNR);

        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, Rec.PNR);

        if not SamplePurchase.IsEmpty() then
            Error(
                'The PNR %1 already exists in Sample Purchase.',
                Rec.PNR);

        NormalSales.Reset();
        NormalSales.SetRange(PNR, Rec.PNR);

        if not NormalSales.IsEmpty() then
            Error(
                'The PNR %1 already exists in Normal Sales.',
                Rec.PNR);

        APISalesFormat.Reset();
        APISalesFormat.SetRange(PNR, Rec.PNR);

        if not APISalesFormat.IsEmpty() then
            Error(
                'The PNR %1 already exists in API Sales Format.',
                Rec.PNR);
    end;

    // ==========================================
    // EXISTING DUPLICATE AQ NUMBER CHECK
    // ==========================================

    local procedure CheckDuplicateRefNoAQNumber()
    var
        NormalSales: Record "Normal Sales";
        APISalesFormat: Record "API Sales Format";
        ThirdPartySupplierSales:
            Record "Third-Party Supplier Sales";
    begin
        if "Ref No./AQ Number" = 0 then
            exit;

        ThirdPartySupplierSales.Reset();

        ThirdPartySupplierSales.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if Rec."Serial No." <> '' then
            ThirdPartySupplierSales.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not ThirdPartySupplierSales.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in Third-Party Supplier Sales.',
                Rec."Ref No./AQ Number");

        NormalSales.Reset();

        NormalSales.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

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
    end;
}
