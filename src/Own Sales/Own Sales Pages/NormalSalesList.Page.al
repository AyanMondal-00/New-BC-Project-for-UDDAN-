page 50410 "Normal Sales List"
{
    Caption = 'Normal Sales';
    PageType = List;
    SourceTable = "Normal Sales";
    ApplicationArea = All;
    UsageCategory = Lists;

    DelayedInsert = true;

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
                    ToolTip = 'Displays the serial number assigned by the AIRIQ Own Sales No. Series when the record is inserted.';
                }

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }

                field("Invoice Number"; Rec."Invoice Number")
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
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Date to Date API Import")
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
                ToolTip = 'Create invoices for native selected rows (or the current row). This action ignores checkbox values.';
                Image = CreateDocument;

                trigger OnAction()
                begin
                    CreateInvoices();
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

    local procedure CreateInvoices()
    var
        SelectedNormalSales: Record "Normal Sales";
        SalesInvoiceMgt: Codeunit "AIRIQ Sales Invoice Mgt";
    begin
        CurrPage.SaveRecord();
        SelectedNormalSales.Copy(Rec);
        CurrPage.SetSelectionFilter(SelectedNormalSales);
        if SelectedNormalSales.IsEmpty() then begin
            Message('Please select at least one Own Sales record.');
            exit;
        end;
        Commit();
        SalesInvoiceMgt.CreateOwnSalesInvoicesForMode(
            SelectedNormalSales, 'Native selected rows');
        CurrPage.Update(false);
    end;

    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';

        if Rec."Sales Invoice Created" then
            SalesInvoiceCreatedText := 'Yes'
        else
            SalesInvoiceCreatedText := 'No';
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Do not allocate a No. Series number here.
        // The table OnInsert trigger handles allocation.
        // This avoids assigning a primary key to an
        // otherwise empty row during New/Refresh.
        ViewPassengerText := 'View Passenger';
        SalesInvoiceCreatedText := 'No';
    end;

    var
        ViewPassengerText: Text[30];
        SalesInvoiceCreatedText: Text[3];
}
