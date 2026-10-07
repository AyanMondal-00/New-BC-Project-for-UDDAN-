codeunit 50438 "Third Party Sales Invoice Mgt"
{
    procedure CreateThirdPartySalesInvoices(
        var ThirdPartySales: Record "Third-Party Supplier Sales")
    var
        CreateSalesInvoice: Codeunit "Third Party Sales Invoice";
        CreatedCount: Integer;
    begin
        ThirdPartySales.SetRange("Select", true);

        if ThirdPartySales.IsEmpty() then
            Error('Please select at least one Third Party Sales record.');

        if ThirdPartySales.FindSet(true) then begin
            repeat
                if ThirdPartySales."Sales Invoice Created" then
                    Error(
                        'Sales Invoice has already been created for AQ Number %1.',
                        ThirdPartySales."Ref No./AQ Number");

                CreateSalesInvoice.CreateThirdPartySalesInvoice(ThirdPartySales);
                CreatedCount += 1;
            until ThirdPartySales.Next() = 0;
        end;

        Message(
            '%1 Third Party Sales Invoice(s) created successfully.',
            CreatedCount);
    end;
}