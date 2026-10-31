
namespace AIRIQ.ContraVoucher;

using Microsoft.Finance.TaxBase;

pageextension 50477 "AIRIQ Contra Voucher Import" extends "Contra Voucher"
{
    actions
    {
        addfirst(Processing)
        {
            action(ImportContraVoucherExcel)
            {
                Caption = 'Import Excel';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Import Contra Voucher journal lines from Excel.';

                trigger OnAction()
                var
                    ContraImport: Codeunit "AIRIQ Contra Voucher Import";
                begin
                    ContraImport.ImportExcel(
                        Rec."Journal Template Name",
                        Rec."Journal Batch Name");

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
