
namespace AIRIQ.JournalVoucher;

using Microsoft.Finance.TaxBase;

pageextension 50475 "AIRIQ Journal Voucher Import" extends "Journal Voucher"
{
    actions
    {
        addfirst(Processing)
        {
            action(ImportJournalVoucherExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import Journal Voucher lines from Excel.';

                trigger OnAction()
                var
                    JournalImport: Codeunit "AIRIQ Journal Voucher Import";
                begin
                    JournalImport.ImportExcel(
                        Rec."Journal Template Name",
                        Rec."Journal Batch Name");

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
