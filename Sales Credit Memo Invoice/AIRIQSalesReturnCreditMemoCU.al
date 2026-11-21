
codeunit 50715 "AIRIQ SR Create Memo"
{
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rimd,
        tabledata "Sales Return" = rm;

    // Uses standard BC Copy Document Management to reverse the original posted
    // invoice, then retains only the posted lines belonging to this PNR.
    // The posting step remains manual and standard BC tax calculation applies.
    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(Serial: Integer; var Header: Record "Sales Header")
    var
        Source: Record "Sales Return";
        Customer: Record Customer;
        Passenger: Record "Sales Return Passenger Name";
        Existing: Record "Sales Header";
        PostedMemo: Record "Sales Cr.Memo Header";
        OriginalInvoice: Record "Sales Invoice Header";
        OriginalLine: Record "Sales Invoice Line";
        CreditLine: Record "Sales Line";
        CopyDoc: Codeunit "Copy Document Mgt.";
        DocTypeFrom: Enum "Sales Document Type From";
        RemainingQty: Decimal;
        ReversibleQty: Decimal;
        MatchedLineCount: Integer;
    begin
        Source.LockTable();
        if not Source.Get(Serial) then
            Error('Sales Return %1 does not exist.', Serial);

        Source.TestField("Return No.");
        Source.TestField("Bill No.");
        Source.TestField(PNR);
        Source.TestField("A/C Name");
        if Source.PAX <= 0 then
            Error('Sales Return PAX must be greater than zero.');

        Existing.SetRange("Document Type", Existing."Document Type"::"Credit Memo");
        Existing.SetRange("AIRIQ Return No.", Source."Return No.");
        if Existing.FindFirst() then
            Error('Return %1 already has Sales Credit Memo %2.', Source."Return No.", Existing."No.");

        PostedMemo.SetRange("AIRIQ Return No.", Source."Return No.");
        if PostedMemo.FindFirst() then
            Error('Return %1 already has Posted Credit Memo %2.', Source."Return No.", PostedMemo."No.");

        if Source."AIRIQ Memo Created" or (Source."AIRIQ Memo No." <> '') then
            Error('Return %1 is already linked to Credit Memo %2.',
                Source."Return No.", Source."AIRIQ Memo No.");

        // Bill No. is the NEW custom Invoice Number, not AQ Number or BC No.
        OriginalInvoice.SetRange("Invoice Number", Source."Bill No.");

        if OriginalInvoice.Count() <> 1 then
            Error(
                'Bill No. %1 must match exactly one Posted Sales Invoice custom Invoice Number. Matches: %2.',
                Source."Bill No.", OriginalInvoice.Count());

        OriginalInvoice.FindFirst();

        // PNR lives in the original posted invoice line Description.
        OriginalLine.SetRange("Document No.", OriginalInvoice."No.");
        OriginalLine.SetRange(Description, Source.PNR);
        OriginalLine.SetFilter(Quantity, '>0');

        if OriginalLine.IsEmpty() then
            Error('No posted sales invoice line for Bill %1 / PNR %2.',
                Source."Bill No.", Source.PNR);

        if OriginalLine.FindSet() then
            repeat
                ReversibleQty += OriginalLine.Quantity;
                MatchedLineCount += 1;
            until OriginalLine.Next() = 0;

        if Source.PAX > ReversibleQty then
            Error(
                'Return PAX %1 exceeds original PNR invoiced quantity %2.',
                Source.PAX, ReversibleQty);

        // Customer comes from the posted document.
        Customer.Get(OriginalInvoice."Sell-to Customer No.");

        if Customer.Name <> Source."A/C Name" then
            Error(
                'Sales Return A/C Name %1 does not match original invoice customer %2.',
                Source."A/C Name", Customer.Name);

        Passenger.SetRange("Return No.", Source."Return No.");
        Passenger.SetRange(PNR, Source.PNR);

        if Passenger.Count() <> Source.PAX then
            Error(
                'Passenger count %1 must equal return PAX %2.',
                Passenger.Count(), Source.PAX);

        if Passenger.FindSet() then
            repeat
                Passenger.TestField("Passenger Name");
            until Passenger.Next() = 0;

        Header.Init();
        Header."Document Type" := Header."Document Type"::"Credit Memo";
        Header.Insert(true);

        Header.Validate(
            "Sell-to Customer No.",
            OriginalInvoice."Sell-to Customer No.");

        Header.Validate(
            "Prices Including VAT",
            OriginalInvoice."Prices Including VAT");

        if Source."Entry Date" <> 0DT then
            Header.Validate(
                "Document Date",
                DT2Date(Source."Entry Date"));

        Header.Modify(true);

        // Standard BC document-copy procedure.
        CopyDoc.SetProperties(false, false, false, false, true, true, false);

        DocTypeFrom := DocTypeFrom::"Posted Invoice";

        CopyDoc.CopySalesDoc(
            DocTypeFrom,
            OriginalInvoice."No.",
            Header);

        RemainingQty := Source.PAX;

        CreditLine.SetRange(
            "Document Type",
            Header."Document Type");

        CreditLine.SetRange(
            "Document No.",
            Header."No.");

        if CreditLine.FindSet(true) then
            repeat
                if (CreditLine.Description <> Source.PNR) or
                   (CreditLine.Type = CreditLine.Type::" ") or
                   (RemainingQty <= 0) then
                    CreditLine.Delete(true)
                else begin
                    if CreditLine.Quantity > RemainingQty then
                        CreditLine.Validate(
                            Quantity,
                            RemainingQty);

                    RemainingQty -= CreditLine.Quantity;

                    CreditLine."AIRIQ Country" := Source.Country;
                    CreditLine."AIRIQ State" := Source.State;
                    CreditLine."AIRIQ City" := Source.City;
                    CreditLine."AIRIQ Travel Time" := Source.Time;
                    CreditLine."AIRIQ Airline" := Source.Airline;
                    CreditLine."AIRIQ Airline Code" := Source."Airline Code";
                    CreditLine."AIRIQ Reference" := Source.Reference;
                    CreditLine."AIRIQ XXLN Charges" := Source."XXLN Charges";
                    CreditLine."AIRIQ Refund Amount" := Source."Refund Amount";

                    CreditLine.Modify(true);
                end;
            until CreditLine.Next() = 0;

        if RemainingQty <> 0 then
            Error(
                'Unable to reverse requested %1 PAX for PNR %2; remaining quantity %3.',
                Source.PAX, Source.PNR, RemainingQty);

        // Keep original Posted Invoice No. separately from custom Bill No.
        Header."AIRIQ Return No." := Source."Return No.";
        Header."AIRIQ Return Serial" := Source."Serial No.";
        Header."AIRIQ Bill No." := Source."Bill No.";
        Header."AIRIQ Original Invoice" := OriginalInvoice."No.";
        Header."AIRIQ Entry Date" := Source."Entry Date";
        Header."AIRIQ Reference" := Source.Reference;
        Header."AIRIQ Narration" := Source.Narration;
        Header."AIRIQ Supplier" := Source.Supplier;
        Header."AIRIQ Sale Type" := Source."Sale Type";

        Header."Agency ID" :=
            CopyStr(Source."Agency ID", 1, MaxStrLen(Header."Agency ID"));

        Header.Modify(true);

        Source."AIRIQ Memo Created" := true;
        Source."AIRIQ Memo No." := Header."No.";
        Source.Modify(true);

        Message(
            'Sales Credit Memo %1 created from Posted Invoice %2 (Bill %3 / PNR %4). Review selected lines, quantities and GST before posting.',
            Header."No.",
            OriginalInvoice."No.",
            Source."Bill No.",
            Source.PNR);
    end;
}
