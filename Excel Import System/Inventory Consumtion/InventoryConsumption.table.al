
table 50420 "Inventory Consumption"
{
    Caption = 'Inventory Consumption';
    DataClassification = CustomerContent;

    fields
    {
        field(20; Select; Boolean)
        {
            Caption = 'Select';
            DataClassification = CustomerContent;
            InitValue = false;
        }

        field(21; "Purchase Return Order Created"; Boolean)
        {
            Caption = 'Purchase Return Order Created';
            DataClassification = CustomerContent;
            InitValue = false;
        }

        field(1; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = SystemMetadata;
        }

        field(2; "Date"; DateTime)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SelectedDate: Date;
                CurrentTime: Time;
            begin
                SelectedDate := DT2Date(Rec."Date");

                if DT2Time(Rec."Date") = 000000T then
                    CurrentTime := DT2Time(CurrentDateTime())
                else
                    CurrentTime := DT2Time(Rec."Date");

                Rec."Date" := CreateDateTime(SelectedDate, CurrentTime);
            end;
        }

        field(3; "Invoice Number"; Code[50])
        {
            Caption = 'Invoice Number';
            DataClassification = CustomerContent;
        }

        field(4; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(5; "Agency Name"; Text[100])
        {
            Caption = 'Agency Name';
            DataClassification = CustomerContent;
        }

        field(22; "Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
            DataClassification = CustomerContent;
        }

        field(6; "Ref No./AQ Number"; Integer)
        {
            Caption = 'Ref No./AQ Number';
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Passenger name is no longer maintained in this table.';
        }

        field(9; Pax; Integer)
        {
            Caption = 'Pax';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(10; "Travel Date"; DateTime)
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

        field(11; Sector; Text[200])
        {
            Caption = 'Sector';
            DataClassification = CustomerContent;
        }

        field(12; Type; Text[50])
        {
            Caption = 'Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(13; "Base Fare"; Decimal)
        {
            Caption = 'Base Fare';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }

        field(14; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateAmounts();
            end;
        }
        field(23; "Rate"; Decimal)
        {
            Caption = 'Rate';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(15; "Taxable Basis"; Decimal)
        {
            Caption = 'Taxable Basis';
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(16; CGST; Decimal)
        {
            Caption = 'CGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(17; SGST; Decimal)
        {
            Caption = 'SGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(18; IGST; Decimal)
        {
            Caption = 'IGST';
            BlankZero = true;
            Editable = false;
            DataClassification = CustomerContent;
        }

        field(19; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            Editable = false;
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
        if "Serial No." <= 0 then
            "Serial No." := GetNextSerialNo();

        CalculateAmounts();
    end;

    trigger OnModify()
    begin
        CalculateAmounts();
    end;

    procedure CalculateAmounts()
    var
        TotalBaseFare: Decimal;
    begin
        TotalBaseFare := "Base Fare" * Pax;
        Rate := ("Base Fare" + "Other Charges") * Pax;
        "Total Amount" := Rate;
        "Taxable Basis" := 0;
        CGST := 0;
        SGST := 0;
        IGST := 0;

        case UpperCase(DelChr(Type, '<>', ' ')) of
            'DOMESTIC':
                begin
                    "Taxable Basis" := TotalBaseFare * 5 / 100;
                    CGST := "Taxable Basis" * 9 / 100;
                    SGST := "Taxable Basis" * 9 / 100;
                end;
            'INTERNATIONAL':
                begin
                    "Taxable Basis" := TotalBaseFare * 10 / 100;
                    IGST := "Taxable Basis" * 18 / 100;
                end;
        end;
    end;
    local procedure GetNextSerialNo(): Integer
    var
        SerialCounter: Record "Inv. Cons. Serial Cnt.";
        InventoryConsumption: Record "Inventory Consumption";
    begin
        SerialCounter.LockTable();

        if not SerialCounter.Get('INVCON') then begin
            SerialCounter.Init();
            SerialCounter."Counter Code" := 'INVCON';

            InventoryConsumption.Reset();

            if InventoryConsumption.FindLast() then
                SerialCounter."Last Serial No." :=
                    InventoryConsumption."Serial No."
            else
                SerialCounter."Last Serial No." := 0;

            SerialCounter.Insert();
        end;

        SerialCounter."Last Serial No." += 1;
        SerialCounter.Modify();

        exit(SerialCounter."Last Serial No.");
    end;
}
