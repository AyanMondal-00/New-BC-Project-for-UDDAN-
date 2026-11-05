
page 50477 "API Purchase Return"
{
    Caption = 'API Purchase Return';
    PageType = List;
    SourceTable = "API Purchase Return";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                ShowCaption = false;

                field("Select"; Rec."Select")
                {
                    ApplicationArea = All;
                    Caption = 'Select';
                    Editable = true;
                }

                field(
                    "Third Party Purchase Return Inv Created";
                Rec."Third Party Purchase Return Inv Created")
                {
                    ApplicationArea = All;
                    Caption = 'Third Party Purchase Return Invoice Created';
                    Editable = false;
                }

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                }

                field("Refund Date"; Rec."Refund Date")
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

                field("Airline"; Rec."Airline")
                {
                    ApplicationArea = All;
                }

                field("Country"; Rec."Country")
                {
                    ApplicationArea = All;
                }

                field("Type"; Rec."Type")
                {
                    ApplicationArea = All;
                }

                field("Sector"; Rec."Sector")
                {
                    ApplicationArea = All;
                }

                field("PNR"; Rec."PNR")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    ToolTip =
                        'Enter a unique PNR. Duplicate PNR values are not allowed.';
                }

                field("Narration"; Rec."Narration")
                {
                    ApplicationArea = All;
                }

                field("Pax"; Rec."Pax")
                {
                    ApplicationArea = All;
                }

                field("Rate"; Rec."Rate")
                {
                    ApplicationArea = All;
                }

                field("Cost Value"; Rec."Cost Value")
                {
                    ApplicationArea = All;
                }

                field(
                    "Cancellation Charges";
                Rec."Cancellation Charges")
                {
                    ApplicationArea = All;
                }

                field("Amount"; Rec."Amount")
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
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
            action(ImportThirdPartyPurchaseReturn)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import API Purchase Return records from Excel.';

                trigger OnAction()
                var
                    ExcelImport: Codeunit "API Purchase Return Exl Import";
                begin
                    ExcelImport.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
    }

}
