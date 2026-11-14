
page 50461 "AIRIQ Vertical Balance Sheet"
{
    Caption = 'AIRIQ Vertical Balance Sheet';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Balance Sheet Filters';

                field(AsOfDate; AsOfDate)
                {
                    ApplicationArea = All;
                    Caption = 'Balance As On Date';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        BuildBalanceSheet();
                        PushBalanceSheet();
                    end;
                }

                field(FiscalYearStartDate; FiscalYearStartDate)
                {
                    ApplicationArea = All;
                    Caption = 'Fiscal Year Start';
                    Editable = false;
                }
            }

            usercontrol(BalanceTree; "AIRIQ Balance Tree AddIn")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    AddInIsReady := true;
                    PushBalanceSheet();
                end;

                trigger NodeActivated(NodeId: Integer)
                begin
                    OpenNodeDetails(NodeId);
                end;
            }

            group(Summary)
            {
                Caption = 'Balance Sheet Summary';

                field(TotalLiabilities; TotalLiabilities)
                {
                    ApplicationArea = All;
                    Caption = 'Total Liabilities & Equity';
                    Editable = false;
                }

                field(TotalAssets; TotalAssets)
                {
                    ApplicationArea = All;
                    Caption = 'Total Assets';
                    Editable = false;
                }

                field(CurrentProfitLoss; CurrentProfitLoss)
                {
                    ApplicationArea = All;
                    Caption = 'Current Year Profit / Loss';
                    Editable = false;
                }

                field(BalanceDifference; BalanceDifference)
                {
                    ApplicationArea = All;
                    Caption = 'Balance Difference';
                    Editable = false;
                    StyleExpr = DifferenceStyle;
                }

                field(ValidationIssueCount; ValidationIssueCount)
                {
                    ApplicationArea = All;
                    Caption = 'Account Validation Issues';
                    Editable = false;
                    StyleExpr = ValidationStyle;
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
                    PushBalanceSheet();
                    CurrPage.Update(false);
                end;
            }

            action(ExportToExcel)
            {
                Caption = 'Export to Excel';
                ApplicationArea = All;
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the complete T-shaped Balance Sheet hierarchy for the selected Balance As On Date.';

                trigger OnAction()
                begin
                    ExportBalanceSheetToExcel();
                end;
            }

            action(ViewValidationIssues)
            {
                Caption = 'View Validation Issues';
                ApplicationArea = All;
                Image = Warning;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if ValidationIssueCount = 0 then
                        Message('No validation issues were detected by this page.')
                    else
                        Message('%1', ValidationDetails);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        AsOfDate := WorkDate();
        BuildBalanceSheet();
    end;

    var
        TempNodes: Record "AIRIQ Vertical Balance Sheet" temporary;
        AsOfDate: Date;
        FiscalYearStartDate: Date;
        TotalAssets: Decimal;
        TotalLiabilities: Decimal;
        CurrentProfitLoss: Decimal;
        BalanceDifference: Decimal;
        ValidationIssueCount: Integer;
        ValidationDetails: Text;
        DifferenceStyle: Text;
        ValidationStyle: Text;
        NextNodeID: Integer;
        AddInIsReady: Boolean;

    // =====================================================
    // CONTROL ADD-IN DATA
    // All posting accounts, including zero balance,
    // are sent to JavaScript.
    // =====================================================

    local procedure PushBalanceSheet()
    var
        Payload: JsonObject;
        Nodes: JsonArray;
        Node: JsonObject;
        ScanNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        PayloadText: Text;
    begin
        if not AddInIsReady then
            exit;

        ScanNode.Copy(TempNodes, true);
        ScanNode.Reset();

        if ScanNode.FindSet() then
            repeat
                Clear(Node);

                Node.Add('id', ScanNode."Entry No.");
                Node.Add('parentId', ScanNode."Node Parent ID");
                Node.Add('side', ScanNode."Node Side");
                Node.Add('level', ScanNode."Node Level");
                Node.Add('accountNo', ScanNode."Node G/L Account No.");
                Node.Add('name', ScanNode."Node Name");
                Node.Add('amount', ScanNode."Node Amount");
                Node.Add('isGroup', ScanNode."Node Is Group");
                Node.Add('isProfit', ScanNode."Node Is Profit");

                Nodes.Add(Node);
            until ScanNode.Next() = 0;

        Payload.Add('nodes', Nodes);
        Payload.Add('assets', TotalAssets);
        Payload.Add('liabilities', TotalLiabilities);
        Payload.Add('profit', CurrentProfitLoss);
        Payload.Add('difference', BalanceDifference);
        Payload.Add('validationIssues', ValidationIssueCount);
        Payload.Add('asOfDate', Format(AsOfDate));
        Payload.Add('fiscalYearStart', Format(FiscalYearStartDate));

        Payload.WriteTo(PayloadText);

        CurrPage.BalanceTree.SetBalanceSheetData(PayloadText);
    end;

    // =====================================================
    // LEDGER DRILL DOWN
    // =====================================================

    local procedure OpenNodeDetails(NodeId: Integer)
    var
        Node: Record "AIRIQ Vertical Balance Sheet" temporary;
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
    begin
        if NodeId = 0 then
            exit;

        Node.Copy(TempNodes, true);

        if not Node.Get(NodeId) then
            exit;

        if Node."Node Is Group" then
            exit;

        if Node."Node Is Profit" then begin
            GLAccount.Reset();

            GLAccount.SetRange(
                "Account Type",
                GLAccount."Account Type"::Posting);

            GLAccount.SetRange(
                "Income/Balance",
                GLAccount."Income/Balance"::"Income Statement");

            if FiscalYearStartDate <> 0D then
                GLAccount.SetRange(
                    "Date Filter",
                    FiscalYearStartDate,
                    AsOfDate)
            else
                GLAccount.SetFilter(
                    "Date Filter",
                    '..%1',
                    AsOfDate);

            Page.Run(Page::"Chart of Accounts", GLAccount);
            exit;
        end;

        if Node."Node G/L Account No." = '' then
            exit;

        // Only posting accounts under the named Sundry Debtors/Creditors
        // COA branches use the party-wise subledger drill-down.
        if IsUnderNamedGroup(Node, 'SUNDRY DEBTORS') then begin
            OpenPartyBalances(Node."Node G/L Account No.", false);
            exit;
        end;

        if IsUnderNamedGroup(Node, 'SUNDRY CREDITORS') then begin
            OpenPartyBalances(Node."Node G/L Account No.", true);
            exit;
        end;

        GLEntry.Reset();

        GLEntry.SetRange(
            "G/L Account No.",
            Node."Node G/L Account No.");

        GLEntry.SetFilter(
            "Posting Date",
            '..%1',
            AsOfDate);

        Page.Run(Page::"General Ledger Entries", GLEntry);
    end;

    // Check the complete COA ancestor chain, not merely the Assets/Liabilities side.
    local procedure IsUnderNamedGroup(SelectedNode: Record "AIRIQ Vertical Balance Sheet" temporary; GroupName: Text): Boolean
    var
        ParentNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        ParentID: Integer;
    begin
        ParentNode.Copy(TempNodes, true);
        ParentID := SelectedNode."Node Parent ID";
        while ParentID <> 0 do begin
            if not ParentNode.Get(ParentID) then
                exit(false);
            if ParentNode."Node Is Group" and
               (UpperCase(DelChr(ParentNode."Node Name", '<>', ' ')) = GroupName) then
                exit(true);
            ParentID := ParentNode."Node Parent ID";
        end;
        exit(false);
    end;

    local procedure OpenPartyBalances(AccountNo: Code[20]; IsVendor: Boolean)
    var
        PartyPage: Page "AIRIQ BS Party Balances";
    begin
        Clear(PartyPage);
        PartyPage.LoadBalances(AccountNo, AsOfDate, IsVendor);
        PartyPage.RunModal();
    end;

    // =====================================================
    // EXCEL EXPORT
    // Preserves previous export behavior:
    // zero-balance posting accounts are excluded.
    // =====================================================

    local procedure ExportBalanceSheetToExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ScanNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        LookupNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        LiabilityNodeIDs: List of [Integer];
        AssetNodeIDs: List of [Integer];
        RowNo: Integer;
        RowCount: Integer;
        LiabilityNodeID: Integer;
        AssetNodeID: Integer;
        FileName: Text;
    begin
        if AsOfDate = 0D then
            Error('Please enter a valid Balance As On Date.');

        ScanNode.Copy(TempNodes, true);
        LookupNode.Copy(TempNodes, true);
        ScanNode.Reset();

        if ScanNode.FindSet() then
            repeat
                // Important:
                // Excel export stays the same as the old version.
                // Groups and Profit are always included.
                // Zero-value posting ledgers are excluded.
                if ScanNode."Node Is Group" or
                   ScanNode."Node Is Profit" or
                   (ScanNode."Node Amount" <> 0)
                then
                    case ScanNode."Node Side" of
                        1:
                            LiabilityNodeIDs.Add(
                                ScanNode."Entry No.");

                        2:
                            AssetNodeIDs.Add(
                                ScanNode."Entry No.");
                    end;
            until ScanNode.Next() = 0;

        if (LiabilityNodeIDs.Count() = 0) and
           (AssetNodeIDs.Count() = 0) then
            Error(
                'There is no Balance Sheet data to export. Please recalculate first.');

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();

        // Report Title
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'AIRIQ VERTICAL BALANCE SHEET',
            true);

        AddBlankExcelColumns(ExcelBuffer, 3);

        // Company Name
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            CompanyName(),
            true);

        AddBlankExcelColumns(ExcelBuffer, 3);

        // Balance Sheet Date
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'Balance As On Date',
            true);

        ExcelBuffer.AddColumn(
            AsOfDate,
            false,
            '',
            false,
            false,
            false,
            'dd-mm-yyyy',
            ExcelBuffer."Cell Type"::Date);

        AddExcelText(
            ExcelBuffer,
            'Fiscal Year Start',
            true);

        if FiscalYearStartDate <> 0D then
            ExcelBuffer.AddColumn(
                FiscalYearStartDate,
                false,
                '',
                false,
                false,
                false,
                'dd-mm-yyyy',
                ExcelBuffer."Cell Type"::Date)
        else
            AddExcelText(
                ExcelBuffer,
                'Not found',
                false);

        // Blank Row
        ExcelBuffer.NewRow();
        AddBlankExcelColumns(ExcelBuffer, 4);

        // Column Headers
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'LIABILITIES & EQUITY',
            true);

        AddExcelText(
            ExcelBuffer,
            'Amount',
            true);

        AddExcelText(
            ExcelBuffer,
            'ASSETS',
            true);

        AddExcelText(
            ExcelBuffer,
            'Amount',
            true);

        // Calculate Row Count
        RowCount := LiabilityNodeIDs.Count();

        if AssetNodeIDs.Count() > RowCount then
            RowCount := AssetNodeIDs.Count();

        // Export Groups and Non-Zero Ledgers
        for RowNo := 1 to RowCount do begin
            ExcelBuffer.NewRow();

            LiabilityNodeID := 0;

            if RowNo <= LiabilityNodeIDs.Count() then
                LiabilityNodeID :=
                    LiabilityNodeIDs.Get(RowNo);

            AddExcelNodePair(
                ExcelBuffer,
                LookupNode,
                LiabilityNodeID);

            AssetNodeID := 0;

            if RowNo <= AssetNodeIDs.Count() then
                AssetNodeID :=
                    AssetNodeIDs.Get(RowNo);

            AddExcelNodePair(
                ExcelBuffer,
                LookupNode,
                AssetNodeID);
        end;

        // Grand Total Row
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'TOTAL LIABILITIES & EQUITY',
            true);

        AddExcelAmount(
            ExcelBuffer,
            TotalLiabilities,
            true);

        AddExcelText(
            ExcelBuffer,
            'TOTAL ASSETS',
            true);

        AddExcelAmount(
            ExcelBuffer,
            TotalAssets,
            true);

        // Blank Row
        ExcelBuffer.NewRow();
        AddBlankExcelColumns(ExcelBuffer, 4);

        // Summary Heading
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'BALANCE SHEET SUMMARY',
            true);

        AddBlankExcelColumns(ExcelBuffer, 3);

        // Current Year Profit / Loss
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'Current Year Profit / Loss',
            false);

        AddExcelAmount(
            ExcelBuffer,
            CurrentProfitLoss,
            false);

        AddBlankExcelColumns(ExcelBuffer, 2);

        // Balance Difference
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'Balance Difference (Assets - Liabilities)',
            true);

        AddExcelAmount(
            ExcelBuffer,
            BalanceDifference,
            true);

        AddBlankExcelColumns(ExcelBuffer, 2);

        // Validation Issues
        ExcelBuffer.NewRow();

        AddExcelText(
            ExcelBuffer,
            'Account Validation Issues',
            false);

        ExcelBuffer.AddColumn(
            ValidationIssueCount,
            false,
            '',
            false,
            false,
            false,
            '0',
            ExcelBuffer."Cell Type"::Number);

        AddBlankExcelColumns(ExcelBuffer, 2);

        // File Name
        FileName := StrSubstNo(
            'AIRIQ_Vertical_Balance_Sheet_%1',
            Format(
                AsOfDate,
                0,
                '<Year4><Month,2><Day,2>'));

        ExcelBuffer.CreateNewBook(
            'Vertical Balance Sheet');

        ExcelBuffer.WriteSheet(
            'AIRIQ Vertical Balance Sheet',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        ExcelBuffer.SetFriendlyFilename(FileName);

        ExcelBuffer.OpenExcel();
    end;

    // =====================================================
    // EXCEL TEXT HELPER
    // =====================================================

    local procedure AddExcelText(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        ValueText: Text;
        IsBold: Boolean)
    begin
        ExcelBuffer.AddColumn(
            ValueText,
            false,
            '',
            IsBold,
            false,
            false,
            '',
            ExcelBuffer."Cell Type"::Text);
    end;

    // =====================================================
    // EXCEL NODE HELPER
    // =====================================================

    local procedure AddExcelNodePair(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        var LookupNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        NodeID: Integer)
    var
        IsBold: Boolean;
    begin
        if NodeID = 0 then begin
            AddBlankExcelColumns(ExcelBuffer, 2);
            exit;
        end;

        if not LookupNode.Get(NodeID) then
            Error(
                'Balance Sheet node %1 was not found during Excel export.',
                NodeID);

        IsBold :=
            LookupNode."Node Is Group" or
            LookupNode."Node Is Profit";

        ExcelBuffer.AddColumn(
            GetExcelNodeCaption(LookupNode),
            false,
            '',
            IsBold,
            false,
            false,
            '',
            ExcelBuffer."Cell Type"::Text);

        AddExcelAmount(
            ExcelBuffer,
            LookupNode."Node Amount",
            IsBold);
    end;

    // =====================================================
    // EXCEL INDENTATION
    // =====================================================

    local procedure GetExcelNodeCaption(
        Node: Record "AIRIQ Vertical Balance Sheet" temporary): Text
    var
        Indentation: Text;
        LevelNo: Integer;
        CaptionText: Text;
    begin
        for LevelNo := 1 to Node."Node Level" do
            Indentation += '    ';

        CaptionText := Node."Node Name";

        if (not Node."Node Is Group") and
           (not Node."Node Is Profit") and
           (Node."Node G/L Account No." <> '') then
            CaptionText := StrSubstNo(
                '%1 - %2',
                Node."Node G/L Account No.",
                Node."Node Name");

        exit(Indentation + CaptionText);
    end;

    // =====================================================
    // EXCEL AMOUNT HELPER
    // =====================================================

    local procedure AddExcelAmount(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        Amount: Decimal;
        IsBold: Boolean)
    begin
        ExcelBuffer.AddColumn(
            Amount,
            false,
            '',
            IsBold,
            false,
            false,
            '#,##0.00;[Red](#,##0.00);0.00',
            ExcelBuffer."Cell Type"::Number);
    end;

    // =====================================================
    // EXCEL BLANK COLUMN HELPER
    // =====================================================

    local procedure AddBlankExcelColumns(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        ColumnCount: Integer)
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to ColumnCount do
            ExcelBuffer.AddColumn(
                '',
                false,
                '',
                false,
                false,
                false,
                '',
                ExcelBuffer."Cell Type"::Text);
    end;

    // =====================================================
    // BUILD BALANCE SHEET
    // MODIFIED:
    // All valid Posting G/L Accounts are now added.
    // Zero Balance ledgers are included in TempNodes.
    // UI decides whether to display zero ledgers.
    // =====================================================

    local procedure BuildBalanceSheet()
    var
        GLAccount: Record "G/L Account";
        GroupStack: List of [Integer];
        ParentID: Integer;
        Side: Integer;
        AccountBalance: Decimal;
        DisplayAmount: Decimal;
        NodeID: Integer;
    begin
        if AsOfDate = 0D then
            Error('Please enter a valid Balance As On Date.');

        TempNodes.Reset();
        TempNodes.DeleteAll();

        NextNodeID := 0;
        TotalAssets := 0;
        TotalLiabilities := 0;
        CurrentProfitLoss := 0;
        BalanceDifference := 0;
        ValidationIssueCount := 0;

        Clear(ValidationDetails);
        Clear(GroupStack);

        FindFiscalYearStart();

        GLAccount.Reset();
        GLAccount.SetCurrentKey("No.");

        GLAccount.SetRange(
            "Income/Balance",
            GLAccount."Income/Balance"::"Balance Sheet");

        GLAccount.SetFilter(
            "Date Filter",
            '..%1',
            AsOfDate);

        if GLAccount.FindSet() then
            repeat
                case GLAccount."Account Type" of

                    GLAccount."Account Type"::"Begin-Total":
                        begin
                            ParentID :=
                                GetStackParent(GroupStack);

                            Side :=
                                DetermineSide(GLAccount, ParentID);

                            if Side = 0 then begin
                                GroupStack.Add(0);

                                AddValidationIssue(
                                    StrSubstNo(
                                        'Group %1 - %2 has no valid side/category.',
                                        GLAccount."No.",
                                        GLAccount.Name));
                            end else begin
                                NodeID := AddNode(
                                    GLAccount."No.",
                                    GLAccount.Name,
                                    ParentID,
                                    GroupStack.Count(),
                                    Side,
                                    true,
                                    0,
                                    false);

                                GroupStack.Add(NodeID);

                                CheckSideMismatch(
                                    GLAccount,
                                    Side);
                            end;
                        end;

                    GLAccount."Account Type"::"End-Total":
                        CloseEndTotal(
                            GLAccount,
                            GroupStack);

                    GLAccount."Account Type"::Posting:
                        begin
                            ParentID :=
                                GetStackParent(GroupStack);

                            Side :=
                                DetermineSide(GLAccount, ParentID);

                            CheckSideMismatch(
                                GLAccount,
                                Side);

                            if ParentID = 0 then
                                AddValidationIssue(
                                    StrSubstNo(
                                        'Posting G/L %1 - %2 is not within a recognized Begin-Total group.',
                                        GLAccount."No.",
                                        GLAccount.Name));

                            GLAccount.CalcFields(
                                "Balance at Date");

                            AccountBalance :=
                                GLAccount."Balance at Date";

                            if Side = 0 then begin
                                if AccountBalance <> 0 then
                                    AddValidationIssue(
                                        StrSubstNo(
                                            'UNCLASSIFIED AMOUNT: G/L %1 - %2, balance %3.',
                                            GLAccount."No.",
                                            GLAccount.Name,
                                            AccountBalance));
                            end else begin

                                // =========================================
                                // NEW ZERO BALANCE POSTING ACCOUNT LOGIC
                                // =========================================

                                DisplayAmount := AccountBalance;

                                if Side = 1 then
                                    DisplayAmount := -DisplayAmount;

                                // Always add the Posting G/L Account.
                                // This includes amount = 0.
                                AddNode(
                                    GLAccount."No.",
                                    GLAccount.Name,
                                    ParentID,
                                    GroupStack.Count(),
                                    Side,
                                    false,
                                    DisplayAmount,
                                    false);

                                // Only non-zero amounts need to
                                // update Group and Grand Totals.
                                if DisplayAmount <> 0 then begin

                                    AddToParents(
                                        ParentID,
                                        DisplayAmount);

                                    if Side = 1 then
                                        TotalLiabilities += DisplayAmount
                                    else
                                        TotalAssets += DisplayAmount;
                                end;
                            end;
                        end;
                end;
            until GLAccount.Next() = 0;

        if GroupStack.Count() <> 0 then
            AddValidationIssue(
                StrSubstNo(
                    '%1 Begin-Total groups remain open at the end of the Balance Sheet chart.',
                    GroupStack.Count()));

        ValidateRootTotals();

        CalculateCurrentProfitLoss();

        AddNode(
            '',
            'CURRENT YEAR PROFIT / LOSS',
            0,
            0,
            1,
            false,
            CurrentProfitLoss,
            true);

        TotalLiabilities += CurrentProfitLoss;

        BalanceDifference :=
            Round(
                TotalAssets - TotalLiabilities,
                0.01);

        UpdateSummaryStyles();
    end;

    // =====================================================
    // ADD HIERARCHY NODE
    // =====================================================

    local procedure AddNode(
        AccountNo: Code[20];
        AccountName: Text;
        ParentID: Integer;
        Level: Integer;
        Side: Integer;
        IsGroup: Boolean;
        Amount: Decimal;
        IsProfit: Boolean): Integer
    var
        NewNode: Record "AIRIQ Vertical Balance Sheet" temporary;
    begin
        NewNode.Copy(TempNodes, true);

        NextNodeID += 1;

        NewNode.Init();

        NewNode."Entry No." := NextNodeID;
        NewNode."Node G/L Account No." := AccountNo;

        NewNode."Node Name" :=
            CopyStr(
                AccountName,
                1,
                MaxStrLen(NewNode."Node Name"));

        NewNode."Node Parent ID" := ParentID;
        NewNode."Node Level" := Level;
        NewNode."Node Side" := Side;
        NewNode."Node Is Group" := IsGroup;
        NewNode."Node Expanded" := false;
        NewNode."Node Amount" := Amount;
        NewNode."Node Is Profit" := IsProfit;

        NewNode.Insert();

        exit(NextNodeID);
    end;

    // =====================================================
    // GET STACK PARENT
    // =====================================================

    local procedure GetStackParent(
        GroupStack: List of [Integer]): Integer
    var
        IndexNo: Integer;
        CandidateID: Integer;
    begin
        for IndexNo := GroupStack.Count() downto 1 do begin
            CandidateID := GroupStack.Get(IndexNo);

            if CandidateID <> 0 then
                exit(CandidateID);
        end;

        exit(0);
    end;

    // =====================================================
    // DETERMINE ASSET / LIABILITY SIDE
    // =====================================================

    local procedure DetermineSide(
        GLAccount: Record "G/L Account";
        ParentID: Integer): Integer
    var
        ParentNode: Record "AIRIQ Vertical Balance Sheet" temporary;
    begin
        if ParentID <> 0 then begin
            ParentNode.Copy(TempNodes, true);

            if ParentNode.Get(ParentID) then
                exit(ParentNode."Node Side");
        end;

        exit(GetCategorySide(GLAccount));
    end;

    local procedure GetCategorySide(
        GLAccount: Record "G/L Account"): Integer
    begin
        case GLAccount."Account Category" of
            GLAccount."Account Category"::Assets:
                exit(2);

            GLAccount."Account Category"::Liabilities,
            GLAccount."Account Category"::Equity:
                exit(1);
        end;

        exit(0);
    end;

    // =====================================================
    // VALIDATE ACCOUNT CATEGORY
    // =====================================================

    local procedure CheckSideMismatch(
        GLAccount: Record "G/L Account";
        AssignedSide: Integer)
    var
        CategorySide: Integer;
    begin
        CategorySide := GetCategorySide(GLAccount);

        if CategorySide = 0 then begin
            if GLAccount."Account Type" =
               GLAccount."Account Type"::Posting then
                AddValidationIssue(
                    StrSubstNo(
                        'Posting G/L %1 - %2 has an empty or invalid Account Category.',
                        GLAccount."No.",
                        GLAccount.Name));

            exit;
        end;

        if (AssignedSide <> 0) and
           (AssignedSide <> CategorySide) then
            AddValidationIssue(
                StrSubstNo(
                    'G/L %1 - %2 category conflicts with its COA parent. Check grouping.',
                    GLAccount."No.",
                    GLAccount.Name));
    end;

    // =====================================================
    // CLOSE END-TOTAL GROUP
    // =====================================================

    local procedure CloseEndTotal(
        GLAccount: Record "G/L Account";
        var GroupStack: List of [Integer])
    var
        ClosingNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        OpeningNo: Code[20];
        RangeText: Text;
        SeparatorPos: Integer;
        ClosingNodeID: Integer;
    begin
        if GroupStack.Count() = 0 then begin
            AddValidationIssue(
                StrSubstNo(
                    'Unmatched End-Total %1 - %2.',
                    GLAccount."No.",
                    GLAccount.Name));

            exit;
        end;

        ClosingNodeID :=
            GroupStack.Get(GroupStack.Count());

        GroupStack.RemoveAt(GroupStack.Count());

        if ClosingNodeID = 0 then
            exit;

        ClosingNode.Copy(TempNodes, true);

        if not ClosingNode.Get(ClosingNodeID) then
            exit;

        RangeText := GLAccount.Totaling;

        SeparatorPos := StrPos(RangeText, '..');

        if SeparatorPos <= 1 then begin
            AddValidationIssue(
                StrSubstNo(
                    'End-Total %1 - %2 has an empty/non-range Totaling value: %3.',
                    GLAccount."No.",
                    GLAccount.Name,
                    RangeText));

            exit;
        end;

        OpeningNo :=
            CopyStr(
                CopyStr(
                    RangeText,
                    1,
                    SeparatorPos - 1),
                1,
                MaxStrLen(OpeningNo));

        if OpeningNo <>
           ClosingNode."Node G/L Account No." then
            AddValidationIssue(
                StrSubstNo(
                    'End-Total %1 should close Begin-Total %2, but Totaling begins with %3.',
                    GLAccount."No.",
                    ClosingNode."Node G/L Account No.",
                    OpeningNo));
    end;

    // =====================================================
    // ADD AMOUNT TO PARENT GROUPS
    // =====================================================

    local procedure AddToParents(
        ParentID: Integer;
        Amount: Decimal)
    var
        ParentNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        NextParentID: Integer;
        Guard: Integer;
    begin
        ParentNode.Copy(TempNodes, true);

        while ParentID <> 0 do begin
            Guard += 1;

            if Guard > 100 then
                Error(
                    'Invalid circular Balance Sheet hierarchy.');

            if not ParentNode.Get(ParentID) then
                Error(
                    'Missing Balance Sheet parent node %1.',
                    ParentID);

            NextParentID :=
                ParentNode."Node Parent ID";

            ParentNode."Node Amount" += Amount;
            ParentNode.Modify();

            ParentID := NextParentID;
        end;
    end;

    // =====================================================
    // VALIDATE ROOT TOTALS
    // =====================================================

    local procedure ValidateRootTotals()
    var
        RootNode: Record "AIRIQ Vertical Balance Sheet" temporary;
        LeftRootTotal: Decimal;
        RightRootTotal: Decimal;
    begin
        RootNode.Copy(TempNodes, true);
        RootNode.Reset();

        RootNode.SetRange(
            "Node Parent ID",
            0);

        if RootNode.FindSet() then
            repeat
                case RootNode."Node Side" of
                    1:
                        LeftRootTotal += RootNode."Node Amount";

                    2:
                        RightRootTotal += RootNode."Node Amount";
                end;
            until RootNode.Next() = 0;

        if Round(
            LeftRootTotal - TotalLiabilities,
            0.01) <> 0 then
            AddValidationIssue(
                'Liability hierarchy root subtotal does not reconcile to posting-account total.');

        if Round(
            RightRootTotal - TotalAssets,
            0.01) <> 0 then
            AddValidationIssue(
                'Asset hierarchy root subtotal does not reconcile to posting-account total.');
    end;

    // =====================================================
    // CURRENT YEAR PROFIT / LOSS
    // =====================================================

    local procedure CalculateCurrentProfitLoss()
    var
        GLAccount: Record "G/L Account";
        NetChange: Decimal;
    begin
        CurrentProfitLoss := 0;

        GLAccount.Reset();

        GLAccount.SetRange(
            "Account Type",
            GLAccount."Account Type"::Posting);

        GLAccount.SetRange(
            "Income/Balance",
            GLAccount."Income/Balance"::"Income Statement");

        if FiscalYearStartDate <> 0D then
            GLAccount.SetRange(
                "Date Filter",
                FiscalYearStartDate,
                AsOfDate)
        else
            GLAccount.SetFilter(
                "Date Filter",
                '..%1',
                AsOfDate);

        if GLAccount.FindSet() then
            repeat
                GLAccount.CalcFields("Net Change");

                NetChange += GLAccount."Net Change";
            until GLAccount.Next() = 0;

        CurrentProfitLoss := -NetChange;
    end;

    // =====================================================
    // FIND FISCAL YEAR START
    // =====================================================

    local procedure FindFiscalYearStart()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        Clear(FiscalYearStartDate);

        AccountingPeriod.Reset();

        AccountingPeriod.SetCurrentKey(
            "Starting Date");

        AccountingPeriod.SetRange(
            "New Fiscal Year",
            true);

        AccountingPeriod.SetFilter(
            "Starting Date",
            '..%1',
            AsOfDate);

        if AccountingPeriod.FindLast() then
            FiscalYearStartDate :=
                AccountingPeriod."Starting Date"
        else
            AddValidationIssue(
                'Fiscal year start not found; P/L uses all entries to the selected date.');
    end;

    // =====================================================
    // VALIDATION ISSUE MESSAGE
    // =====================================================

    local procedure AddValidationIssue(
        IssueText: Text)
    begin
        ValidationIssueCount += 1;

        if StrLen(ValidationDetails) < 15000 then
            ValidationDetails +=
                StrSubstNo(
                    '%1. %2\',
                    ValidationIssueCount,
                    IssueText);
    end;

    // =====================================================
    // SUMMARY STYLES
    // =====================================================

    local procedure UpdateSummaryStyles()
    begin
        if BalanceDifference = 0 then
            DifferenceStyle := 'Favorable'
        else
            DifferenceStyle := 'Unfavorable';

        if ValidationIssueCount = 0 then
            ValidationStyle := 'Favorable'
        else
            ValidationStyle := 'Unfavorable';
    end;
}
