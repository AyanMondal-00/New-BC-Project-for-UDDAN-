
page 50411 "API Sales Format List"
{
    Caption = 'API Sales Format';
    PageType = List;
    SourceTable = "API Sales Format";
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
                        PassengerList:
                            Page "API Sales Passenger Name List";
                    begin
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
            action("Create Sales Invoice")
            {
                ApplicationArea = All;
                Caption = 'Create Sales Invoice';
                Image = CreateDocument;

                trigger OnAction()
                var
                    SelectedAPISales:
                        Record "API Sales Format";
                    SalesInvoiceMgt:
                        Codeunit "AIRIQ API Sales Invoice Mgt";
                begin
                    CurrPage.SetSelectionFilter(
                        SelectedAPISales);

                    SalesInvoiceMgt.CreateAPISalesInvoices(
                        SelectedAPISales);

                    CurrPage.Update(false);
                end;
            }

            action(ImportSalesExcel)
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;
                ToolTip =
                    'Import API Sales records from an Excel file.';

                trigger OnAction()
                var
                    SalesExcelImportMgt:
                        Codeunit "API Sales Excel Import Mgt.";
                begin
                    SalesExcelImportMgt.ImportFromExcel();

                    CurrPage.Update(false);
                end;
            }

            // ====================================
            // CUSTOM EXCEL EXPORT
            // ====================================

            action(ExportSalesExcel)
            {
                ApplicationArea = All;
                Caption = 'Export to Excel';
                Image = ExportToExcel;
                ToolTip =
                    'Export API Sales with passenger names, IDs and types.';

                trigger OnAction()
                var
                    SelectedSales:
                        Record "API Sales Format";
                    ExcelExportMgt:
                        Codeunit "API Sales Excel Export Mgt.";
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
