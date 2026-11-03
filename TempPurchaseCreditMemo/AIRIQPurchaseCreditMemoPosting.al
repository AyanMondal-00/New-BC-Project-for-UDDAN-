codeunit 50702 "AIRIQ Return Posting"
{
    Permissions = tabledata "Purchase Return" = rm;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure CheckSourceLink(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    var
        Source: Record "Purchase Return";
        Posted: Record "Purch. Cr. Memo Hdr.";
    begin
        if PurchaseHeader."AIRIQ Return Serial No." = 0 then
            exit;
        PurchaseHeader.TestField("Document Type", PurchaseHeader."Document Type"::"Credit Memo");
        if not Source.Get(PurchaseHeader."AIRIQ Return Serial No.") then
            Error('Source Purchase Return %1 is missing. Restore the source before posting.', PurchaseHeader."AIRIQ Return Serial No.");
        Source.TestField("AIRIQ Credit Memo No.", PurchaseHeader."No.");
        PurchaseHeader.TestField("Vendor Cr. Memo No.", Source."AIRIQ Vendor Cr. Memo No.");
        Posted.SetRange("AIRIQ Return Serial No.", Source."Serial No.");
        if Posted.FindFirst() then
            Error('Purchase Return %1 already has posted Purchase Credit Memo %2.', Source."Serial No.", Posted."No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoHeaderInsert', '', false, false)]
    local procedure CopyHeader(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean)
    begin
        if PurchHeader."AIRIQ Return Serial No." = 0 then
            exit;
        PurchCrMemoHdr."AIRIQ Return Serial No." := PurchHeader."AIRIQ Return Serial No.";
        PurchCrMemoHdr."AIRIQ Voucher Number" := PurchHeader."AIRIQ Voucher Number";
        PurchCrMemoHdr."AIRIQ Entry Date" := PurchHeader."AIRIQ Entry Date";
        PurchCrMemoHdr."AIRIQ Purchase Date" := PurchHeader."AIRIQ Purchase Date";
        PurchCrMemoHdr."AIRIQ Reference" := PurchHeader."AIRIQ Reference";
        PurchCrMemoHdr."AIRIQ Narration" := PurchHeader."AIRIQ Narration";
        PurchCrMemoHdr."AIRIQ Airline ID" := PurchHeader."AIRIQ Airline ID";
        // Vendor Cr. Memo No. is a standard field transferred by Purch.-Post.
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchCrMemoLineInsert', '', false, false)]
    local procedure CopyLine(var PurchCrMemoLine: Record "Purch. Cr. Memo Line"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchLine: Record "Purchase Line"; CommitIsSupressed: Boolean; var xPurchaseLine: Record "Purchase Line")
    begin
        if PurchCrMemoHdr."AIRIQ Return Serial No." = 0 then
            exit;
        PurchCrMemoLine."AIRIQ PNR" := PurchLine."AIRIQ PNR";
        PurchCrMemoLine."Sample Sector" := PurchLine."Sample Sector";
        PurchCrMemoLine."AIRIQ Country" := PurchLine."AIRIQ Country";
        PurchCrMemoLine."Sample Flight Type" := PurchLine."Sample Flight Type";
        PurchCrMemoLine."AIRIQ Pax" := PurchLine."AIRIQ Pax";
        PurchCrMemoLine."Sample Base Fare" := PurchLine."Sample Base Fare";
        PurchCrMemoLine."Sample Other Charges" := PurchLine."Sample Other Charges";
        PurchCrMemoLine."AIRIQ Rate" := PurchLine."AIRIQ Rate";
        PurchCrMemoLine."AIRIQ Discount" := PurchLine."AIRIQ Discount";
        PurchCrMemoLine."AIRIQ XXLN Charges" := PurchLine."AIRIQ XXLN Charges";
        PurchCrMemoLine."AIRIQ Return Amount" := PurchLine."AIRIQ Return Amount";
        PurchCrMemoLine."Sample Travel Date" := PurchLine."Sample Travel Date";
        PurchCrMemoLine."AIRIQ Flight No." := PurchLine."AIRIQ Flight No.";
        PurchCrMemoLine."AIRIQ Departure Time" := PurchLine."AIRIQ Departure Time";
        PurchCrMemoLine."AIRIQ Arrival Time" := PurchLine."AIRIQ Arrival Time";
        PurchCrMemoLine."AIRIQ Cost Revision" := PurchLine."AIRIQ Cost Revision";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchCrMemoHeaderInsert', '', false, false)]
    local procedure TrackPosted(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var PurchHeader: Record "Purchase Header"; CommitIsSupressed: Boolean; PreviewMode: Boolean)
    var
        Source: Record "Purchase Return";
    begin
        if PreviewMode or (PurchHeader."AIRIQ Return Serial No." = 0) then
            exit;
        if Source.Get(PurchHeader."AIRIQ Return Serial No.") then begin
            Source."AIRIQ Posted Cr. Memo No." := PurchCrMemoHdr."No.";
            Source.Modify(false);
        end;
    end;
}
