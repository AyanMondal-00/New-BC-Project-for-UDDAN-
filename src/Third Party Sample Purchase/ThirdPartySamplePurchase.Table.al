table 50660 "Third Party Sample Purchase"
{
    Caption = 'Third Party Sample Purchase';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer) { Caption = 'Serial No.'; DataClassification = SystemMetadata; Editable = false; }
        field(2; "Purchase Date"; DateTime)
        {
            Caption = 'Purchase Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Purchase Date");

                if DT2Time(Rec."Purchase Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Purchase Date");

                Rec."Purchase Date" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }
        field(3; "Entry Date"; DateTime)
        {
            Caption = 'Entry Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Entry Date");

                if DT2Time(Rec."Entry Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Entry Date");

                Rec."Entry Date" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }
        field(4; Airline; Text[100]) { Caption = 'Airline'; DataClassification = CustomerContent; }
        field(5; "Supplier ID"; Code[20]) { Caption = 'Supplier ID'; DataClassification = CustomerContent; }
        field(6; Select; Boolean) { Caption = 'Select'; DataClassification = CustomerContent; }
        field(7; "Invoice Created"; Boolean) { Caption = 'Invoice Created'; DataClassification = CustomerContent; Editable = false; }
        field(8; "Invoice Posted"; Boolean) { Caption = 'Invoice Posted'; DataClassification = CustomerContent; Editable = false; }
        field(9; "Item Created"; Boolean) { Caption = 'Item Created'; DataClassification = CustomerContent; Editable = false; }
        field(10; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                PNR := UpperCase(DelChr(PNR, '<>', ' '));
            end;
        }
        field(11; "Total Pax"; Integer)
        {
            Caption = 'Total Pax';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                RecalculateAmount();
            end;
        }
        field(12; "Travel Date"; DateTime)
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

                Rec."Travel Date" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }
        field(13; Sector; Text[200]) { Caption = 'Sector'; DataClassification = CustomerContent; }
        field(14; Type; Text[50]) { Caption = 'Type'; DataClassification = CustomerContent; }
        field(15; Rate; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                RecalculateAmount();
            end;
        }
        field(16; "Total Amount"; Decimal) { Caption = 'Total Amount'; DataClassification = CustomerContent; Editable = false; }
        field(17; "Purchase Invoice No."; Code[20]) { Caption = 'Purchase Invoice No.'; DataClassification = CustomerContent; Editable = false; }
    }

    keys
    {
        key(PK; "Serial No.") { Clustered = true; }
        key(PurchaseIdentity; PNR) { }
    }

    trigger OnInsert()
    begin
        // The page's key is a preview. Recheck under the table lock so a
        // concurrent insert cannot reuse it and abandoned rows leave no gap.
        "Serial No." := GetNextSerialNo(true);
        ValidateSource();
    end;

    trigger OnModify()
    begin
        if xRec."Purchase Invoice No." <> '' then
            if (PNR <> xRec.PNR) or ("Supplier ID" <> xRec."Supplier ID") or
               ("Purchase Date" <> xRec."Purchase Date") or
               ("Total Pax" <> xRec."Total Pax") or (Rate <> xRec.Rate) then
                Error('Purchase details cannot be changed after invoice %1 was created.', xRec."Purchase Invoice No.");
        "Invoice Created" := "Purchase Invoice No." <> '';
        ValidateSource();
    end;

    procedure RecalculateAmount()
    begin
        "Total Amount" := Rate * "Total Pax";
    end;

    procedure ValidateSource()
    var
        OtherPurchase: Record "Third Party Sample Purchase";
    begin
        PNR := UpperCase(DelChr(PNR, '<>', ' '));
        if PNR = '' then
            Error('PNR is required.');
        if "Supplier ID" = '' then
            Error('Supplier ID is required for vendor matching.');
        if "Purchase Date" = 0DT then
            Error('Purchase Date is required for the invoice document date.');
        if "Total Pax" <= 0 then
            Error('Total Pax must be greater than zero.');
        if Rate < 0 then
            Error('Rate cannot be negative.');
        RecalculateAmount();
        OtherPurchase.LockTable();
        OtherPurchase.SetRange(PNR, PNR);
        OtherPurchase.SetFilter("Serial No.", '<>%1', "Serial No.");
        if not OtherPurchase.IsEmpty() then
            Error('PNR %1 already exists in Third Party Sample Purchase.', PNR);
    end;

    procedure PreviewNextSerialNo(): Integer
    begin
        exit(GetNextSerialNo(false));
    end;

    local procedure GetNextSerialNo(LockForInsert: Boolean): Integer
    var
        Purchase: Record "Third Party Sample Purchase";
    begin
        if LockForInsert then
            Purchase.LockTable();

        Purchase.Reset();
        Purchase.SetCurrentKey("Serial No.");
        if Purchase.FindLast() then
            exit(Purchase."Serial No." + 1);

        exit(1);
    end;
}
