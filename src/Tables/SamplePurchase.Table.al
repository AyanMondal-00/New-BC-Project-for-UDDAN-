
table 50300 "Sample Purchase"
{
    Caption = 'Sample Purchase';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Code[20])
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
                if Rec."Purchase Date" = 0DT then
                    exit;

                SelectedDate := DT2Date(Rec."Purchase Date");

                if DT2Time(Rec."Purchase Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Purchase Date");

                Rec."Purchase Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
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
                if Rec."Entry Date" = 0DT then
                    exit;

                SelectedDate := DT2Date(Rec."Entry Date");

                if DT2Time(Rec."Entry Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Entry Date");

                Rec."Entry Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
            end;
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
            ObsoleteState = Removed;
        }

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
                Rec.PNR := UpperCase(DelChr(Rec.PNR, '<>', ' '));
                CheckDuplicatePNR();
            end;
        }

        field(7; "Total Pax"; Integer)
        {
            Caption = 'Total Pax';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalculatePurchaseAmount();
            end;
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
                if Rec."Travel Date" = 0DT then
                    exit;

                SelectedDate := DT2Date(Rec."Travel Date");

                if DT2Time(Rec."Travel Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Travel Date");

                Rec."Travel Date" :=
                    CreateDateTime(SelectedDate, CurrentTime);
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
            Editable = True;
        }

        field(11; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculatePurchaseAmount();
            end;
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
            Editable = true;

            trigger OnValidate()
            begin
                CalculatePurchaseAmount();
            end;
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

        key(PNRKey; PNR)
        {
        }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        // Allocate the serial from the standard Business Central number series.
        if "Serial No." = '' then
            "Serial No." := NoSeries.GetNextNo('AIR-IQ-SP');

        // Normalize and check PNR
        Rec.PNR := UpperCase(DelChr(Rec.PNR, '<>', ' '));
        CheckDuplicatePNR();
    end;

    trigger OnModify()
    begin
        // Prevent duplicate PNR even when modified by code
        Rec.PNR := UpperCase(DelChr(Rec.PNR, '<>', ' '));
        CheckDuplicatePNR();
    end;



    local procedure CalculatePurchaseAmount()
    begin
        Rec."Other Charges" :=
            Rec."Total Amount" -
            (Rec."Base Fare" * Rec."Total Pax");
    end;



    local procedure CheckDuplicatePNR()
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        // Empty PNR does not require duplicate checking
        if Rec.PNR = '' then
            exit;

        SamplePurchase.Reset();

        // Search only inside Sample Purchase
        SamplePurchase.SetRange(PNR, Rec.PNR);

        // Exclude the current record
        if Rec."Serial No." <> '' then
            SamplePurchase.SetFilter(
                "Serial No.", '<>%1', Rec."Serial No.");

        // Block duplicate PNR
        if not SamplePurchase.IsEmpty() then
            Error(
                'The PNR %1 already exists in Sample Purchase.',
                Rec.PNR);
    end;
}
