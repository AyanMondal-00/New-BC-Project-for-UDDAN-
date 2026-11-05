
table 50464 "Third Party Purchase Return"
{
    Caption = 'Third Party Purchase Return';
    DataClassification = CustomerContent;
    DrillDownPageId = "Third Party Purchase Return";
    LookupPageId = "Third Party Purchase Return";

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "Entry Date"; DateTime)
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

        field(3; "Refund Date"; DateTime)
        {
            Caption = 'Refund Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Refund Date");

                if DT2Time(Rec."Refund Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Refund Date");

                Rec."Refund Date" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(4; "Bill No."; Text[50])
        {
            Caption = 'Bill No.';
            DataClassification = CustomerContent;
        }

        field(5; "Invoice No."; Text[50])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }

        field(6; "Return No."; Text[50])
        {
            Caption = 'Return No.';
            DataClassification = CustomerContent;
        }

        field(7; "Airline"; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(8; "Country"; Text[100])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }

        field(9; "Type"; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        field(10; "Sector"; Text[100])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(11; "PNR"; Text[50])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckDuplicatePNR();
            end;
        }

        field(12; "Narration"; Text[250])
        {
            Caption = 'Narration';
            DataClassification = CustomerContent;
        }

        field(13; "Pax"; Text[50])
        {
            Caption = 'Pax';
            DataClassification = CustomerContent;
        }

        field(14; "Rate"; Decimal)
        {
            Caption = 'Rate';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(15; "Cost Value"; Decimal)
        {
            Caption = 'COST VALUE';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(16; "Cancellation Charges"; Decimal)
        {
            Caption = 'Cancellation Charges';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(17; "Amount"; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(18; "Travel Date"; DateTime)
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

        field(19; "Select"; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            InitValue = false;
        }

        field(20; "Third Party Purchase Return Inv Created"; Boolean)
        {
            Caption = 'Third Party Purchase Return Invoice Created';
            DataClassification = CustomerContent;
            InitValue = false;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Serial No.")
        {
            Clustered = true;
        }

        key(ReturnNo; "Return No.")
        {
        }

        key(InvoiceNo; "Invoice No.")
        {
        }

        key(PNRKey; "PNR")
        {
        }
    }

    trigger OnInsert()
    var
        LastPurchaseReturn: Record "Third Party Purchase Return";
        NextSerialNo: Integer;
    begin
        // Always generate Serial No. inside BC.
        // Never accept the Serial No. from Excel.
        LastPurchaseReturn.LockTable();
        LastPurchaseReturn.Reset();
        LastPurchaseReturn.SetCurrentKey("Serial No.");

        if LastPurchaseReturn.FindLast() then
            NextSerialNo := LastPurchaseReturn."Serial No." + 1
        else
            NextSerialNo := 1;

        // Additional protection against existing Serial Nos.
        while LastPurchaseReturn.Get(NextSerialNo) do
            NextSerialNo += 1;

        "Serial No." := NextSerialNo;

        // PNR Duplicate Validation
        CheckDuplicatePNR();

        // Default Entry Date
        if "Entry Date" = 0DT then
            "Entry Date" := CurrentDateTime();

        // Default Status
        "Select" := false;
        "Third Party Purchase Return Inv Created" := false;
    end;

    trigger OnModify()
    begin
        CheckDuplicatePNR();
    end;

    local procedure CheckDuplicatePNR()
    var
        ExistingPurchaseReturn: Record "Third Party Purchase Return";
    begin
        if PNR = '' then
            Error('PNR cannot be blank.');

        ExistingPurchaseReturn.Reset();
        ExistingPurchaseReturn.SetRange(PNR, PNR);

        ExistingPurchaseReturn.SetFilter(
            "Serial No.",
            '<>%1',
            "Serial No.");

        if ExistingPurchaseReturn.FindFirst() then
            Error(
                'Duplicate PNR detected! PNR %1 already exists. Existing Serial No.: %2.',
                PNR,
                ExistingPurchaseReturn."Serial No.");
    end;
}
