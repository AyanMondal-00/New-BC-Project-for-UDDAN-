
page 50593 "AIRIQ GST Formula Check"
{
    Caption = 'AIRIQ GST Formula Check';
    PageType = List;
    SourceTable = "Tax Component Expression";
    ApplicationArea = All;
    UsageCategory = Lists;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Formulas)
            {
                Editable = false;

                field("Case ID"; Rec."Case ID")
                {
                    ApplicationArea = All;
                }

                field("Component ID"; Rec."Component ID")
                {
                    ApplicationArea = All;
                }

                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }

                field(Expression; Rec.Expression)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ShowStandardCase)
            {
                Caption = 'Show Standard GST Case';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                begin
                    FilterStandardCase();
                    CurrPage.Update(false);
                end;
            }

            action(ShowAll)
            {
                Caption = 'Show All Formulas';
                ApplicationArea = All;
                Image = View;

                trigger OnAction()
                begin
                    Rec.Reset();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        FilterStandardCase();
    end;

    local procedure FilterStandardCase()
    var
        CaseGuid: Guid;
    begin
        Evaluate(
            CaseGuid,
            '6B464955-261F-4EAF-A749-7807444FC37C');

        Rec.Reset();
        Rec.SetRange("Case ID", CaseGuid);
    end;
}
