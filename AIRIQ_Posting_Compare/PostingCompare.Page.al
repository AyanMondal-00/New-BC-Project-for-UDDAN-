namespace AIRIQ.GSTPostingCompare;

page 50747 "AIRIQ Posting Compare Audit"
{
    PageType = Card;
    Caption = 'AIRIQ Posting Compare Audit';
    ApplicationArea = All;
    UsageCategory = Administration;
    Editable = false;
    layout
    {
        area(Content)
        {
            group(Information)
            {
                field(Scope; ScopeText)
                {
                    ApplicationArea = All;
                    Caption = 'Read-only scope';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ExportDiagnostic)
            {
                Caption = 'Export Read-only Diagnostic';
                ApplicationArea = All;
                Image = Export;
                trigger OnAction()
                var
                    Diagnostic: Codeunit "AIRIQ Posting Compare Audit";
                begin
                    Diagnostic.ExportAudit();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ScopeText := 'READ ONLY: all posting records in all 12 AIRIQ cases; includes unresolved permissions and missing keys. Internal switch headers cannot be verified.';
    end;
    var
        ScopeText: Text;
}
