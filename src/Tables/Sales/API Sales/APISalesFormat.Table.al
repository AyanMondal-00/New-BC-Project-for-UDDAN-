
table 50401 "API Sales Format"
{
    Caption = 'API Sales Format';
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
                SelectedTime: Time;
            begin
                if Rec."Date" = 0DT then
                    exit;

                SelectedDate := DT2Date(Rec."Date");
                SelectedTime := DT2Time(Rec."Date");

                if SelectedTime = 0T then
                    SelectedTime := DT2Time(CurrentDateTime());

                Rec."Date" :=
                    CreateDateTime(SelectedDate, SelectedTime);
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
        }

        field(10; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                SelectedTime: Time;
            begin
                if Rec."Travel Date" = 0DT then
                    exit;

                SelectedDate := DT2Date(Rec."Travel Date");
                SelectedTime := DT2Time(Rec."Travel Date");

                if SelectedTime = 0T then
                    SelectedTime := DT2Time(CurrentDateTime());

                Rec."Travel Date" :=
                    CreateDateTime(SelectedDate, SelectedTime);
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
    // BC STANDARD NO. SERIES - API-SALES
    // ==========================================

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        if "Serial No." = '' then
            "Serial No." :=
                NoSeries.GetNextNo('API-SALES');
    end;

    // ==========================================
    // AUTOMATIC PASSENGER DELETE
    // ==========================================

    trigger OnDelete()
    var
        APISalesPassenger: Record "API Sales Passenger Name";
    begin
        if Rec."Ref No./AQ Number" = 0 then
            exit;

        APISalesPassenger.Reset();

        APISalesPassenger.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        APISalesPassenger.SetRange(PNR, Rec.PNR);

        APISalesPassenger.DeleteAll(true);
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

        APISalesFormat.Reset();
        APISalesFormat.SetRange(PNR, Rec.PNR);

        if Rec."Serial No." <> '' then
            APISalesFormat.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not APISalesFormat.IsEmpty() then
            Error(
                'The PNR %1 already exists in API Sales Format.',
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

        ThirdPartySupplierSales.Reset();
        ThirdPartySupplierSales.SetRange(PNR, Rec.PNR);

        if not ThirdPartySupplierSales.IsEmpty() then
            Error(
                'The PNR %1 already exists in Third-Party Supplier Sales.',
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

        APISalesFormat.Reset();
        APISalesFormat.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if Rec."Serial No." <> '' then
            APISalesFormat.SetFilter(
                "Serial No.",
                '<>%1',
                Rec."Serial No.");

        if not APISalesFormat.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in API Sales Format.',
                Rec."Ref No./AQ Number");

        NormalSales.Reset();
        NormalSales.SetRange(
            "Ref No./AQ Number",
            Rec."Ref No./AQ Number");

        if not NormalSales.IsEmpty() then
            Error(
                'The Ref No./AQ Number %1 already exists in Normal Sales.',
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
