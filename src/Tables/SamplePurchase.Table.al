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
        field(20; "Invoice Posted"; Boolean)
        {
            Caption = 'Invoice Posted';
            DataClassification = CustomerContent;
            Editable = false;
        }


        field(6; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                PNR := UpperCase(PNR);
                CheckDuplicatePNR();
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

        field(9; Sector; Text[200])
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

        field(14; Type; Text[50])
        {
            Caption = 'Type';
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
        "Serial No." := GetNextSerialNo();
    end;

    local procedure GetNextSerialNo(): Integer
    var
        SerialCounter: Record "Sample Purchase Serial Cnt.";
        SamplePurchase: Record "Sample Purchase";
        CommissionRec: Record "Commission Calculation";
        HighestExistingNo: Integer;
    begin
        // Lock both tables while generating the number.
        SamplePurchase.LockTable();
        SerialCounter.LockTable();

        // Find the highest serial currently in use.
        SamplePurchase.Reset();
        SamplePurchase.SetCurrentKey("Serial No.");

        if SamplePurchase.FindLast() then
            HighestExistingNo := SamplePurchase."Serial No.";

        // Initialize the persistent counter on first use.
        if not SerialCounter.Get('SAMPLEPUR') then begin
            SerialCounter.Init();
            SerialCounter."Counter Code" := 'SAMPLEPUR';
            SerialCounter."Last Serial No." := HighestExistingNo;
            SerialCounter.Insert(true);
        end;

        // Never allow the counter to go below an existing serial.
        if SerialCounter."Last Serial No." < HighestExistingNo then
            SerialCounter."Last Serial No." := HighestExistingNo;

        // Allocate a new number and persist it.
        SerialCounter."Last Serial No." += 1;
        SerialCounter.Modify(true);

        exit(SerialCounter."Last Serial No.");
    end;

    local procedure CheckDuplicatePNR()
    var
        SamplePurchase: Record "Sample Purchase";
        NormalSales: Record "Normal Sales";
        APISalesFormat: Record "API Sales Format";
        ThirdPartySupplierSales: Record "Third-Party Supplier Sales";
        CommissionRec: Record "Commission Calculation";
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

        if PNR <> xRec.PNR then begin
            CommissionRec.Reset();
            CommissionRec.SetRange(PNR, UpperCase(PNR));

            if not CommissionRec.IsEmpty() then
                Error(
                    'The PNR %1 already exists in Commission Calculation.',
                    PNR);
        end;
    end;
}

