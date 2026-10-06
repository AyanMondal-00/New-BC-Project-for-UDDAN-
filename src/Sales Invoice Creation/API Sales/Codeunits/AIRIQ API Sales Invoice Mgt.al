codeunit 50436 "AIRIQ API Sales Invoice Mgt"
{
    procedure CreateAPISalesInvoices(var APISales: Record "API Sales Format")
    var
        CreateSalesInvoice: Codeunit "AIRIQ Create API Sales Invoice";
        CreatedCount: Integer;
    begin
        APISales.SetRange("Select", true);

        if APISales.IsEmpty() then
            Error('Please select at least one API Sales record.');

        if APISales.FindSet(true) then begin
            repeat
                if APISales."Sales Invoice Created" then
                    Error(
                        'Sales Invoice has already been created for AQ Number %1.',
                        APISales."Ref No./AQ Number");

                CreateSalesInvoice.CreateAPISalesInvoice(APISales);
                CreatedCount += 1;
            until APISales.Next() = 0;
        end;

        Message(
            '%1 API Sales Invoice(s) created successfully.',
            CreatedCount);
    end;
}