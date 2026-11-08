
page 50410 "Normal Sales List"
{
    Caption = 'Normal Sales';
    PageType = List;
    SourceTable = "Normal Sales";
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

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }

                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = All;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field("Agency Name"; Rec."Agency Name")
                {
                    ApplicationArea = All;
                }

                field("Ref No./AQ Number"; Rec."Ref No./AQ Number")
                {
                    ApplicationArea = All;
                }

                field("Select"; Rec."Select")
                {
                    ApplicationArea = All;
                }

                field("Sales Invoice Created"; SalesInvoiceCreatedText)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Invoice Created';
                    Editable = false;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("View Passenger"; ViewPassengerText)
                {
                    ApplicationArea = All;
                    Caption = 'View Passenger';
                    Editable = false;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        PassengerList: Page "Own Sales Passenger List Name";
                    begin
                        if Rec."Ref No./AQ Number" = 0 then
                            Error('Ref No./AQ Number is blank.');

                        Clear(PassengerList);

                        PassengerList.SetRefNoAQNumber(
                            Rec."Ref No./AQ Number",
                            Rec.PNR);

                        PassengerList.RunModal();
                    end;
                }

                field(Pax; Rec.Pax)
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

                field(Type; Rec.Type)
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
                }

                field("Taxable Basis"; Rec."Taxable Basis")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Date to Date API Import")
            {
                ApplicationArea = All;
                Caption = 'Choose Date to Date';
                ToolTip = 'Import Own Sales data from API for a selected date range.';
                Image = DateRange;

                trigger OnAction()
                var
                    DateFilterDialog: Page "Choose Date to Date";
                    OwnSalesAPIMgt: Codeunit "Own Sales API Mgt.";
                    SelectedFromDate: Date;
                    SelectedToDate: Date;
                begin
                    DateFilterDialog.SetDates(Today, Today);

                    if DateFilterDialog.RunModal() = Action::OK then begin
                        DateFilterDialog.GetDates(
                            SelectedFromDate,
                            SelectedToDate);

                        if (SelectedFromDate = 0D) or
                           (SelectedToDate = 0D)
                        then
                            Error('Please select both From Date and To Date.');

                        if SelectedFromDate > SelectedToDate then
                            Error('From Date cannot be later than To Date.');

                        OwnSalesAPIMgt.ImportOwnSalesByDate(
                            SelectedFromDate,
                            SelectedToDate);

                        CurrPage.Update(false);
                    end;
                end;
            }

            // =====================================================
            // MAIN DUAL SELECTION INVOICE ACTION
            // =====================================================

            action("Create Own Sales Invoice")
            {
                ApplicationArea = All;
                Caption = 'Create Own Sales Invoice';
                ToolTip =
                    'Create Sales Invoices for checked rows first. If no rows are checked, process BC selected rows using Ctrl+A, Ctrl+Click or Shift+Click.';
                Image = CreateDocument;

                trigger OnAction()
                begin
                    CreateInvoices();
                end;
            }

            action("Import from Excel")
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;

                trigger OnAction()
                var
                    OwnSalesExcelImportMgt:
                        Codeunit "Own Sales Excel Import Mgt.";
                begin
                    OwnSalesExcelImportMgt.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    // =========================================================
    // DUAL SELECTION INVOICE CREATION
    // =========================================================
    //
    // Priority 1: Select Checkbox
    // Priority 2: Native BC Row Selection
    //
    // Existing Codeunit processing modes are preserved.
    // =========================================================

    local procedure CreateInvoices()
    var
        SelectedNormalSales: Record "Normal Sales";
        SalesInvoiceMgt: Codeunit "AIRIQ Sales Invoice Mgt";
        SelectionMode: Text;
    begin
        // Save any pending changes on the current row.
        CurrPage.SaveRecord();

        // STEP 1:
        // Check checkbox-selected rows within active page filters.

        SelectedNormalSales.CopyFilters(Rec);

        // FilterGroup 10 ensures that the checkbox condition
        // intersects with existing page filters.

        SelectedNormalSales.FilterGroup(10);
        SelectedNormalSales.SetRange("Select", true);
        SelectedNormalSales.FilterGroup(0);

        if not SelectedNormalSales.IsEmpty() then begin

            // Checkbox selection takes priority.

            SelectionMode := 'Checked rows within page filters';

        end else begin

            // STEP 2:
            // No checked rows found.
            // Clear previous filters before native selection.

            SelectedNormalSales.Reset();

            // Preserve current page filters and native selection.

            SelectedNormalSales.Copy(Rec);

            CurrPage.SetSelectionFilter(SelectedNormalSales);

            SelectionMode :=
                'Native selected rows (current row if no multi-selection)';
        end;

        // STEP 3:
        // Validate selected records.

        if SelectedNormalSales.IsEmpty() then begin
            Message(
                'No records found for selection mode: %1.',
                SelectionMode);
            exit;
        end;

        // STEP 4:
        // Preserve existing transaction boundary.

        Commit();

        // STEP 5:
        // Reuse existing invoice management logic.

        SalesInvoiceMgt.CreateOwnSalesInvoicesForMode(
            SelectedNormalSales,
            SelectionMode);

        // STEP 6:
        // Refresh status after processing.

        CurrPage.Update(false);
    end;

    // =========================================================
    // EXISTING STATUS DISPLAY
    // =========================================================

    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';

        if Rec."Sales Invoice Created" then
            SalesInvoiceCreatedText := 'Yes'
        else
            SalesInvoiceCreatedText := 'No';
    end;

    var
        ViewPassengerText: Text[30];
        SalesInvoiceCreatedText: Text[3];
}
