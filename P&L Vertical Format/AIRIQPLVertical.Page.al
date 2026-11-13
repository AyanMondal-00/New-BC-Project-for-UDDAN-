
page 50462 "P&L Vertical Format"
{
    Caption = 'P&L Vertical Format';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            group(Filters)
            {
                Caption = 'Profit & Loss Filters';

                field(DateFilterMode; DateFilterMode)
                {
                    ApplicationArea = All;
                    Caption = 'Date Selection';
                    ToolTip = 'Use the current fiscal year or enter a custom date range.';

                    trigger OnValidate()
                    begin
                        if DateFilterMode = DateFilterMode::"Current Fiscal Year" then
                            SetDefaultFinancialYearDates();
                        RefreshPL();
                    end;
                }

                field(StartingDate; StartingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ToolTip = 'First posting date included in the profit and loss statement.';

                    trigger OnValidate()
                    begin
                        DateFilterMode := DateFilterMode::"Custom Date Range";
                        RefreshPL();
                    end;
                }

                field(EndingDate; EndingDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ToolTip = 'Last posting date included in the profit and loss statement.';

                    trigger OnValidate()
                    begin
                        DateFilterMode := DateFilterMode::"Custom Date Range";
                        RefreshPL();
                    end;
                }
            }

            usercontrol(PLTree; "AIRIQ P&L Tree AddIn")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    AddInIsReady := true;
                    PushPL();
                end;

                trigger NodeActivated(NodeId: Integer)
                begin
                    OpenNodeDetails(NodeId);
                end;
            }

            group(Summary)
            {
                Caption = 'Profit & Loss Summary';

                field(IncomeBeforeBalancing; IncomeBeforeBalancing)
                {
                    ApplicationArea = All;
                    Caption = 'Total Income (Before Net Result)';
                    Editable = false;
                }

                field(ExpensesBeforeBalancing; ExpensesBeforeBalancing)
                {
                    ApplicationArea = All;
                    Caption = 'Total Expenses (Before Net Result)';
                    Editable = false;
                }

                field(DirectIncome; DirectIncome)
                {
                    ApplicationArea = All;
                    Caption = 'Direct Income (Including Sales)';
                    Editable = false;
                }

                field(DirectExpenses; DirectExpenses)
                {
                    ApplicationArea = All;
                    Caption = 'Direct Expenses (Including Purchases)';
                    Editable = false;
                }

                field(GrossProfitLoss; GrossProfitLoss)
                {
                    ApplicationArea = All;
                    Caption = 'Gross Profit / (Loss)';
                    Editable = false;
                    StyleExpr = GrossStyle;
                }

                field(NetProfitLoss; NetProfitLoss)
                {
                    ApplicationArea = All;
                    Caption = 'Net Profit / (Loss)';
                    Editable = false;
                    StyleExpr = ProfitStyle;
                }

                field(TotalExpenses; TotalExpenses)
                {
                    ApplicationArea = All;
                    Caption = 'Expenses Side Grand Total';
                    Editable = false;
                }

                field(TotalIncome; TotalIncome)
                {
                    ApplicationArea = All;
                    Caption = 'Income Side Grand Total';
                    Editable = false;
                }

                field(BalanceDifference; BalanceDifference)
                {
                    ApplicationArea = All;
                    Caption = 'Difference';
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
                    RefreshPL();
                end;
            }

            // NEW ACTION: EXPORT TO EXCEL
            action(ExportToExcel)
            {
                Caption = 'Export to Excel';
                ApplicationArea = All;
                Image = ExportToExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Export the full P&L hierarchy for the selected date range.';

                trigger OnAction()
                begin
                    ExportPLToExcel();
                end;
            }

            action(UseCurrentFiscalYear)
            {
                Caption = 'Current Financial Year';
                ApplicationArea = All;
                Image = Calendar;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    DateFilterMode := DateFilterMode::"Current Fiscal Year";
                    SetDefaultFinancialYearDates();
                    RefreshPL();
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
        DateFilterMode := DateFilterMode::"Current Fiscal Year";
        SetDefaultFinancialYearDates();
        BuildPL();
    end;

    var
        TempNodes: Record "AIRIQ P&L Vertical" temporary;
        StartingDate: Date;
        EndingDate: Date;
        DateFilterMode: Option "Current Fiscal Year","Custom Date Range";
        ExpensesBeforeBalancing: Decimal;
        IncomeBeforeBalancing: Decimal;
        TotalExpenses: Decimal;
        TotalIncome: Decimal;
        NetProfitLoss: Decimal;
        DirectIncome: Decimal;
        DirectExpenses: Decimal;
        GrossProfitLoss: Decimal;
        GrossStyle: Text;
        BalanceDifference: Decimal;
        ValidationIssueCount: Integer;
        ValidationDetails: Text;
        ProfitStyle: Text;
        DifferenceStyle: Text;
        ValidationStyle: Text;
        NextNodeID: Integer;
        AddInIsReady: Boolean;
        FiscalYearNotConfigured: Boolean;

    // =====================================================
    // NEW: EXPORT P&L TO EXCEL
    // =====================================================

    local procedure ExportPLToExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        ScanNode: Record "AIRIQ P&L Vertical" temporary;
        LookupNode: Record "AIRIQ P&L Vertical" temporary;
        ExpenseNodeIDs: List of [Integer];
        IncomeNodeIDs: List of [Integer];
        RowNo: Integer;
        RowCount: Integer;
        ExpenseNodeID: Integer;
        IncomeNodeID: Integer;
        FileName: Text;
    begin
        if (StartingDate = 0D) or (EndingDate = 0D) then
            Error('Enter both Starting Date and Ending Date.');

        if StartingDate > EndingDate then
            Error('Starting Date cannot be later than Ending Date.');

        // Export the existing calculated hierarchy.
        // Collapsed groups and zero-balance ledgers are included.
        ScanNode.Copy(TempNodes, true);
        LookupNode.Copy(TempNodes, true);
        ScanNode.Reset();

        if ScanNode.FindSet() then
            repeat
                case ScanNode."Node Side" of
                    1:
                        ExpenseNodeIDs.Add(ScanNode."Entry No.");
                    2:
                        IncomeNodeIDs.Add(ScanNode."Entry No.");
                end;
            until ScanNode.Next() = 0;

        if (ExpenseNodeIDs.Count() = 0) and
           (IncomeNodeIDs.Count() = 0) then
            Error('There is no P&L data to export. Please recalculate first.');

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();

        // Report Title
        ExcelBuffer.NewRow();
        AddPLExcelText(
            ExcelBuffer,
            'AIRIQ P&L VERTICAL FORMAT',
            true);
        AddPLExcelBlanks(ExcelBuffer, 3);

        // Company Name
        ExcelBuffer.NewRow();
        AddPLExcelText(
            ExcelBuffer,
            CompanyName(),
            true);
        AddPLExcelBlanks(ExcelBuffer, 3);

        // Selected Date Range
        ExcelBuffer.NewRow();

        AddPLExcelText(
            ExcelBuffer,
            'Starting Date',
            true);

        AddPLExcelDate(
            ExcelBuffer,
            StartingDate);

        AddPLExcelText(
            ExcelBuffer,
            'Ending Date',
            true);

        AddPLExcelDate(
            ExcelBuffer,
            EndingDate);

        // Blank Row
        ExcelBuffer.NewRow();
        AddPLExcelBlanks(ExcelBuffer, 4);

        // Column Headers
        ExcelBuffer.NewRow();

        AddPLExcelText(
            ExcelBuffer,
            'EXPENSES',
            true);

        AddPLExcelText(
            ExcelBuffer,
            'Amount',
            true);

        AddPLExcelText(
            ExcelBuffer,
            'INCOME',
            true);

        AddPLExcelText(
            ExcelBuffer,
            'Amount',
            true);

        // Number of rows needed for both sides
        RowCount := ExpenseNodeIDs.Count();

        if IncomeNodeIDs.Count() > RowCount then
            RowCount := IncomeNodeIDs.Count();

        // All Groups, Subgroups and Posting Ledgers
        for RowNo := 1 to RowCount do begin
            ExcelBuffer.NewRow();

            // Left Side: Expenses
            ExpenseNodeID := 0;

            if RowNo <= ExpenseNodeIDs.Count() then
                ExpenseNodeID :=
                    ExpenseNodeIDs.Get(RowNo);

            AddPLExcelNodePair(
                ExcelBuffer,
                LookupNode,
                ExpenseNodeID);

            // Right Side: Income
            IncomeNodeID := 0;

            if RowNo <= IncomeNodeIDs.Count() then
                IncomeNodeID :=
                    IncomeNodeIDs.Get(RowNo);

            AddPLExcelNodePair(
                ExcelBuffer,
                LookupNode,
                IncomeNodeID);
        end;

        // Grand Total
        ExcelBuffer.NewRow();

        AddPLExcelText(
            ExcelBuffer,
            'TOTAL EXPENSES',
            true);

        AddPLExcelAmount(
            ExcelBuffer,
            TotalExpenses,
            true);

        AddPLExcelText(
            ExcelBuffer,
            'TOTAL INCOME',
            true);

        AddPLExcelAmount(
            ExcelBuffer,
            TotalIncome,
            true);

        // Blank Row
        ExcelBuffer.NewRow();
        AddPLExcelBlanks(ExcelBuffer, 4);

        // Summary Heading
        ExcelBuffer.NewRow();

        AddPLExcelText(
            ExcelBuffer,
            'PROFIT & LOSS SUMMARY',
            true);

        AddPLExcelBlanks(ExcelBuffer, 3);

        // Summary Amounts
        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Direct Income (Including Sales)',
            DirectIncome);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Direct Expenses (Including Purchases)',
            DirectExpenses);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Gross Profit / (Loss)',
            GrossProfitLoss);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Total Income (Before Net Result)',
            IncomeBeforeBalancing);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Total Expenses (Before Net Result)',
            ExpensesBeforeBalancing);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Net Profit / (Loss)',
            NetProfitLoss);

        AddPLExcelSummaryRow(
            ExcelBuffer,
            'Balance Difference',
            BalanceDifference);

        // Validation Issue Count
        ExcelBuffer.NewRow();

        AddPLExcelText(
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

        AddPLExcelBlanks(ExcelBuffer, 2);

        // Excel Filename
        FileName := StrSubstNo(
            'AIRIQ_PL_Vertical_%1_to_%2',
            Format(
                StartingDate,
                0,
                '<Year4><Month,2><Day,2>'),
            Format(
                EndingDate,
                0,
                '<Year4><Month,2><Day,2>'));

        // Create Workbook
        ExcelBuffer.CreateNewBook(
            'P&L Vertical Format');

        ExcelBuffer.WriteSheet(
            'AIRIQ P&L Vertical Format',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        ExcelBuffer.SetFriendlyFilename(FileName);

        ExcelBuffer.OpenExcel();
    end;

    // =====================================================
    // EXCEL NODE + AMOUNT
    // =====================================================

    local procedure AddPLExcelNodePair(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        var LookupNode: Record "AIRIQ P&L Vertical" temporary;
        NodeID: Integer)
    var
        IsBold: Boolean;
    begin
        if NodeID = 0 then begin
            AddPLExcelBlanks(ExcelBuffer, 2);
            exit;
        end;

        if not LookupNode.Get(NodeID) then
            Error(
                'P&L node %1 was not found during Excel export.',
                NodeID);

        IsBold :=
            LookupNode."Node Is Group" or
            LookupNode."Node Is Profit";

        AddPLExcelText(
            ExcelBuffer,
            GetPLExcelNodeCaption(LookupNode),
            IsBold);

        AddPLExcelAmount(
            ExcelBuffer,
            LookupNode."Node Amount",
            IsBold);
    end;

    // =====================================================
    // EXCEL HIERARCHY INDENTATION
    // =====================================================

    local procedure GetPLExcelNodeCaption(
        Node: Record "AIRIQ P&L Vertical" temporary): Text
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
    // EXCEL SUMMARY ROW
    // =====================================================

    local procedure AddPLExcelSummaryRow(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        CaptionText: Text;
        Amount: Decimal)
    begin
        ExcelBuffer.NewRow();

        AddPLExcelText(
            ExcelBuffer,
            CaptionText,
            true);

        AddPLExcelAmount(
            ExcelBuffer,
            Amount,
            true);

        AddPLExcelBlanks(ExcelBuffer, 2);
    end;

    // =====================================================
    // EXCEL TEXT CELL - 8 PARAMETERS
    // =====================================================

    local procedure AddPLExcelText(
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
    // EXCEL NUMERIC CELL - 8 PARAMETERS
    // =====================================================

    local procedure AddPLExcelAmount(
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
    // EXCEL DATE CELL - 8 PARAMETERS
    // =====================================================

    local procedure AddPLExcelDate(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        ValueDate: Date)
    begin
        ExcelBuffer.AddColumn(
            ValueDate,
            false,
            '',
            false,
            false,
            false,
            'dd-mm-yyyy',
            ExcelBuffer."Cell Type"::Date);
    end;

    // =====================================================
    // EXCEL BLANK COLUMNS
    // =====================================================

    local procedure AddPLExcelBlanks(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        ColumnCount: Integer)
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to ColumnCount do
            AddPLExcelText(
                ExcelBuffer,
                '',
                false);
    end;

    // =====================================================
    // EXISTING P&L LOGIC - UNCHANGED
    // =====================================================

    local procedure RefreshPL()
    begin
        BuildPL();
        PushPL();
        CurrPage.Update(false);
    end;

    local procedure SetDefaultFinancialYearDates()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        EndingDate := WorkDate();
        FiscalYearNotConfigured := false;

        AccountingPeriod.Reset();
        AccountingPeriod.SetCurrentKey("Starting Date");
        AccountingPeriod.SetRange("New Fiscal Year", true);
        AccountingPeriod.SetFilter("Starting Date", '..%1', EndingDate);

        if AccountingPeriod.FindLast() then
            StartingDate := AccountingPeriod."Starting Date"
        else begin
            StartingDate := CalcDate('<-CY>', EndingDate);
            FiscalYearNotConfigured := true;
        end;
    end;

    local procedure PushPL()
    var
        Payload: JsonObject;
        Nodes: JsonArray;
        Node: JsonObject;
        ScanNode: Record "AIRIQ P&L Vertical" temporary;
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
        Payload.Add('totalExpenses', TotalExpenses);
        Payload.Add('totalIncome', TotalIncome);
        Payload.Add('profit', NetProfitLoss);
        Payload.Add('grossProfit', GrossProfitLoss);
        Payload.Add('directIncome', DirectIncome);
        Payload.Add('directExpenses', DirectExpenses);
        Payload.Add('difference', BalanceDifference);
        Payload.Add('validationIssues', ValidationIssueCount);
        Payload.Add('startingDate', Format(StartingDate));
        Payload.Add('endingDate', Format(EndingDate));

        Payload.WriteTo(PayloadText);
        CurrPage.PLTree.SetPLData(PayloadText);
    end;

    local procedure OpenNodeDetails(NodeId: Integer)
    var
        Node: Record "AIRIQ P&L Vertical" temporary;
        GLEntry: Record "G/L Entry";
    begin
        if NodeId = 0 then
            exit;

        Node.Copy(TempNodes, true);

        if not Node.Get(NodeId) then
            exit;

        if Node."Node Is Group" or Node."Node Is Profit" then
            exit;

        if Node."Node G/L Account No." = '' then
            exit;

        GLEntry.Reset();
        GLEntry.SetRange(
            "G/L Account No.",
            Node."Node G/L Account No.");

        GLEntry.SetRange(
            "Posting Date",
            StartingDate,
            EndingDate);

        Page.Run(
            Page::"General Ledger Entries",
            GLEntry);
    end;

    local procedure BuildPL()
    var
        GLAccount: Record "G/L Account";
        GroupStack: List of [Integer];
        ParentID: Integer;
        Side: Integer;
        AccountNetChange: Decimal;
        DisplayAmount: Decimal;
        NodeID: Integer;
    begin
        if (StartingDate = 0D) or (EndingDate = 0D) then
            Error('Enter both Starting Date and Ending Date.');

        if StartingDate > EndingDate then
            Error('Starting Date cannot be later than Ending Date.');

        TempNodes.Reset();
        TempNodes.DeleteAll();

        NextNodeID := 0;
        IncomeBeforeBalancing := 0;
        ExpensesBeforeBalancing := 0;
        TotalExpenses := 0;
        TotalIncome := 0;
        NetProfitLoss := 0;
        BalanceDifference := 0;
        DirectIncome := 0;
        DirectExpenses := 0;
        GrossProfitLoss := 0;
        ValidationIssueCount := 0;

        Clear(ValidationDetails);
        Clear(GroupStack);

        if FiscalYearNotConfigured and
           (DateFilterMode = DateFilterMode::"Current Fiscal Year") then
            AddValidationIssue(
                'No New Fiscal Year accounting period found. Calendar-year start is a fallback; configure Accounting Periods or select a custom date range.');

        GLAccount.Reset();
        GLAccount.SetCurrentKey("No.");

        GLAccount.SetRange(
            "Income/Balance",
            GLAccount."Income/Balance"::"Income Statement");

        GLAccount.SetRange(
            "Date Filter",
            StartingDate,
            EndingDate);

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
                                        'Group %1 - %2 has no recognizable income/expense side.',
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
                                        'Posting G/L %1 - %2 is outside a recognized Begin-Total group.',
                                        GLAccount."No.",
                                        GLAccount.Name));

                            GLAccount.CalcFields("Net Change");

                            AccountNetChange :=
                                GLAccount."Net Change";

                            if Side = 0 then begin
                                AddValidationIssue(
                                    StrSubstNo(
                                        'Unclassified posting G/L %1 - %2, net change %3.',
                                        GLAccount."No.",
                                        GLAccount.Name,
                                        AccountNetChange));
                            end else begin

                                DisplayAmount :=
                                    AccountNetChange;

                                if Side = 2 then
                                    DisplayAmount :=
                                        -DisplayAmount;

                                // Includes zero-balance Posting accounts.
                                AddNode(
                                    GLAccount."No.",
                                    GLAccount.Name,
                                    ParentID,
                                    GroupStack.Count(),
                                    Side,
                                    false,
                                    DisplayAmount,
                                    false);

                                AddToParents(
                                    ParentID,
                                    DisplayAmount);

                                if IsDirectTradingAccount(
                                    GLAccount."No.",
                                    ParentID,
                                    Side) then
                                    if Side = 1 then
                                        DirectExpenses += DisplayAmount
                                    else
                                        DirectIncome += DisplayAmount;

                                if Side = 1 then
                                    ExpensesBeforeBalancing +=
                                        DisplayAmount
                                else
                                    IncomeBeforeBalancing +=
                                        DisplayAmount;
                            end;
                        end;
                end;
            until GLAccount.Next() = 0;

        if GroupStack.Count() <> 0 then
            AddValidationIssue(
                StrSubstNo(
                    '%1 Begin-Total groups remain open in the P&L chart.',
                    GroupStack.Count()));

        ValidateRootTotals();

        GrossProfitLoss :=
            Round(
                DirectIncome - DirectExpenses,
                0.01);

        if GrossProfitLoss >= 0 then
            GrossStyle := 'Favorable'
        else
            GrossStyle := 'Unfavorable';

        NetProfitLoss :=
            Round(
                IncomeBeforeBalancing - ExpensesBeforeBalancing,
                0.01);

        TotalExpenses := ExpensesBeforeBalancing;
        TotalIncome := IncomeBeforeBalancing;

        if NetProfitLoss >= 0 then begin

            AddNode(
                '',
                'NET PROFIT',
                0,
                0,
                1,
                false,
                NetProfitLoss,
                true);

            TotalExpenses += NetProfitLoss;

        end else begin

            AddNode(
                '',
                'NET LOSS',
                0,
                0,
                2,
                false,
                -NetProfitLoss,
                true);

            TotalIncome += -NetProfitLoss;
        end;

        BalanceDifference :=
            Round(
                TotalIncome - TotalExpenses,
                0.01);

        UpdateSummaryStyles();
    end;

    local procedure IsDirectTradingAccount(
        AccountNo: Code[20];
        ParentID: Integer;
        Side: Integer): Boolean
    var
        ParentNode: Record "AIRIQ P&L Vertical" temporary;
        ParentAccountNo: Code[20];
        Guard: Integer;
    begin
        // AIRIQ COA Sales / Purchases classification.
        if Side = 2 then
            if (AccountNo = '30010') or
               (AccountNo = '30101') then
                exit(true);

        if Side = 1 then
            if (AccountNo = '40010') or
               (AccountNo = '40301') then
                exit(true);

        ParentNode.Copy(TempNodes, true);

        while ParentID <> 0 do begin
            Guard += 1;

            if Guard > 100 then
                Error(
                    'Circular account group detected in direct trading classification.');

            if not ParentNode.Get(ParentID) then
                exit(false);

            ParentAccountNo :=
                ParentNode."Node G/L Account No.";

            if Side = 2 then
                if (ParentAccountNo = '30010') or
                   (ParentAccountNo = '30101') then
                    exit(true);

            if Side = 1 then
                if (ParentAccountNo = '40010') or
                   (ParentAccountNo = '40301') then
                    exit(true);

            ParentID :=
                ParentNode."Node Parent ID";
        end;

        exit(false);
    end;

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
        NewNode: Record "AIRIQ P&L Vertical" temporary;
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

    local procedure DetermineSide(
        GLAccount: Record "G/L Account";
        ParentID: Integer): Integer
    var
        ParentNode: Record "AIRIQ P&L Vertical" temporary;
        CategorySide: Integer;
    begin
        if ParentID <> 0 then begin
            ParentNode.Copy(TempNodes, true);

            if ParentNode.Get(ParentID) then
                exit(ParentNode."Node Side");
        end;

        CategorySide := GetCategorySide(GLAccount);

        if CategorySide <> 0 then
            exit(CategorySide);

        if GLAccount."No." = '30000' then
            exit(2);

        if GLAccount."No." = '40000' then
            exit(1);

        exit(0);
    end;

    local procedure GetCategorySide(
        GLAccount: Record "G/L Account"): Integer
    begin
        case GLAccount."Account Category" of

            GLAccount."Account Category"::Income:
                exit(2);

            GLAccount."Account Category"::"Cost of Goods Sold",
            GLAccount."Account Category"::Expense:
                exit(1);
        end;

        exit(0);
    end;

    local procedure CheckSideMismatch(
        GLAccount: Record "G/L Account";
        AssignedSide: Integer)
    var
        CategorySide: Integer;
    begin
        CategorySide :=
            GetCategorySide(GLAccount);

        if CategorySide = 0 then begin

            if GLAccount."Account Type" =
               GLAccount."Account Type"::Posting then
                AddValidationIssue(
                    StrSubstNo(
                        'Posting G/L %1 - %2 has an empty/unmapped Account Category.',
                        GLAccount."No.",
                        GLAccount.Name));

            exit;
        end;

        if (AssignedSide <> 0) and
           (AssignedSide <> CategorySide) then
            AddValidationIssue(
                StrSubstNo(
                    'G/L %1 - %2 category conflicts with its COA parent side.',
                    GLAccount."No.",
                    GLAccount.Name));
    end;

    local procedure CloseEndTotal(
        GLAccount: Record "G/L Account";
        var GroupStack: List of [Integer])
    var
        ClosingNode: Record "AIRIQ P&L Vertical" temporary;
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
                    'End-Total %1 - %2 has no valid Totaling range: %3.',
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

    local procedure AddToParents(
        ParentID: Integer;
        Amount: Decimal)
    var
        ParentNode: Record "AIRIQ P&L Vertical" temporary;
        NextParentID: Integer;
        Guard: Integer;
    begin
        ParentNode.Copy(TempNodes, true);

        while ParentID <> 0 do begin
            Guard += 1;

            if Guard > 100 then
                Error('Invalid circular P&L hierarchy.');

            if not ParentNode.Get(ParentID) then
                Error(
                    'Missing P&L parent node %1.',
                    ParentID);

            NextParentID :=
                ParentNode."Node Parent ID";

            ParentNode."Node Amount" += Amount;
            ParentNode.Modify();

            ParentID := NextParentID;
        end;
    end;

    local procedure ValidateRootTotals()
    var
        RootNode: Record "AIRIQ P&L Vertical" temporary;
        RootExpenses: Decimal;
        RootIncome: Decimal;
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
                        RootExpenses +=
                            RootNode."Node Amount";

                    2:
                        RootIncome +=
                            RootNode."Node Amount";
                end;
            until RootNode.Next() = 0;

        if Round(
            RootExpenses - ExpensesBeforeBalancing,
            0.01) <> 0 then
            AddValidationIssue(
                'Expense hierarchy root totals do not reconcile to expense posting totals.');

        if Round(
            RootIncome - IncomeBeforeBalancing,
            0.01) <> 0 then
            AddValidationIssue(
                'Income hierarchy root totals do not reconcile to income posting totals.');
    end;

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

    local procedure UpdateSummaryStyles()
    begin
        if NetProfitLoss >= 0 then
            ProfitStyle := 'Favorable'
        else
            ProfitStyle := 'Unfavorable';

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
