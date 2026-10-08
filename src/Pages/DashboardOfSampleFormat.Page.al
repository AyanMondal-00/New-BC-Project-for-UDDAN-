page 50340 "Dashboard of Sample Format"
{
    Caption = 'Dashboard  View of Sample Format';
    PageType = CardPart;
    SourceTable = "Sample Purchase Dashboard";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            cuegroup(Group1)
            {
                Caption = 'Total Purchase Amount';
                CuegroupLayout = Wide;

                field("Total Purchase Amount"; Rec."Total Purchase Amount")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "Sample Purchase List";
                    Image = Cash;
                    Style = StandardAccent;
                    StyleExpr = true;
                    ShowCaption = false;
                }
            }

            cuegroup(Group2)
            {
                Caption = 'Count of Total Domestic Purchase';
                CuegroupLayout = Wide;

                field("Count Domestic Purchase"; Rec."Count Domestic Purchase")
                {
                    ApplicationArea = All;
                    Image = Checklist;
                    Style = Favorable;
                    StyleExpr = true;
                    ShowCaption = false;
                    
                    trigger OnDrillDown()
                    var
                        SamplePurchase: Record "Sample Purchase";
                    begin
                        SamplePurchase.SetRange(Type, 'Domestic');
                        Page.Run(Page::"Sample Purchase List", SamplePurchase);
                    end;
                }
            }

            cuegroup(Group3)
            {
                Caption = 'Total International Purchase';
                CuegroupLayout = Wide;

                field("Total International Purchase"; Rec."Total International Purchase")
                {
                    ApplicationArea = All;
                    Image = Document;
                    Style = Ambiguous;
                    StyleExpr = true;
                    ShowCaption = false;
                    
                    trigger OnDrillDown()
                    var
                        SamplePurchase: Record "Sample Purchase";
                    begin
                        SamplePurchase.SetRange(Type, 'International');
                        Page.Run(Page::"Sample Purchase List", SamplePurchase);
                    end;
                }
            }

            cuegroup(Group4)
            {
                Caption = 'Total International Other Charges';
                CuegroupLayout = Wide;

                field("Total Intl. Other Charges"; Rec."Total Intl. Other Charges")
                {
                    ApplicationArea = All;
                    Image = Receipt;
                    Style = Unfavorable;
                    StyleExpr = true;
                    ShowCaption = false;
                    
                    trigger OnDrillDown()
                    var
                        SamplePurchase: Record "Sample Purchase";
                    begin
                        SamplePurchase.SetRange(Type, 'International');
                        Page.Run(Page::"Sample Purchase List", SamplePurchase);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec."Primary Key" := 'DEFAULT';
            Rec.Insert();
        end;

        Rec.CalcFields(
            "Total Purchase Amount",
            "Count Domestic Purchase",
            "Total International Purchase",
            "Total Intl. Other Charges"
        );
    end;
}