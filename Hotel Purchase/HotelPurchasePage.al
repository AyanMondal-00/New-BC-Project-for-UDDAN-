
page 50440 "Hotel Purchase List"
{
    Caption = 'Hotel Purchase';
    PageType = List;
    SourceTable = "Hotel Purchase";
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

                field("Voucher Number"; Rec."Voucher Number")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                }

                field(Select; Rec.Select)
                {
                    ApplicationArea = All;
                }

                field("Invoice Created"; Rec."Invoice Created")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Invoice Posted"; Rec."Invoice Posted")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Item Created"; Rec."Item Created")
                {
                    ApplicationArea = All;
                    Editable = false;
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

                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                }

                field("Total Quantity"; Rec."Total Quantity")
                {
                    ApplicationArea = All;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
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
            action(ImportHotelPurchaseExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                ToolTip = 'Import Hotel Purchase records from Excel.';

                trigger OnAction()
                var
                    HotelImport: Codeunit "Hotel Purchase Exl Import Mgt.";
                begin
                    HotelImport.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }

            action(SelectAll)
            {
                Caption = 'Select All';
                ApplicationArea = All;
                Image = SelectEntries;

                trigger OnAction()
                var
                    HotelPurchase: Record "Hotel Purchase";
                begin
                    HotelPurchase.CopyFilters(Rec);

                    if HotelPurchase.FindSet(true) then
                        repeat
                            HotelPurchase.Select := true;
                            HotelPurchase.Modify(true);
                        until HotelPurchase.Next() = 0;

                    CurrPage.Update(false);
                end;
            }

            action(ClearSelection)
            {
                Caption = 'Clear Selection';
                ApplicationArea = All;
                Image = ClearFilter;

                trigger OnAction()
                var
                    HotelPurchase: Record "Hotel Purchase";
                begin
                    HotelPurchase.CopyFilters(Rec);

                    if HotelPurchase.FindSet(true) then
                        repeat
                            HotelPurchase.Select := false;
                            HotelPurchase.Modify(true);
                        until HotelPurchase.Next() = 0;

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
