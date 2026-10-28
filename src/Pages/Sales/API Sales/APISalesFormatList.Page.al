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
                        PassengerList: Page "API Sales Passenger Name List";
                    begin
                        PassengerList.SetRefNoAQNumber(Rec."Ref No./AQ Number", Rec.PNR);
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
            action("Create Sales Invoice")
            {
                ApplicationArea = All;
                Caption = 'Create Sales Invoice';
                Image = CreateDocument;

                trigger OnAction()
                var
                    SelectedAPISales: Record "API Sales Format";
                    SalesInvoiceMgt: Codeunit "AIRIQ API Sales Invoice Mgt";
                begin
                    CurrPage.SetSelectionFilter(SelectedAPISales);

                    SalesInvoiceMgt.CreateAPISalesInvoices(SelectedAPISales);

                    CurrPage.Update(false);
                end;
            }
            action(ImportSalesExcel)
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;
                ToolTip = 'Import API Sales records from an Excel file.';

                trigger OnAction()
                var
                    SalesExcelImportMgt: Codeunit "API Sales Excel Import Mgt.";
                begin
                    SalesExcelImportMgt.ImportFromExcel();
                    CurrPage.Update(false);
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

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        APISalesFormat: Record "API Sales Format";
    begin
        APISalesFormat.Reset();
        if APISalesFormat.FindLast() then
            if APISalesFormat."Serial No." >= 1 then
                Rec."Serial No." := APISalesFormat."Serial No." + 1
            else
                Rec."Serial No." := 1
        else
            Rec."Serial No." := 1;
    end;

    var
        ViewPassengerText: Text[30];
        SalesInvoiceCreatedText: Text[3];
}
