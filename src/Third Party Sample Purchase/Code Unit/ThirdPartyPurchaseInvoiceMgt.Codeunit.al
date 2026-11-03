codeunit 50665 "TP Purchase Invoice Mgt"
{
    Permissions = tabledata "Third Party Sample Purchase" = rimd,
                  tabledata "Purchase Header" = rimd,
                  tabledata "Purch. Inv. Header" = r;

    procedure CreatePurchaseInvoices(var SelectedPurchases: Record "Third Party Sample Purchase")
    begin
        ProcessPurchases(SelectedPurchases, false);
    end;

    procedure CreateAndPostPurchaseInvoices(var SelectedPurchases: Record "Third Party Sample Purchase")
    begin
        ProcessPurchases(SelectedPurchases, true);
    end;

    local procedure ProcessPurchases(var SelectedPurchases: Record "Third Party Sample Purchase"; PostNow: Boolean)
    var
        Purchase: Record "Third Party Sample Purchase";
        Fresh: Record "Third Party Sample Purchase";
        Header: Record "Purchase Header";
        InvoiceWorker: Codeunit "TP Purchase Inv Worker";
        ConflictingNo: Code[20];
        CreatedCount: Integer;
        PostedCount: Integer;
        SkippedCount: Integer;
        FailedCount: Integer;
        Details: Text;
    begin
        Purchase.Copy(SelectedPurchases);
        if Purchase.IsEmpty() then Error('Select at least one Third Party Sample Purchase record.');
        if Purchase.FindSet() then
            repeat
                if Fresh.Get(Purchase."Serial No.") then begin
                    if Fresh."Invoice Posted" then
                        SkippedCount += 1
                    else begin
                        if Fresh."Purchase Invoice No." = '' then begin
                            ClearLastError();
                            if Codeunit.Run(Codeunit::"TP Purchase Inv Worker", Fresh) then
                                CreatedCount += 1
                            else begin
                                FailedCount += 1;
                                Details += StrSubstNo('\Serial No. %1: %2', Purchase."Serial No.", GetLastErrorText());
                            end;
                        end else if not PostNow then
                            SkippedCount += 1;

                        Fresh.Get(Purchase."Serial No.");
                        if PostNow and (Fresh."Purchase Invoice No." <> '') then begin
                            if Header.Get(Header."Document Type"::Invoice, Fresh."Purchase Invoice No.") then begin
                                ConflictingNo := '';
                                if InvoiceWorker.ConflictingInvoiceExists(Fresh, Header."No.", ConflictingNo) then begin
                                    FailedCount += 1;
                                    Details += StrSubstNo('\Serial No. %1: PNR %2 already has another invoice %3.', Purchase."Serial No.", Fresh.PNR, ConflictingNo);
                                end else begin
                                Header.Receive := true;
                                Header.Invoice := true;
                                Header.Modify(true);
                                Commit();
                                ClearLastError();
                                if Codeunit.Run(Codeunit::"Purch.-Post", Header) then begin
                                    Fresh.Get(Purchase."Serial No.");
                                    Fresh."Purchase Invoice No." := FindPostedInvoiceNo(Header);
                                    Fresh."Invoice Posted" := true;
                                    Fresh."Select" := false;
                                    Fresh.Modify(true);
                                    Commit();
                                    PostedCount += 1;
                                end else begin
                                    // Keep the draft and its source reference for inspection/retry.
                                    Fresh.Get(Purchase."Serial No.");
                                    Fresh."Select" := true;
                                    Fresh.Modify(true);
                                    Commit();
                                    FailedCount += 1;
                                    Details += StrSubstNo('\Serial No. %1: posting failed: %2 (draft %3 retained)', Purchase."Serial No.", GetLastErrorText(), Header."No.");
                                end;
                                end;
                            end else begin
                                FailedCount += 1;
                                Details += StrSubstNo('\Serial No. %1: invoice %2 is not an open purchase invoice; review its status.', Purchase."Serial No.", Fresh."Purchase Invoice No.");
                            end;
                        end;
                    end;
                end;
            until Purchase.Next() = 0;
        if PostNow then
            Message('Create & Post complete. Created: %1, posted: %2, skipped: %3, failed: %4%5', CreatedCount, PostedCount, SkippedCount, FailedCount, Details)
        else
            Message('Purchase Invoice creation complete. Created: %1, skipped: %2, failed: %3%4', CreatedCount, SkippedCount, FailedCount, Details);
    end;

    local procedure FindPostedInvoiceNo(Header: Record "Purchase Header"): Code[20]
    var PostedHeader: Record "Purch. Inv. Header";
    begin
        PostedHeader.SetCurrentKey("Pre-Assigned No.");
        PostedHeader.SetRange("Pre-Assigned No.", Header."No.");
        if PostedHeader.FindLast() then exit(PostedHeader."No.");
        if Header."Last Posting No." <> '' then exit(Header."Last Posting No.");
        if Header."Posting No." <> '' then exit(Header."Posting No.");
        Error('Posting completed but the posted invoice number for %1 could not be resolved.', Header."No.");
    end;
}
