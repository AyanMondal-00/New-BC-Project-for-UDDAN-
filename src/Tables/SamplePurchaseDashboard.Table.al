table 50330 "Sample Purchase Dashboard"
{
    Caption = 'Sample Purchase Dashboard';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }

        field(2; "Total Purchase Amount"; Decimal)
        {
            Caption = 'Total Purchase Amount';
            FieldClass = FlowField;
            CalcFormula = Sum("Sample Purchase"."Total Amount");
            Editable = false;
        }

        field(3; "Count Domestic Purchase"; Integer)
        {
            Caption = 'Count of Total Domestic Purchase';
            FieldClass = FlowField;
            CalcFormula = Count("Sample Purchase" WHERE(Type = CONST(Domestic)));
            Editable = false;
        }

        field(4; "Total International Purchase"; Decimal)
        {
            Caption = 'Total International Purchase';
            FieldClass = FlowField;
            CalcFormula = Sum("Sample Purchase"."Total Amount"
                WHERE(Type = CONST(International)));
            Editable = false;
        }

        field(5; "Total Intl. Other Charges"; Decimal)
        {
            Caption = 'Total International Other Charges';
            FieldClass = FlowField;
            CalcFormula = Sum("Sample Purchase"."Other Charges"
                WHERE(Type = CONST(International)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}