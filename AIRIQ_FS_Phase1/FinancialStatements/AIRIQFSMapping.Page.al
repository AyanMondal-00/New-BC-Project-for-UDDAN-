page 50730 "AIRIQ FS Mapping List"
{
    Caption = 'AIRIQ Financial Statement Mapping';
    PageType = List;
    SourceTable = "AIRIQ FS Mapping";
    ApplicationArea = All;
    UsageCategory = Lists;
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Statement Code"; Rec."Statement Code") { ApplicationArea = All; }
                field("Note No."; Rec."Note No.") { ApplicationArea = All; }
                field("Financial Heading"; Rec."Financial Heading") { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("Reverse Sign"; Rec."Reverse Sign") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
                field("Approved Mapping"; Rec."Approved Mapping") { ApplicationArea = All; }
                field("Mapping Comment"; Rec."Mapping Comment") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenStatementDefinitions)
            {
                Caption = 'Statement Definitions';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "AIRIQ FS Statements";
            }
            action(OpenPreview)
            {
                Caption = 'G/L Mapping Preview';
                ApplicationArea = All;
                Image = View;
                RunObject = page "AIRIQ FS G/L Preview";
            }
        }
    }
}
