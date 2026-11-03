page 50490 "AIRIQ GST Tree Diagnostic"
{
    Caption = 'AIRIQ GST Execution Tree';
    PageType = List;
    SourceTable = "Use Case Tree Node";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }

                field("Name"; Rec.Name)
                {
                    ApplicationArea = All;
                }

                field("Node Type"; Rec."Node Type")
                {
                    ApplicationArea = All;
                }

                field("Use Case ID"; Rec."Use Case ID")
                {
                    ApplicationArea = All;
                }

                field("Indentation"; Rec.Indentation)
                {
                    ApplicationArea = All;
                }

                field("Blocked"; Rec.Blocked)
                {
                    ApplicationArea = All;
                }

                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}