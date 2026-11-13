
page 50414 "Third Party Sales List"
{
    Caption = 'Third-Party Supplier Sales Format';
    PageType = List;
    SourceTable = "Third-Party Supplier Sales";
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

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
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

                    trigger OnDrillDown()
                    var
                        PassengerList: Page "Third Party Name List";
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

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
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
            // ====================================
            // EXISTING SALES INVOICE CREATION
            // ====================================

            action("Create Sales Invoice")
            {
                ApplicationArea = All;
                Caption = 'Create Sales Invoice';
                Image = CreateDocument;

                trigger OnAction()
                var
                    SelectedThirdPartySales:
                        Record "Third-Party Supplier Sales";
                    SalesInvoiceMgt:
                        Codeunit "Third Party Sales Invoice Mgt";
                begin
                    CurrPage.SetSelectionFilter(
                        SelectedThirdPartySales);

                    SalesInvoiceMgt.CreateThirdPartySalesInvoices(
                        SelectedThirdPartySales);

                    CurrPage.Update(false);
                end;
            }

            // ====================================
            // EXISTING EXCEL IMPORT
            // ====================================

            action(ImportThirdPartySalesExcel)
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;

                ToolTip =
                    'Import Third-Party Supplier Sales records from an Excel file.';

                trigger OnAction()
                var
                    ThirdPartySalesImportMgt:
                        Codeunit "Third Party Sales Excel Import";
                begin
                    ThirdPartySalesImportMgt.ImportFromExcel();

                    CurrPage.Update(false);
                end;
            }

            // ====================================
            // NEW CUSTOM EXCEL EXPORT
            // ====================================

            action(ExportThirdPartySalesExcel)
            {
                ApplicationArea = All;
                Caption = 'Export to Excel';
                Image = ExportToExcel;

                ToolTip =
                    'Export Third-Party Sales with passenger names, IDs and types.';

                trigger OnAction()
                var
                    SelectedSales:
                        Record "Third-Party Supplier Sales";
                    ExcelExportMgt:
                        Codeunit "Third Party Sales Excel Export";
                begin
                    CurrPage.SaveRecord();

                    CurrPage.SetSelectionFilter(
                        SelectedSales);

                    ExcelExportMgt.ExportToExcel(
                        SelectedSales);
                end;
            }
        }
    }

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
