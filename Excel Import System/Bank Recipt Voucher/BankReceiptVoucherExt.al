
namespace AIRIQ.BankReceipt;

using Microsoft.Finance.TaxBase;

pageextension 50473 "AIRIQ Bank Receipt Import" extends "Bank Receipt Voucher"
{
    actions
    {
        addfirst(Processing)
        {
            action(ImportBankReceiptExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import Bank Receipt Voucher lines from Excel.';

                trigger OnAction()
                var
                    BankReceiptImport: Codeunit "AIRIQ Bank Receipt Import";
                begin
                    BankReceiptImport.ImportExcel(
                        Rec."Journal Template Name",
                        Rec."Journal Batch Name");

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
