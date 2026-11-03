
page 50594 "AIRIQ GST Tree Check"
{
    Caption = 'AIRIQ GST Tree Check';
    PageType = List;
    SourceTable = "Use Case Tree Node";
    ApplicationArea = All;
    UsageCategory = Lists;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(TreeNodes)
            {
                Editable = false;

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }

                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }

                field("Node Type"; Rec."Node Type")
                {
                    ApplicationArea = All;
                }

                field(Indentation; Rec.Indentation)
                {
                    ApplicationArea = All;
                }

                field("Use Case ID"; Rec."Use Case ID")
                {
                    ApplicationArea = All;
                }


                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }

                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = All;
                }

                field(CaseName; Rec.CaseName)
                {
                    ApplicationArea = All;
                }

                field(ConditionTxt; Rec.ConditionTxt)
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
            action(ShowGSTBranch)
            {
                Caption = 'Show GST Tree';
                ApplicationArea = All;
                Image = Refresh;

                trigger OnAction()
                begin
                    Rec.Reset();
                    Rec.SetFilter(Code, 'TE-*');
                    CurrPage.Update(false);
                end;
            }

            action(ShowAll)
            {
                Caption = 'Show All Tree Nodes';
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
        Rec.SetFilter(Code, 'TE-*');
    end;
}
