
namespace AIRIQ.BankPayment;

using Microsoft.Finance.TaxBase;

pageextension 50470 "AIRIQ Bank Payment Import" extends "Bank Payment Voucher"
{
    actions
    {
        addfirst(Processing)
        {
            action(ImportBankPaymentExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import Bank Payment Voucher journal lines from Excel.';

                trigger OnAction()
                var
                    BankImport: Codeunit "AIRIQ Bank Payment Import";
                begin
                    BankImport.ImportExcel(
                        Rec."Journal Template Name",
                        Rec."Journal Batch Name");

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
