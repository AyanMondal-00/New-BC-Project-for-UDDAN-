table 50479 "API Sales Return"
{
    Caption = 'API Sales Return';
    DataClassification = CustomerContent;
    DrillDownPageId = "API Sales Return";
    LookupPageId = "API Sales Return";

    fields
    {
        field(1; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "Entry Date"; DateTime)
        {
            Caption = 'Entry Date';

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

        field(3; "Bill No."; Text[50])
        {
            Caption = 'Bill No.';

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(4; "Invoice No."; Text[50])
        {
            Caption = 'Invoice No.';
        }

        field(5; "Return No."; Code[50])
        {
            Caption = 'Return No.';

            trigger OnValidate()
            begin
                CheckDuplicateReturnNo();
            end;
        }

        field(6; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
        }

        field(7; "A/C Name"; Text[100])
        {
            Caption = 'A/C Name';
        }

        field(8; Country; Text[100])
        {
            Caption = 'Country';
        }

        field(9; State; Text[100])
        {
            Caption = 'State';
        }

        field(10; City; Text[100])
        {
            Caption = 'City';
        }

        field(11; Sector; Text[200])
        {
            Caption = 'Sector';
        }

        field(12; Type; Text[50])
        {
            Caption = 'Type';
        }

        field(13; "Travel Date"; DateTime)
        {
            Caption = 'Travel Date';

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

        field(14; "Flight Time"; Time)
        {
            Caption = 'Time';
        }

        field(15; Airline; Text[100])
        {
            Caption = 'Airline';
        }

        field(16; "Airline Code"; Text[50])
        {
            Caption = 'Airline Code';
        }

        field(17; PNR; Text[50])
        {
            Caption = 'PNR';

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(18; Narration; Text[250])
        {
            Caption = 'Narration';
        }

        field(19; PAX; Integer)
        {
            Caption = 'PAX';

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(20; RATE; Decimal)
        {
            Caption = 'RATE';
            DecimalPlaces = 0 : 5;
        }

        field(21; "Sold Value"; Decimal)
        {
            Caption = 'Sold Value';
            DecimalPlaces = 0 : 5;
        }

        field(22; "XXLN Charges"; Decimal)
        {
            Caption = 'XXLN Charges';
            DecimalPlaces = 0 : 5;
        }

        field(23; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DecimalPlaces = 0 : 5;
        }

        field(24; "Sale Type"; Text[50])
        {
            Caption = 'Sale Type';
        }

        field(25; Supplier; Text[100])
        {
            Caption = 'Supplier';
        }

        field(26; "Select"; Boolean)
        {
            Caption = 'Select';
            InitValue = false;
        }

        field(27; "Sales Credit Memo Created"; Boolean)
        {
            Caption = 'Sales Credit Memo Created';
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

        key(PNRKey; PNR)
        {
        }
    }

    trigger OnInsert()
    var
        NoSeries: Codeunit "No. Series";
    begin
        // Validate before requesting a number from the series.
        CheckDuplicateReturnNo();

        // Generate Serial No. from BC Standard No. Series.
        "Serial No." := NoSeries.GetNextNo('API-SALES-RETURN');

        RefreshPostedInvoiceData();
    end;

    trigger OnModify()
    begin
        CheckDuplicateReturnNo();
        RefreshPostedInvoiceData();
    end;

    procedure RefreshPostedInvoiceData()
    var
        Fetcher: Codeunit "AIRIQ API Return Invoice Fetch";
    begin
        Fetcher.Fetch(Rec);
    end;

    local procedure CheckDuplicateReturnNo()
    var
        ExistingReturn: Record "API Sales Return";
    begin
        if "Return No." = '' then
            Error('Return No. cannot be blank.');

        ExistingReturn.Reset();
        ExistingReturn.SetRange("Return No.", "Return No.");

        ExistingReturn.SetFilter(
            "Serial No.", '<>%1', "Serial No.");

        if ExistingReturn.FindFirst() then
            Error(
                'Duplicate Return No. %1 already exists at Serial No. %2.',
                "Return No.",
                ExistingReturn."Serial No.");
    end;
}