table 50460 "PLB"
{
    Caption = 'PLB';
    DataClassification = CustomerContent;
    DrillDownPageId = "PLB";
    LookupPageId = "PLB";

    fields
    {
        field(1; "Serial No."; Code[20])
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
            Editable = false;
        }

        field(2; "PNR"; Text[10])
        {
            Caption = 'PNR';
            DataClassification = CustomerContent;
        }

        field(3; "Airline"; Text[100])
        {
            Caption = 'Airline';
            DataClassification = CustomerContent;
        }

        field(4; "Airline ID's"; Text[250])
        {
            Caption = 'Airline ID''s';
            DataClassification = CustomerContent;
        }

        field(5; "Type"; Text[100])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }

        field(6; "Basis"; Text[100])
        {
            Caption = 'Basis';
            DataClassification = CustomerContent;
        }

        field(7; "Period"; Text[250])
        {
            Caption = 'Period';
            DataClassification = CustomerContent;
        }

        field(8; "Commission Base"; Decimal)
        {
            Caption = 'Commission Base';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(9; "Commission %"; Decimal)
        {
            Caption = 'Commission %';
            DecimalPlaces = 0 : 4;
            DataClassification = CustomerContent;
        }

        field(10; "Commission Amount"; Decimal)
        {
            Caption = 'Commission Amount';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(11; "GST"; Decimal)
        {
            Caption = 'GST';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(12; "Invoice Amount"; Decimal)
        {
            Caption = 'Invoice Amount';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(13; "TDS"; Decimal)
        {
            Caption = 'TDS';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(14; "Net Receivable"; Decimal)
        {
            Caption = 'Net Receivable';
            DecimalPlaces = 2 : 2;
            DataClassification = CustomerContent;
        }

        field(15; "Received On"; Date)
        {
            Caption = 'Received On';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                UpdateStatus();
            end;
        }

        field(16; "Received In"; Text[100])
        {
            Caption = 'Received In';
            DataClassification = CustomerContent;
        }

        field(17; "Status"; Text[100])
        {
            Caption = 'Status';
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

        key(PNRKey; "PNR")
        {
        }

        key(AirlineKey; "Airline")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Serial No." = '' then
            GenerateSerialNo();

        UpdateStatus();
    end;

    procedure UpdateStatus()
    begin
        if "Received On" <> 0D then
            "Status" := 'Received'
        else
            "Status" := 'Pending';
    end;

    local procedure GenerateSerialNo()
    var
        PLBRecord: Record "PLB";
        LastSerialNo: Code[20];
    begin
        PLBRecord.LockTable();

        PLBRecord.SetCurrentKey("Serial No.");
        PLBRecord.SetFilter("Serial No.", 'PLB*');

        if PLBRecord.FindLast() then begin
            LastSerialNo := PLBRecord."Serial No.";
            "Serial No." := IncStr(LastSerialNo);

            if "Serial No." = '' then
                Error(
                    'Unable to generate the next PLB Serial No. after %1.',
                    LastSerialNo);
        end else
            "Serial No." := 'PLB000001';
    end;
}
