namespace AIRIQ.GSTPostingCleanup;

page 50748 "AIRIQ GST Posting Cleanup"
{
    PageType = Card;
    Caption = 'AIRIQ GST Posting Cleanup';
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
                    Caption = 'Scope';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DeleteBrokenPostingLines)
            {
                ApplicationArea = All;
                Caption = 'Delete Broken Posting Lines';
                Image = Delete;
                trigger OnAction()
                var
                    Cleanup: Codeunit "AIRIQ GST Posting Cleanup";
                begin
                    Cleanup.Execute();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        ScopeText := 'Sandbox1 / TEST 2 only. Exact 24 audited obsolete posting rows. No automatic cleanup on publish.';
    end;
    var
        ScopeText: Text;
}
