
codeunit 50341 "Posted Purch Inv Line Mgt"
{
    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Purch.-Post",
        'OnPostPurchLineOnBeforeInsertInvoiceLine',
        '',
        false,
        false)]
    local procedure CopySampleFieldsBeforePostedLineInsert(
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        var IsHandled: Boolean;
        var PurchInvLine: Record "Purch. Inv. Line")
    begin
        // Copy source Purchase Line values to Posted Purchase Invoice Line.
        PurchInvLine."Sample Purchase Date" :=
            PurchaseLine."Sample Purchase Date";

        PurchInvLine."Sample Entry Date" :=
            PurchaseLine."Sample Entry Date";

        PurchInvLine."Sample Travel Date" :=
            PurchaseLine."Sample Travel Date";

        PurchInvLine."Sample Airline" :=
            PurchaseLine."Sample Airline";

        PurchInvLine."Sample Sector" :=
            PurchaseLine."Sample Sector";

        PurchInvLine."Sample Flight Type" :=
            PurchaseLine."Sample Flight Type";

        PurchInvLine."Sample Supplier ID" :=
            PurchaseLine."Sample Supplier ID";

        PurchInvLine."Sample Base Fare" :=
            PurchaseLine."Sample Base Fare";

        PurchInvLine."Sample Other Charges" :=
            PurchaseLine."Sample Other Charges";
    end;
}
