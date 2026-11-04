
page 50461 "AIRIQ Vertical Balance Sheet"
{
    Caption = 'AIRIQ Vertical Balance Sheet';
    PageType = List;
    SourceTable = "AIRIQ Vertical Balance Sheet";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Balance Sheet Filters';

                field(AsOfDate; AsOfDate)
                {
                    Caption = 'Balance As On Date';
                    ApplicationArea = All;
                    Editable = true;

                    trigger OnValidate()
                    begin
                        BuildBalanceSheet();
                        CurrPage.Update(false);
                    end;
                }
            }

            repeater(BalanceSheet)
            {
                ShowCaption = false;

                field("Liability Account"; Rec."Liability Account")
                {
                    ApplicationArea = All;
                    Caption = 'LIABILITIES & EQUITY';
                    StyleExpr = RowStyle;
                }

                field("Liability Amount"; Rec."Liability Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    StyleExpr = RowStyle;
                }

                field("Asset Account"; Rec."Asset Account")
                {
                    ApplicationArea = All;
                    Caption = 'ASSETS';
                    StyleExpr = RowStyle;
                }

                field("Asset Amount"; Rec."Asset Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Amount';
                    StyleExpr = RowStyle;
                }
            }

            group(Summary)
            {
                Caption = 'Balance Sheet Summary';

                field(TotalLiabilities; TotalLiabilities)
                {
                    Caption = 'Total Liabilities & Equity';
                    ApplicationArea = All;
                }

                field(TotalAssets; TotalAssets)
                {
                    Caption = 'Total Assets';
                    ApplicationArea = All;
                }

                field(BalanceDifference; BalanceDifference)
                {
                    Caption = 'Balance Difference';
                    ApplicationArea = All;
                    StyleExpr = DifferenceStyle;
                }
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
                ApplicationArea = All;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    BuildBalanceSheet();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        AsOfDate := WorkDate();
        BuildBalanceSheet();
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Is Total" then
            RowStyle := 'Strong'
        else
            RowStyle := 'Standard';
    end;

    var
        AsOfDate: Date;
        TotalAssets: Decimal;
        TotalLiabilities: Decimal;
        BalanceDifference: Decimal;
        RowStyle: Text;
        DifferenceStyle: Text;

    local procedure BuildBalanceSheet()
    var
        GLAccount: Record "G/L Account";
        AssetNames: List of [Text];
        AssetAmounts: List of [Decimal];
        LiabilityNames: List of [Text];
        LiabilityAmounts: List of [Decimal];
        AccountBalance: Decimal;
        RowCount: Integer;
        RowNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        Clear(TotalAssets);
        Clear(TotalLiabilities);
        Clear(BalanceDifference);

        Clear(AssetNames);
        Clear(AssetAmounts);
        Clear(LiabilityNames);
        Clear(LiabilityAmounts);

        GLAccount.Reset();

        GLAccount.SetRange(
            "Account Type",
            GLAccount."Account Type"::Posting);

        GLAccount.SetRange(
            "Income/Balance",
            GLAccount."Income/Balance"::"Balance Sheet");

        GLAccount.SetFilter("Date Filter", '..%1', AsOfDate);

        if GLAccount.FindSet() then
            repeat
                GLAccount.CalcFields("Balance at Date");

                AccountBalance := GLAccount."Balance at Date";

                if AccountBalance <> 0 then begin

                    case GLAccount."Account Category" of

                        GLAccount."Account Category"::Assets:
                            begin
                                AssetNames.Add(
                                    GLAccount."No." + ' - ' +
                                    GLAccount.Name);

                                AssetAmounts.Add(AccountBalance);

                                TotalAssets += AccountBalance;
                            end;

                        GLAccount."Account Category"::Liabilities,
                        GLAccount."Account Category"::Equity:
                            begin
                                LiabilityNames.Add(
                                    GLAccount."No." + ' - ' +
                                    GLAccount.Name);

                                LiabilityAmounts.Add(-AccountBalance);

                                TotalLiabilities += -AccountBalance;
                            end;
                    end;
                end;

            until GLAccount.Next() = 0;

        RowCount := AssetNames.Count();

        if LiabilityNames.Count() > RowCount then
            RowCount := LiabilityNames.Count();

        for RowNo := 1 to RowCount do begin

            Rec.Init();
            Rec."Entry No." := RowNo;

            if RowNo <= LiabilityNames.Count() then begin

                Rec."Liability Account" :=
                    CopyStr(
                        LiabilityNames.Get(RowNo),
                        1,
                        MaxStrLen(Rec."Liability Account"));

                Rec."Liability Amount" :=
                    LiabilityAmounts.Get(RowNo);
            end;

            if RowNo <= AssetNames.Count() then begin

                Rec."Asset Account" :=
                    CopyStr(
                        AssetNames.Get(RowNo),
                        1,
                        MaxStrLen(Rec."Asset Account"));

                Rec."Asset Amount" :=
                    AssetAmounts.Get(RowNo);
            end;

            Rec.Insert();
        end;

        // Insert Total Row
        Rec.Init();

        Rec."Entry No." := RowCount + 1;

        Rec."Liability Account" :=
            'TOTAL LIABILITIES & EQUITY';

        Rec."Liability Amount" :=
            TotalLiabilities;

        Rec."Asset Account" :=
            'TOTAL ASSETS';

        Rec."Asset Amount" :=
            TotalAssets;

        Rec."Is Total" := true;

        Rec.Insert();

        // Balance Difference
        BalanceDifference :=
            Round(
                TotalAssets - TotalLiabilities,
                0.01);

        if BalanceDifference = 0 then
            DifferenceStyle := 'Favorable'
        else
            DifferenceStyle := 'Unfavorable';

        Rec.Reset();

        if Rec.FindFirst() then;
    end;
}
