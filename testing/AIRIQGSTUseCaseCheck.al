
page 50592 "AIRIQ GST Use Case Check"
{
    Caption = 'AIRIQ GST Use Case Check';
    PageType = List;
    SourceTable = "Tax Use Case";
    ApplicationArea = All;
    UsageCategory = Lists;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(UseCases)
            {
                Editable = false;

                field(ID; Rec.ID)
                {
                    ApplicationArea = All;
                }

                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                }

                field(Enable; Rec.Enable)
                {
                    ApplicationArea = All;
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }

                field("Parent Use Case ID"; Rec."Parent Use Case ID")
                {
                    ApplicationArea = All;
                }

                field("Condition ID"; Rec."Condition ID")
                {
                    ApplicationArea = All;
                }

                field("Computation Script ID"; Rec."Computation Script ID")
                {
                    ApplicationArea = All;
                }

                field("Major Version"; Rec."Major Version")
                {
                    ApplicationArea = All;
                }

                field("Minor Version"; Rec."Minor Version")
                {
                    ApplicationArea = All;
                }

                field("Effective From"; Rec."Effective From")
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
            action(LoadAIRIQGSTCase)
            {
                Caption = 'Load Active GST Case';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GSTCaseID: Guid;
                begin
                    Evaluate(
                        GSTCaseID,
                        '6B464955-261F-4EAF-A749-7807444FC37C');

                    Rec.Reset();
                    Rec.SetRange(ID, GSTCaseID);

                    CurrPage.Update(false);
                end;
            }

            action(ShowAllUseCases)
            {
                Caption = 'Show All Use Cases';
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
    var
        GSTCaseID: Guid;
    begin
        Evaluate(
            GSTCaseID,
            '6B464955-261F-4EAF-A749-7807444FC37C');

        Rec.SetRange(ID, GSTCaseID);
    end;
}
