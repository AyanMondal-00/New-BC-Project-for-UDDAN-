codeunit 50725 "AIRIQ SR Posted Invoice Fetch"
{
    // No errors for blank / unmatched Bill No. + PNR.
    // Source: Posted Sales Invoice custom Invoice Number and Item No. (PNR).
    // GST source: Posted Detailed GST Ledger Entries for the matching lines.
    // Amounts are scaled to the return PAX.
    procedure Fetch(var SalesReturn: Record "Sales Return"): Boolean
    var
        PostedHeader: Record "Sales Invoice Header";
        PostedLine: Record "Sales Invoice Line";
        GSTEntry: Record "Detailed GST Ledger Entry";
        LineBaseFare: Decimal;
        InvoiceQty: Decimal;
        ReturnFactor: Decimal;
        BaseFareTotal: Decimal;
        OtherChargesTotal: Decimal;
        TaxableTotal: Decimal;
        CGSTTotal: Decimal;
        SGSTTotal: Decimal;
        IGSTTotal: Decimal;
        GSTBase: Decimal;
        LineCGST: Decimal;
        LineSGST: Decimal;
        LineIGST: Decimal;
        FoundGST: Boolean;
        FoundBase: Boolean;
        LineCount: Integer;
        EffectivePAX: Decimal;
    begin
        // Clear stale values if either key has changed or no match exists.
        ClearFetchedAmounts(SalesReturn);

        if (SalesReturn."Bill No." = '') or
           (SalesReturn.PNR = '') then
            exit(false);

        // Refuse ambiguous Bill No. matches; never pick a random invoice.
        PostedHeader.Reset();
        PostedHeader.SetRange("Invoice Number", SalesReturn."Bill No.");
        if PostedHeader.Count() <> 1 then
            exit(false);
        PostedHeader.FindFirst();

        // PNR is the Item No. (not Description).
        PostedLine.Reset();
        PostedLine.SetRange("Document No.", PostedHeader."No.");
        PostedLine.SetRange(Type, PostedLine.Type::Item);
        PostedLine.SetRange("No.", SalesReturn.PNR);
        PostedLine.SetFilter(Quantity, '>0');

        if not PostedLine.FindSet() then
            exit(false);

        // Validate all numeric BaseFare text values before assigning totals.
        repeat
            if not Evaluate(LineBaseFare, PostedLine.BaseFare) then
                if PostedHeader."Sales Type" = PostedHeader."Sales Type"::"Own Sales" then
                    LineBaseFare := PostedLine."Unit Price" - PostedLine."Other Charges"
                else
                    exit(false);
            InvoiceQty += PostedLine.Quantity;
            LineCount += 1;
        until PostedLine.Next() = 0;

        if InvoiceQty <= 0 then
            exit(false);

        // When PAX is not yet entered, show per-passenger amounts for
        // one passenger; re-fetch automatically when PAX changes.
        EffectivePAX := SalesReturn.PAX;
        if EffectivePAX <= 0 then
            EffectivePAX := 1;
        if EffectivePAX > InvoiceQty then
            exit(false);

        PostedLine.FindSet();
        repeat
            if not Evaluate(LineBaseFare, PostedLine.BaseFare) then
                LineBaseFare := PostedLine."Unit Price" - PostedLine."Other Charges";
            // Custom posted fields are per passenger in AIRIQ invoice creation.
            BaseFareTotal += LineBaseFare * PostedLine.Quantity;
            OtherChargesTotal += PostedLine."Other Charges" * PostedLine.Quantity;

            Clear(GSTBase);
            Clear(LineCGST);
            Clear(LineSGST);
            Clear(LineIGST);
            FoundGST := false;
            FoundBase := false;

            GSTEntry.Reset();
            GSTEntry.SetRange("Document No.", PostedHeader."No.");
            GSTEntry.SetRange("Document Line No.", PostedLine."Line No.");
            if GSTEntry.FindSet() then
                repeat
                    case UpperCase(GSTEntry."GST Component Code") of
                        'CGST':
                            begin
                                LineCGST += Abs(GSTEntry."GST Amount");
                                if not FoundBase then begin
                                    GSTBase := Abs(GSTEntry."GST Base Amount");
                                    FoundBase := true;
                                end;
                                FoundGST := true;
                            end;
                        'SGST':
                            begin
                                LineSGST += Abs(GSTEntry."GST Amount");
                                if not FoundBase then begin
                                    GSTBase := Abs(GSTEntry."GST Base Amount");
                                    FoundBase := true;
                                end;
                                FoundGST := true;
                            end;
                        'IGST':
                            begin
                                LineIGST += Abs(GSTEntry."GST Amount");
                                if not FoundBase then begin
                                    GSTBase := Abs(GSTEntry."GST Base Amount");
                                    FoundBase := true;
                                end;
                                FoundGST := true;
                            end;
                    end;
                until GSTEntry.Next() = 0;

            // If no posted GST detail exists, custom posted component
            // fields are a fallback. We do NOT invent a taxable basis.
            if not FoundGST then begin
                LineCGST := PostedLine.CGST;
                LineSGST := PostedLine.SGST;
                LineIGST := PostedLine.IGST;
            end;

            TaxableTotal += GSTBase;
            CGSTTotal += LineCGST;
            SGSTTotal += LineSGST;
            IGSTTotal += LineIGST;
        until PostedLine.Next() = 0;

        // Financial amounts returned correspond to the PAX being returned.
        ReturnFactor := EffectivePAX / InvoiceQty;
        SalesReturn."Base Fare" := Round(BaseFareTotal / InvoiceQty, 0.01);
        SalesReturn."Other Charges" := Round(OtherChargesTotal / InvoiceQty, 0.01);
        SalesReturn."Taxable Value" := Round(TaxableTotal * ReturnFactor, 0.01);
        SalesReturn.CGST := Round(CGSTTotal * ReturnFactor, 0.01);
        SalesReturn.SGST := Round(SGSTTotal * ReturnFactor, 0.01);
        SalesReturn.IGST := Round(IGSTTotal * ReturnFactor, 0.01);

        // Sold Value, XXLN Charges, Refund Amount stay manual.
        exit(LineCount > 0);
    end;

    local procedure ClearFetchedAmounts(var SalesReturn: Record "Sales Return")
    begin
        Clear(SalesReturn."Base Fare");
        Clear(SalesReturn."Other Charges");
        Clear(SalesReturn."Taxable Value");
        Clear(SalesReturn.CGST);
        Clear(SalesReturn.SGST);
        Clear(SalesReturn.IGST);
    end;
}
