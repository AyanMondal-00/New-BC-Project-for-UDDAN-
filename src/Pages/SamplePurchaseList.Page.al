
page 50310 "Sample Purchase List"
{
    Caption = 'Sample Purchase Format';
    PageType = List;
    SourceTable = "Sample Purchase";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Selection: Integer;
                    begin
                        Selection := StrMenu(
                            'Air India,IndiGo,SpiceJet',
                            1,
                            'Select Airline:');

                        if Selection <> 0 then begin
                            case Selection of
                                1:
                                    Text := 'Air India';
                                2:
                                    Text := 'IndiGo';
                                3:
                                    Text := 'SpiceJet';
                            end;

                            exit(true);
                        end;
                    end;
                }

                field("Supplier ID"; Rec."Supplier ID")
                {
                    ApplicationArea = All;
                }

                field("Select"; Rec."Select")
                {
                    ApplicationArea = All;
                }

                field("Invoice Created"; InvoiceCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Created';
                    Editable = false;
                }

                field("Invoice Posted"; InvoicePostedText)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Posted';
                    Editable = false;
                }

                field("Item Created"; ItemCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Item Created';
                    Editable = false;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("Total Pax"; Rec."Total Pax")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        AssertNoDirectTrackedCostEdit();
                    end;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        AssertNoDirectTrackedCostEdit();
                    end;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        AssertNoDirectTrackedCostEdit();
                    end;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        AssertNoDirectTrackedCostEdit();
                    end;
                }

                field(Type; Rec.Type)
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
            // ============================================
            // COST REVISION - TURN ON
            // ============================================

            action(EnableCostRevisionTracking)
            {
                Caption = 'Cost Revision: OFF - Turn ON';
                ApplicationArea = All;
                Image = Check;
                Promoted = true;
                PromotedCategory = Process;
                Visible = not CostRevisionEnabled;
                ToolTip = 'Enable cost revision tracking for the current user.';

                trigger OnAction()
                var
                    Tracking: Codeunit "AIRIQ Cost Revision Tracking";
                begin
                    Tracking.SetEnabled(true);
                    CostRevisionEnabled := Tracking.GetEnabled();
                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // COST REVISION - TURN OFF
            // ============================================

            action(DisableCostRevisionTracking)
            {
                Caption = 'Cost Revision: ON - Turn OFF';
                ApplicationArea = All;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;
                Visible = CostRevisionEnabled;
                ToolTip = 'Disable cost revision tracking for the current user.';

                trigger OnAction()
                var
                    Tracking: Codeunit "AIRIQ Cost Revision Tracking";
                begin
                    Tracking.SetEnabled(false);
                    CostRevisionEnabled := Tracking.GetEnabled();
                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // DEDICATED COST REVISION EDITOR
            // ============================================

            action(EditCostRevision)
            {
                Caption = 'Edit Cost Revision';
                ApplicationArea = All;
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Edit financial values in a temporary window. Only Save & Complete Revision writes to Sample Purchase and its history.';

                trigger OnAction()
                var
                    Tracking: Codeunit "AIRIQ Cost Revision Tracking";
                    Editor: Page "AIRIQ Cost Revision Editor";
                    Original: Record "Sample Purchase";
                    Edited: Record "Sample Purchase";
                begin
                    CurrPage.SaveRecord();

                    if not Tracking.GetEnabled() then
                        Error(
                            'Turn on Cost Revision Enable before editing a cost revision.');

                    Rec.TestField("Serial No.");

                    Original.Get(Rec."Serial No.");

                    Editor.LoadPurchase(Original);

                    Commit();

                    Editor.RunModal();

                    if Editor.GetCompletedPurchase(Edited) then begin
                        Tracking.SaveDedicatedRevision(
                            Original,
                            Edited);

                        CurrPage.Update(false);
                    end;
                end;
            }

            // ============================================
            // RECORD OPENING COST
            // ============================================

            action(RecordOpeningCostRevision)
            {
                Caption = 'Record Opening Cost';
                ApplicationArea = All;
                Image = New;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'After completing a normal new purchase, record its initial full financial values as Opening once.';

                trigger OnAction()
                var
                    Tracking: Codeunit "AIRIQ Cost Revision Tracking";
                begin
                    CurrPage.SaveRecord();

                    Rec.TestField("Serial No.");

                    Tracking.RecordInitialOpening(
                        Rec."Serial No.");
                end;
            }

            // ============================================
            // COST REVISION STATEMENT
            // ============================================

            action(ViewCostRevisionStatement)
            {
                Caption = 'Purchase Cost Revision Statement';
                ApplicationArea = All;
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open the PNR-wise grouped cost revision history and export it to Excel.';

                trigger OnAction()
                begin
                    Page.Run(
                        Page::"AIRIQ Cost Revision Statement");
                end;
            }

            // ============================================
            // API IMPORT BY DATE RANGE
            // ============================================

            action(ImportFromAPIByDateRange)
            {
                ApplicationArea = All;
                Caption = 'Import From API by Date Range';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import Sample Purchase records from the original AIRIQ API using an Entry Date range. Duplicate PNRs will be skipped.';

                trigger OnAction()
                var
                    SamplePurchaseAPIMgt:
                        Codeunit "Sample Purchase API Management";
                    DateDialog:
                        Page "Sample Purchase Date Dialog";
                    FromDate: Date;
                    ToDate: Date;
                begin
                    DateDialog.SetDates(Today, Today);

                    if DateDialog.RunModal() <> Action::OK then
                        exit;

                    DateDialog.GetDates(
                        FromDate,
                        ToDate);

                    if (FromDate = 0D) or (ToDate = 0D) then
                        Error(
                            'Please select both From Date and To Date.');

                    if FromDate > ToDate then
                        Error(
                            'From Date cannot be later than To Date.');

                    SamplePurchaseAPIMgt.ImportSamplePurchaseByDate(
                        FromDate,
                        ToDate);

                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // CREATE ITEMS
            // ============================================

            action("Create Items")
            {
                ApplicationArea = All;
                Caption = 'Create Items';
                Image = NewItem;

                trigger OnAction()
                var
                    SamplePurchaseItemManagement:
                        Codeunit "Sample Purchase Item Mngt";
                    SelectedSamplePurchase:
                        Record "Sample Purchase";
                begin
                    if not GetSelectedSamplePurchases(
                        SelectedSamplePurchase)
                    then
                        exit;

                    SamplePurchaseItemManagement.CreateItems(
                        SelectedSamplePurchase);

                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // CREATE PURCHASE INVOICE
            // ============================================

            action("Create Purchase Invoice action")
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Invoice';
                Image = CreateDocument;

                trigger OnAction()
                var
                    SamplePurchaseInvoiceMgt:
                        Codeunit "Sample Purchase Invoice Mngt";
                    SelectedSamplePurchase:
                        Record "Sample Purchase";
                begin
                    if not GetSelectedSamplePurchases(
                        SelectedSamplePurchase)
                    then
                        exit;

                    SamplePurchaseInvoiceMgt.CreatePurchaseInvoices(
                        SelectedSamplePurchase);

                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // CREATE AND POST PURCHASE INVOICES
            // ============================================

            action("Create & Post Purchase Invoices")
            {
                ApplicationArea = All;
                Caption = 'Create & Post Purchase Invoices';
                Image = Post;

                trigger OnAction()
                var
                    SamplePurchaseInvoiceMgt:
                        Codeunit "Sample Purchase Invoice Mngt";
                    SelectedSamplePurchase:
                        Record "Sample Purchase";
                begin
                    if not GetSelectedSamplePurchases(
                        SelectedSamplePurchase)
                    then
                        exit;

                    SamplePurchaseInvoiceMgt.CreateAndPostPurchaseInvoices(
                        SelectedSamplePurchase);

                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // NORMAL EXCEL IMPORT
            // ============================================

            action("Import from Excel")
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;

                trigger OnAction()
                var
                    SamplePurchaseExcelImport:
                        Codeunit "Sample Purchase Excel Import";
                begin
                    SamplePurchaseExcelImport.ImportFromExcel();

                    CurrPage.Update(false);
                end;
            }

            // ============================================
            // COST REVISION EXCEL IMPORT
            // ============================================

            action("Import For Cost Reversion")
            {
                ApplicationArea = All;
                Caption = 'Import For Cost Reversion';
                Image = ImportExcel;
                ToolTip =
                    'Import fare values from Excel and update existing Sample Purchase records by PNR.';

                trigger OnAction()
                var
                    FareAlterationImport:
                        Codeunit "Fare Alteration Import";
                begin
                    FareAlterationImport.ImportFareAlteration();

                    CurrPage.Update(false);
                end;
            }
        }
    }

    // ============================================
    // GLOBAL VARIABLES
    // ============================================

    var
        InvoiceCreatedText: Text[3];
        InvoicePostedText: Text[3];
        ItemCreatedText: Text[3];
        CostRevisionEnabled: Boolean;

    // ============================================
    // PAGE TRIGGERS
    // ============================================

    trigger OnOpenPage()
    var
        Tracking: Codeunit "AIRIQ Cost Revision Tracking";
    begin
        CostRevisionEnabled := Tracking.GetEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        SetCreatedStatusText();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetCreatedStatusText();
    end;

    // ============================================
    // COMMON BULK SELECTION HANDLER
    // ============================================

    local procedure GetSelectedSamplePurchases(
        var SelectedSamplePurchase: Record "Sample Purchase"
    ): Boolean
    begin
        // Priority 1: Existing Select checkbox.

        SelectedSamplePurchase.Reset();
        SelectedSamplePurchase.SetRange("Select", true);

        if not SelectedSamplePurchase.IsEmpty() then
            exit(true);

        // Priority 2: BC row selection.

        SelectedSamplePurchase.Reset();

        CurrPage.SetSelectionFilter(
            SelectedSamplePurchase);

        if SelectedSamplePurchase.IsEmpty() then begin
            Message(
                'Please select at least one Sample Purchase record.');

            exit(false);
        end;

        exit(true);
    end;

    // ============================================
    // STATUS DISPLAY
    // ============================================

    local procedure SetCreatedStatusText()
    begin
        if Rec."Purchase Invoice No." <> '' then
            InvoiceCreatedText := 'Yes'
        else
            InvoiceCreatedText := 'No';

        if Rec."Invoice Posted" then
            InvoicePostedText := 'Yes'
        else
            InvoicePostedText := 'No';

        if Rec."Item Created" then
            ItemCreatedText := 'Yes'
        else
            ItemCreatedText := 'No';
    end;

    // ============================================
    // DATE-BASED CHECKBOX SELECTION
    // ============================================

    local procedure SetSelectionByEntryDate(
        NewSelect: Boolean)
    var
        DateDialog: Page "Sample Purchase Date Dialog";
        SamplePurchaseRec: Record "Sample Purchase";
        FromEntryDate: Date;
        ToEntryDate: Date;
        StartDateTime: DateTime;
        EndDateTime: DateTime;
        UpdatedCount: Integer;
    begin
        DateDialog.SetDates(Today, Today);

        if DateDialog.RunModal() = Action::OK then begin
            DateDialog.GetDates(
                FromEntryDate,
                ToEntryDate);

            if (FromEntryDate = 0D) or
               (ToEntryDate = 0D)
            then
                Error(
                    'Please select both From Entry Date and To Entry Date.');

            if FromEntryDate > ToEntryDate then
                Error(
                    'From Entry Date cannot be later than To Entry Date.');

            StartDateTime :=
                CreateDateTime(
                    FromEntryDate,
                    0T);

            EndDateTime :=
                CreateDateTime(
                    ToEntryDate,
                    235959.999T);

            SamplePurchaseRec.Reset();

            SamplePurchaseRec.SetRange(
                "Entry Date",
                StartDateTime,
                EndDateTime);

            if SamplePurchaseRec.IsEmpty() then begin
                Message(
                    'No Sample Purchase records found for the specified Entry Date range.');

                exit;
            end;

            if SamplePurchaseRec.FindSet(true) then
                repeat
                    SamplePurchaseRec."Select" :=
                        NewSelect;

                    SamplePurchaseRec.Modify();

                    UpdatedCount += 1;
                until SamplePurchaseRec.Next() = 0;

            CurrPage.Update(false);

            if NewSelect then
                Message(
                    '%1 record(s) were selected.',
                    UpdatedCount)
            else
                Message(
                    '%1 record(s) were unselected.',
                    UpdatedCount);
        end;
    end;

    // ============================================
    // PREVENT DIRECT FINANCIAL EDIT
    // AFTER HISTORY EXISTS
    // ============================================

    local procedure AssertNoDirectTrackedCostEdit()
    var
        RevisionHistory:
            Record "AIRIQ Cost Revision History";
    begin
        if Rec."Serial No." = '' then
            exit;

        RevisionHistory.SetRange(
            "Purchase Serial No.",
            Rec."Serial No.");

        if not RevisionHistory.IsEmpty() then
            Error(
                'This purchase already has cost revision history. Use Edit Cost Revision instead of directly changing financial fields.');
    end;
}
