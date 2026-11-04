
table 50440 "Hotel Purchase"
{
    Caption = 'Hotel Purchase';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
            Editable = false;
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

        field(15; "Voucher Number"; Code[50])
        {
            Caption = 'Voucher Number';
            DataClassification = CustomerContent;
            NotBlank = true;

            trigger OnValidate()
            begin
                CheckDuplicateVoucherNumber();
            end;
        }

        field(4; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            InitValue = false;
        }

        field(5; "Invoice Created"; Text[3])
        {
            Caption = 'Invoice Created';
            DataClassification = CustomerContent;
            InitValue = 'No';
            Editable = false;
        }

        field(6; "Invoice Posted"; Text[3])
        {
            Caption = 'Invoice Posted';
            DataClassification = CustomerContent;
            InitValue = 'No';
            Editable = false;
        }

        field(7; "Item Created"; Text[3])
        {
            Caption = 'Item Created';
            DataClassification = CustomerContent;
            InitValue = 'No';
            Editable = false;
        }

        field(8; CGST; Decimal)
        {
            Caption = 'CGST';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
        }

        field(9; SGST; Decimal)
        {
            Caption = 'SGST';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
        }

        field(10; IGST; Decimal)
        {
            Caption = 'IGST';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            BlankZero = true;
        }

        field(11; Inventory; Text[100])
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
        }

        field(12; "Total Quantity"; Decimal)
        {
            Caption = 'Total Quantity';
            DataClassification = CustomerContent;
        }

        field(13; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }

        field(14; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
    }

    keys
    {
        key(PK; "Serial No.")
        {
            Clustered = true;
        }

        key(VoucherKey; "Voucher Number")
        {
            Unique = true;
        }
    }

    // ==========================================
    // ON INSERT
    // ==========================================

    trigger OnInsert()
    begin
        // Always generate Serial No. inside BC
        "Serial No." := GetNextSerialNo();

        if "Voucher Number" = '' then
            Error('Voucher Number cannot be blank.');

        CheckDuplicateVoucherNumber();

        SetDefaultStatuses();
    end;

    // ==========================================
    // ON MODIFY
    // ==========================================

    trigger OnModify()
    begin
        if "Voucher Number" = '' then
            Error('Voucher Number cannot be blank.');

        CheckDuplicateVoucherNumber();
    end;

    // ==========================================
    // DEFAULT STATUS VALUES
    // ==========================================

    local procedure SetDefaultStatuses()
    begin
        if "Invoice Created" = '' then
            "Invoice Created" := 'No';

        if "Invoice Posted" = '' then
            "Invoice Posted" := 'No';

        if "Item Created" = '' then
            "Item Created" := 'No';
    end;

    // ==========================================
    // DUPLICATE VOUCHER NUMBER CHECK
    // ==========================================

    local procedure CheckDuplicateVoucherNumber()
    var
        ExistingHotel: Record "Hotel Purchase";
    begin
        if "Voucher Number" = '' then
            exit;

        ExistingHotel.Reset();

        ExistingHotel.SetRange(
            "Voucher Number",
            "Voucher Number");

        if "Serial No." <> 0 then
            ExistingHotel.SetFilter(
                "Serial No.",
                '<>%1',
                "Serial No.");

        if not ExistingHotel.IsEmpty() then
            Error(
                'Voucher Number %1 already exists in Hotel Purchase.',
                "Voucher Number");
    end;

    // ==========================================
    // AUTO SERIAL NUMBER GENERATION
    // ==========================================

    local procedure GetNextSerialNo(): Integer
    var
        SerialCounter: Record "Hotel Purchase Serial Counter";
        HotelPurchase: Record "Hotel Purchase";
        NextSerialNo: Integer;
    begin
        SerialCounter.LockTable();

        if not SerialCounter.Get('HOTEL') then begin

            SerialCounter.Init();
            SerialCounter."Counter Code" := 'HOTEL';

            // Find existing maximum Serial No.
            HotelPurchase.Reset();
            HotelPurchase.SetCurrentKey("Serial No.");

            if HotelPurchase.FindLast() then
                SerialCounter."Last Serial No." :=
                    HotelPurchase."Serial No."
            else
                SerialCounter."Last Serial No." := 0;

            SerialCounter.Insert();
        end;

        // Generate next number
        SerialCounter."Last Serial No." += 1;

        NextSerialNo :=
            SerialCounter."Last Serial No.";

        // Skip existing Serial Numbers
        while HotelPurchase.Get(NextSerialNo) do
            NextSerialNo += 1;

        // Update Counter
        SerialCounter."Last Serial No." := NextSerialNo;
        SerialCounter.Modify();

        exit(NextSerialNo);
    end;
}
