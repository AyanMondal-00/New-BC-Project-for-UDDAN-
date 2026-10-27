
codeunit 50455 "Comm Credit Memo Sub"
{
    [EventSubscriber(
        ObjectType::Table,
        Database::"Purch. Cr. Memo Line",
        'OnAfterInsertEvent',
        '',
        false,
        false)]
    local procedure OnAfterPostedCreditMemoLineInsert(
        var Rec: Record "Purch. Cr. Memo Line";
        RunTrigger: Boolean)
    var
        CommissionSync: Codeunit "Commission Calculation Sync";
    begin
        if Rec.Type <> Rec.Type::Item then
            exit;

        if Rec."No." = '' then
            exit;

        if Rec."Line Amount" = 0 then
            exit;

        CommissionSync.UpdatePurchaseReturn(
            Rec."No.",
            Rec."Line Amount");
    end;
}
