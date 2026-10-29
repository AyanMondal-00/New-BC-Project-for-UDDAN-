table 50460 "PLB"
{
    Caption = 'PLB';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            AutoIncrement = true;
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "AirLine"; Text[50])
        {
            Caption = 'AirLine';
            DataClassification = CustomerContent;
        }

        field(3; "AirLine ID"; Code[20])
        {
            Caption = 'AirLine ID';
            DataClassification = CustomerContent;
        }

        field(4; "Commission Basis"; Text[50])
        {
            Caption = 'Commission Basis';
            DataClassification = CustomerContent;
        }

        field(5; "Calculation Base"; Text[50])
        {
            Caption = 'Calculation Base';
            DataClassification = CustomerContent;
        }

        field(6; "Commission %"; Decimal)
        {
            Caption = 'Commission %';
            DecimalPlaces = 0 : 4;
            DataClassification = CustomerContent;
        }

        field(7; "TDS % on Commission"; Decimal)
        {
            Caption = 'TDS % on Commission';
            DecimalPlaces = 0 : 4;
            InitValue = 2.0;
            DataClassification = CustomerContent;
        }

        field(8; "GST %"; Decimal)
        {
            Caption = 'GST %';
            DecimalPlaces = 0 : 2;
            InitValue = 18.0;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(9; "Our State"; Text[50])
        {
            Caption = 'Our State';
            DataClassification = CustomerContent;
        }

        field(10; "AirLine State"; Text[50])
        {
            Caption = 'AirLine State';
            DataClassification = CustomerContent;
        }

        field(11; "GST Type"; Text[50])
        {
            Caption = 'GST Type';
            DataClassification = CustomerContent;
        }

        field(26; "Rule Period Booking date From"; DateTime)
        {
            Caption = 'Rule Period Booking date From';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Rule Period Booking date From");
                CurrentTime := DT2Time(CurrentDateTime());

                Rec."Rule Period Booking date From" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(27; "Rule Period Booking date To"; DateTime)
        {
            Caption = 'Rule Period Booking date To';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Rule Period Booking date To");
                CurrentTime := DT2Time(CurrentDateTime());

                Rec."Rule Period Booking date To" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(12; "Amount From"; Text[50])
        {
            Caption = 'Amount From';
            DataClassification = CustomerContent;
        }

        field(13; "Transaction"; Text[50])
        {
            Caption = 'Transaction';
            DataClassification = CustomerContent;
        }

        field(14; "PNR / Ticket"; Text[100])
        {
            Caption = 'PNR / Ticket';
            DataClassification = CustomerContent;
        }

        field(15; "Purchase Base Fare"; Decimal)
        {
            Caption = 'Purchase Base Fare';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(16; "Purchase Other Charges"; Decimal)
        {
            Caption = 'Purchase Other Charges';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(17; "Purchase Total"; Decimal)
        {
            Caption = 'Purchase Total';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(18; "Purchase Commission"; Decimal)
        {
            Caption = 'Purchase Commission';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(19; "Total Commission"; Decimal)
        {
            Caption = 'Total Commission';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(20; "GST Percentage"; Decimal)
        {
            Caption = 'GST Percentage';
            DecimalPlaces = 0 : 2;
            InitValue = 18.0;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(21; "Invoice Incl. GST"; Decimal)
        {
            Caption = 'Invoice Incl. GST';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(22; "TDS (2.00%) on Commission"; Decimal)
        {
            Caption = 'TDS (2.00%) on Commission';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(23; "Net Receivable"; Decimal)
        {
            Caption = 'Net Receivable';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(24; "Received On"; DateTime)
        {
            Caption = 'Received On';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Received On");
                CurrentTime := DT2Time(CurrentDateTime());

                Rec."Received On" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(25; "Received In (Bank/ID)"; Text[100])
        {
            Caption = 'Received In (Bank/ID)';
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
}
