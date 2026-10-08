table 50301 "Sample Purchase Cue"
{
    Caption = 'Sample Purchase Cue';
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
            CalcFormula = sum("Sample Purchase"."Total Amount");
        }

        field(3; "Total Domestic Purchases"; Integer)
        {
            Caption = 'Total Domestic Purchases';
            FieldClass = FlowField;
            CalcFormula = count("Sample Purchase" where(Type = const('Domestic')));
        }

        field(4; "Total Domestic Amount"; Decimal)
        {
            Caption = 'Total Domestic Purchase Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Sample Purchase"."Total Amount" where(Type = const('Domestic')));
        }

        field(5; "Total Intl. Purchases"; Integer)
        {
            Caption = 'Total International Purchases';
            FieldClass = FlowField;
            CalcFormula = count("Sample Purchase" where(Type = const('International')));
        }

        field(6; "Total Intl. Amount"; Decimal)
        {
            Caption = 'Total International Purchase Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Sample Purchase"."Total Amount" where(Type = const('International')));
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
