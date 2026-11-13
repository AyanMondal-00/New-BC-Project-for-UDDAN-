page 50732 "AIRIQ FS G/L Preview"
{
    Caption = 'AIRIQ Financial Statement G/L Mapping Preview';
    PageType = List;
    SourceTable = "AIRIQ FS Preview Buffer";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                field(AsOfDate; AsOfDate)
                {
                    ApplicationArea = All;
                    Caption = 'As at Date';
                    Editable = true;
                    trigger OnValidate() begin RefreshPreview(); end;
                }
                field(StatementCode; StatementCode)
                {
                    ApplicationArea = All;
                    Caption = 'Statement Code';
                    TableRelation = "AIRIQ FS Statement".Code;
                    Editable = true;
                    trigger OnValidate() begin RefreshPreview(); end;
                }
            }
            repeater(Accounts)
            {
                field("Note No."; Rec."Note No.") { ApplicationArea = All; }
                field("Financial Heading"; Rec."Financial Heading") { ApplicationArea = All; }
                field("G/L Account No."; Rec."G/L Account No.") { ApplicationArea = All; }
                field("G/L Account Name"; Rec."G/L Account Name") { ApplicationArea = All; }
                field(Amount; Rec.Amount) { ApplicationArea = All; }
                field("Finance Approved"; Rec."Finance Approved") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Recalculate)
            {
                Caption = 'Recalculate';
                Image = Refresh;
                ApplicationArea = All;
                trigger OnAction() begin RefreshPreview(); end;
            }
            action(OpenGLEntries)
            {
                Caption = 'View G/L Entries';
                Image = LedgerEntries;
                ApplicationArea = All;
                trigger OnAction()
                var
                    GLEntry: Record "G/L Entry";
                begin
                    if Rec."G/L Account No." = '' then
                        exit;
                    GLEntry.SetRange("G/L Account No.", Rec."G/L Account No.");
                    GLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
                    Page.Run(Page::"General Ledger Entries", GLEntry);
                end;
            }
            action(EditMappings)
            {
                Caption = 'Edit Mapping';
                Image = Setup;
                ApplicationArea = All;
                RunObject = page "AIRIQ FS Mapping List";
            }
        }
    }

    trigger OnOpenPage()
    begin
        AsOfDate := DMY2Date(31, 3, 2026);
        StatementCode := 'BS';
        RefreshPreview();
    end;

    local procedure RefreshPreview()
    var
        Calculator: Codeunit "AIRIQ FS GL Calculation";
    begin
        Calculator.BuildPreview(Rec, StatementCode, AsOfDate);
        CurrPage.Update(false);
    end;

    var
        AsOfDate: Date;
        StatementCode: Code[10];
}
