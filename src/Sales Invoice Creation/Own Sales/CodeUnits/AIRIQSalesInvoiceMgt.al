codeunit 50427 "AIRIQ Sales Invoice Mgt"
{
    procedure CreateOwnSalesInvoices(var NormalSales: Record "Normal Sales")
    var
        CreateSalesInvoice: Codeunit "AIRIQ Create Sales Invoice";
        CreatedCount: Integer;
    begin
        NormalSales.SetRange("Select", true);

        if NormalSales.IsEmpty() then
            Error('Please select at least one Sales record.');

        if NormalSales.FindSet(true) then begin
            repeat
                if NormalSales."Sales Invoice Created" then
                    Error(
                        'Sales Invoice has already been created for AQ Number %1.',
                        NormalSales."Ref No./AQ Number");

                CreateSalesInvoice.CreateOwnSalesInvoice(NormalSales);
                CreatedCount += 1;
            until NormalSales.Next() = 0;
        end;

        Message('%1 Sales Invoice(s) created successfully.', CreatedCount);
    end;
}