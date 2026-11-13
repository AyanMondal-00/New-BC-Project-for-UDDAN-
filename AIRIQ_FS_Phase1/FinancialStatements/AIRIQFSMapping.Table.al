table 50730 "AIRIQ FS Mapping"
{
    Caption = 'AIRIQ Financial Statement Mapping';
    DataClassification = CustomerContent;
    DrillDownPageId = "AIRIQ FS Mapping List";
    LookupPageId = "AIRIQ FS Mapping List";

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Statement Code"; Code[10])
        {
            Caption = 'Statement Code';
            TableRelation = "AIRIQ FS Statement".Code;
        }
        field(3; "Note No."; Code[10])
        {
            Caption = 'Note No.';
        }
        field(4; "Financial Heading"; Text[150])
        {
            Caption = 'Financial Heading';
        }
        field(5; "G/L Account No."; Code[20])
        {
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account"."No." where("Account Type" = const(Posting));

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if "G/L Account No." = '' then
                    exit;
                GLAccount.Get("G/L Account No.");
                GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
                if "Financial Heading" = '' then
                    "Financial Heading" := CopyStr(GLAccount.Name, 1, MaxStrLen("Financial Heading"));
            end;
        }
        field(6; "Reverse Sign"; Boolean)
        {
            Caption = 'Reverse Sign';
            ToolTip = 'Reverses the G/L entry sign for statement display only.';
        }
        field(7; Active; Boolean)
        {
            Caption = 'Active';
            InitValue = true;
        }
        field(8; "Approved Mapping"; Boolean)
        {
            Caption = 'Finance Approved';
            InitValue = false;
            ToolTip = 'Mark after Finance Team validates this account classification.';
        }
        field(9; "Mapping Comment"; Text[250])
        {
            Caption = 'Mapping Comment';
        }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
        key(ByStatement; "Statement Code", "Note No.", Active) { }
        key(ByAccount; "G/L Account No.") { }
    }
}
