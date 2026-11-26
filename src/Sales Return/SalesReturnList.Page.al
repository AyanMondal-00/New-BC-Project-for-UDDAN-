
page 50413 "Sales Return List"
{
    Caption = 'Sales Return / Cancellation Charge Format';
    PageType = List;
    SourceTable = "Sales Return";
    ApplicationArea = All;
    UsageCategory = Lists;
    DeleteAllowed = true;

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

                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field("Bill No."; Rec."Bill No.")
                {
                    ApplicationArea = All;
                }

                field("Invoice No."; Rec."Invoice No.")
                {
                    ApplicationArea = All;
                }

                field("Return No."; Rec."Return No.")
                {
                    ApplicationArea = All;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field("A/C Name"; Rec."A/C Name")
                {
                    ApplicationArea = All;
                }

                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                }

                field(State; Rec.State)
                {
                    ApplicationArea = All;
                }

                field(City; Rec.City)
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

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Time; Rec.Time)
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                }

                field("Airline Code"; Rec."Airline Code")
                {
                    ApplicationArea = All;
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
                        PassengerList: Page "Sales Return Passenger List";
                    begin
                        if Rec.Pax <= 0 then
                            Error('First enter Pax count.');

                        if Rec."Return No." = '' then
                            Error('Return No. is blank.');

                        PassengerList.SetReturnNoAndPNR(
                            Rec."Return No.",
                            Rec.PNR);
                        PassengerList.SetExpectedPax(Rec.Pax);
                        PassengerList.RunModal();
                    end;
                }

                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                }

                field(Narration; Rec.Narration)
                {
                    ApplicationArea = All;
                }

                field(PAX; Rec.PAX)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        Passenger: Record "Sales Return Passenger Name";
                        PaxValidation: Codeunit "AIRIQ Pax Validation";
                    begin
                        if (Rec.Pax <> xRec.Pax) and (Rec."Return No." <> '') then begin
                            Passenger.SetRange("Return No.", Rec."Return No.");
                            Passenger.SetRange(PNR, Rec.PNR);
                            PaxValidation.NotifyPaxChange(Rec.Pax, Passenger.Count());
                        end;
                    end;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                }

                field("Taxable Value"; Rec."Taxable Value")
                {
                    ApplicationArea = All;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                }

                field("Sold Value"; Rec."Sold Value")
                {
                    ApplicationArea = All;
                }

                field("XXLN Charges"; Rec."XXLN Charges")
                {
                    ApplicationArea = All;
                }

                field("Refund Amount"; Rec."Refund Amount")
                {
                    ApplicationArea = All;
                }

                field("Sale Type"; Rec."Sale Type")
                {
                    ApplicationArea = All;
                }

                field(Supplier; Rec.Supplier)
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
            action("Refresh Posted Invoice Values")
            {
                ApplicationArea = All;
                Caption = 'Refresh Posted Invoice Values';
                Image = Refresh;
                ToolTip = 'Retry Bill No. and PNR matching against the posted sales invoice without blocking an unmatched record.';

                trigger OnAction()
                begin
                    Rec.RefreshPostedInvoiceData();
                    Rec.Modify(true);
                    CurrPage.Update(false);
                end;
            }

            action("Import from Excel")
            {
                ApplicationArea = All;
                Caption = 'Import from Excel';
                Image = ImportExcel;
                ToolTip = 'Import Sales Return data from an Excel file.';

                trigger OnAction()
                var
                    SalesReturnExcelImport: Codeunit "Sales Return Excel Import";
                begin
                    SalesReturnExcelImport.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ViewPassengerText := 'View Passenger';
    end;

    var
        ViewPassengerText: Text[30];
}
