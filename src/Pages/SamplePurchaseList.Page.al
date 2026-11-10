
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
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
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

                    DateDialog.GetDates(FromDate, ToDate);

                    if (FromDate = 0D) or (ToDate = 0D) then
                        Error('Please select both From Date and To Date.');

                    if FromDate > ToDate then
                        Error('From Date cannot be later than To Date.');

                    SamplePurchaseAPIMgt.ImportSamplePurchaseByDate(
                        FromDate,
                        ToDate
                    );

                    CurrPage.Update(false);
                end;
            }


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

    var
        InvoiceCreatedText: Text[3];
        InvoicePostedText: Text[3];
        ItemCreatedText: Text[3];

    trigger OnAfterGetRecord()
    begin
        SetCreatedStatusText();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Serial No. is assigned by Table 50300 OnInsert.
        SetCreatedStatusText();
    end;

    // =========================================================
    // COMMON BULK SELECTION HANDLER
    // =========================================================
    // Priority 1: Existing Select Checkbox
    // Priority 2: BC Row Selection (Ctrl+A / Ctrl+Click)
    //
    // IMPORTANT:
    // Reset() must be called before SetSelectionFilter()
    // to remove the previous Select=true filter.
    // =========================================================

    local procedure GetSelectedSamplePurchases(
        var SelectedSamplePurchase: Record "Sample Purchase"
    ): Boolean
    begin
        // STEP 1: Check existing checkbox selection.

        SelectedSamplePurchase.Reset();
        SelectedSamplePurchase.SetRange("Select", true);

        if not SelectedSamplePurchase.IsEmpty() then
            exit(true);

        // STEP 2: No checkbox selection exists.
        // Clear all filters before capturing BC row selection.

        SelectedSamplePurchase.Reset();

        // STEP 3: Capture Ctrl+A, Ctrl+Click,
        // Shift+Click or current row selection.

        CurrPage.SetSelectionFilter(SelectedSamplePurchase);

        // STEP 4: Validate resulting selection.

        if SelectedSamplePurchase.IsEmpty() then begin
            Message(
                'Please select at least one Sample Purchase record.');
            exit(false);
        end;

        exit(true);
    end;

    // =========================================================
    // EXISTING STATUS DISPLAY LOGIC
    // =========================================================

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

    // =========================================================
    // EXISTING DATE-BASED CHECKBOX SELECTION
    // =========================================================

    local procedure SetSelectionByEntryDate(NewSelect: Boolean)
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
                CreateDateTime(FromEntryDate, 0T);

            EndDateTime :=
                CreateDateTime(ToEntryDate, 235959.999T);

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
                    SamplePurchaseRec."Select" := NewSelect;
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
}
