page 50698 "AIRIQ GST Posting Diagnostic"
{
    Caption = 'AIRIQ GST Posting Diagnostic';
    PageType = List;
    SourceTable = "Tax Posting Setup";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Summary)
            {
                field(CurrentCompany; CompanyName())
                {
                    Caption = 'Company';
                    ApplicationArea = All;
                }
                field(MatchingRows; MatchingRows)
                {
                    Caption = 'Rows referencing reported switch ID';
                    ApplicationArea = All;
                }
            }
            repeater(PostingSetup)
            {
                field("Case ID"; Rec."Case ID") { ApplicationArea = All; }
                field("ID"; Rec.ID) { Caption = 'Posting Setup ID'; ApplicationArea = All; }
                field("Switch Statement ID"; Rec."Switch Statement ID") { ApplicationArea = All; }
                field(MatchesReportedSwitch; Rec."Switch Statement ID" = ReportedSwitchId)
                {
                    Caption = 'Matches reported switch ID';
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        PostingSetup: Record "Tax Posting Setup";
        CaseId: Guid;
    begin
        Evaluate(CaseId, '{A1D10002-7B10-4A10-9010-000000000002}');
        Evaluate(ReportedSwitchId, '{9BEEC27F-0DC0-4AF3-B1C2-1EEF61229722}');
        Rec.FilterGroup(2);
        Rec.SetRange("Case ID", CaseId);
        Rec.FilterGroup(0);
        PostingSetup.SetRange("Case ID", CaseId);
        PostingSetup.SetRange("Switch Statement ID", ReportedSwitchId);
        MatchingRows := PostingSetup.Count();
    end;

    var
        ReportedSwitchId: Guid;
        MatchingRows: Integer;
}
