table 50403 "Sales Return"
{
    Caption = 'Sales Return';
    DataClassification = CustomerContent;

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

        field(3; "Bill No."; Code[50])
        {
            Caption = 'Bill No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(4; "Invoice No."; Code[50])
        {
            Caption = 'Invoice No.';
            DataClassification = CustomerContent;
        }

        field(5; "Return No."; Code[50])
        {
            Caption = 'Return No.';
            DataClassification = CustomerContent;
        }

        field(6; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(7; "A/C Name"; Text[100])
        {
            Caption = 'A/C Name';
            DataClassification = CustomerContent;
        }

        field(8; Country; Text[50])
        {
            Caption = 'Country';
            DataClassification = CustomerContent;
        }

        field(9; State; Text[50])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
        }

        field(10; City; Text[50])
        {
            Caption = 'City';
            DataClassification = CustomerContent;
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

        field(13; "Travel Date"; DateTime)
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

        field(14; Time; Time)
        {
            Caption = 'Time';
            DataClassification = CustomerContent;
        }

        field(15; Airline; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(16; "Airline Code"; Code[20])
        {
            Caption = 'Airline Code';
            DataClassification = CustomerContent;
        }

        field(17; PNR; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(31; "Passenger Name"; Text[100])
        {
            Caption = 'Passenger Name';
            DataClassification = CustomerContent;
        }

        field(18; Reference; Text[100])
        {
            Caption = 'Reference';
            DataClassification = CustomerContent;
        }

        field(19; Narration; Text[250])
        {
            Caption = 'Narration';
            DataClassification = CustomerContent;
        }

        field(20; PAX; Integer)
        {
            Caption = 'PAX';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RefreshPostedInvoiceData();
            end;
        }

        field(21; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(33; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(22; "Taxable Value"; Decimal)
        {
            Caption = 'Taxable Value';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(23; CGST; Decimal)
        {
            Caption = 'CGST';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(24; SGST; Decimal)
        {
            Caption = 'SGST';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(25; IGST; Decimal)
        {
            Caption = 'IGST';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(26; "Sold Value"; Decimal)
        {
            Caption = 'Sold Value';
            DataClassification = CustomerContent;
        }

        field(27; "XXLN Charges"; Decimal)
        {
            Caption = 'XXLN Charges';
            DataClassification = CustomerContent;
        }

        field(28; "Refund Amount"; Decimal)
        {
            Caption = 'Refund Amount';
            DataClassification = CustomerContent;
        }

        field(29; "Sale Type"; Option)
        {
            Caption = 'Sale Type';
            OptionMembers = Own,ThirdParty;
            DataClassification = CustomerContent;
        }

        field(30; Supplier; Code[30])
        {
            Caption = 'Supplier';
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

        RefreshPostedInvoiceData();
    end;

    trigger OnModify()
    begin
        // Also retry when an older unmatched record is edited.
        RefreshPostedInvoiceData();
    end;

    procedure RefreshPostedInvoiceData()
    var
        Fetcher: Codeunit "AIRIQ SR Posted Invoice Fetch";
    begin
        Fetcher.Fetch(Rec);
    end;

    local procedure GetNextSerialNo(): Integer
    var
        NoSeries: Codeunit "No. Series";
        NextNoText: Code[20];
        NextNo: Integer;
        SalesReturn: Record "Sales Return";
    begin
        NextNoText := NoSeries.GetNextNo('N-SR');

        if not Evaluate(NextNo, NextNoText) then
            Error(
                'No. Series N-SR must generate numeric values. Value received: %1.',
                NextNoText);

        if NextNo <= 0 then
            Error(
                'No. Series N-SR must generate a positive Serial No.');

        if SalesReturn.Get(NextNo) then
            Error(
                'Serial No. %1 already exists. Please check No. Series N-SR setup.',
                NextNo);

        exit(NextNo);
    end;
}