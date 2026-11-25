
codeunit 50715 "AIRIQ SR Create Memo"
{
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rimd,
        tabledata "Sales Return" = rm,
        tabledata "Reference Invoice No." = rim;

    // Uses standard BC Copy Document Management to reverse the
    // original posted invoice, then retains only posted lines
    // belonging to the matching PNR.
    //
    // NEW:
    // 1. Fetch Location Code from original Posted Sales Invoice.
    // 2. Automatically create the GST Reference Invoice No. link.
    //
    // Posting remains manual.
    // Standard BC GST calculation remains unchanged.

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(
        Serial: Integer;
        var Header: Record "Sales Header")
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
            Error(
                'Sales Return %1 does not exist.',
                Serial);

        Source.TestField("Return No.");
        Source.TestField("Bill No.");
        Source.TestField(PNR);
        Source.TestField("A/C Name");

        if Source.PAX <= 0 then
            Error(
                'Sales Return PAX must be greater than zero.');

        // Prevent duplicate unposted Credit Memo.
        Existing.Reset();
        Existing.SetRange(
            "Document Type",
            Existing."Document Type"::"Credit Memo");

        Existing.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if Existing.FindFirst() then
            Error(
                'Return %1 already has Sales Credit Memo %2.',
                Source."Return No.",
                Existing."No.");

        // Prevent duplicate posted Credit Memo.
        PostedMemo.Reset();
        PostedMemo.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if PostedMemo.FindFirst() then
            Error(
                'Return %1 already has Posted Credit Memo %2.',
                Source."Return No.",
                PostedMemo."No.");

        if Source."AIRIQ Memo Created" or
           (Source."AIRIQ Memo No." <> '') then
            Error(
                'Return %1 is already linked to Credit Memo %2.',
                Source."Return No.",
                Source."AIRIQ Memo No.");

        // Bill No. is custom Invoice Number.
        // It is not the BC Posted Invoice No.
        OriginalInvoice.Reset();

        OriginalInvoice.SetRange(
            "Invoice Number",
            Source."Bill No.");

        if OriginalInvoice.Count() <> 1 then
            Error(
                'Bill No. %1 must match exactly one Posted Sales Invoice custom Invoice Number. Matches: %2.',
                Source."Bill No.",
                OriginalInvoice.Count());

        OriginalInvoice.FindFirst();

        // Original matching by PNR.
        OriginalLine.Reset();

        OriginalLine.SetRange(
            "Document No.",
            OriginalInvoice."No.");

        OriginalLine.SetRange(
            Description,
            Source.PNR);

        OriginalLine.SetFilter(
            Quantity,
            '>0');

        if OriginalLine.IsEmpty() then
            Error(
                'No posted sales invoice line for Bill %1 / PNR %2.',
                Source."Bill No.",
                Source.PNR);

        if OriginalLine.FindSet() then
            repeat
                ReversibleQty += OriginalLine.Quantity;
                MatchedLineCount += 1;
            until OriginalLine.Next() = 0;

        if Source.PAX > ReversibleQty then
            Error(
                'Return PAX %1 exceeds original PNR invoiced quantity %2.',
                Source.PAX,
                ReversibleQty);

        // Customer comes from original posted invoice.
        Customer.Get(
            OriginalInvoice."Sell-to Customer No.");

        if Customer.Name <> Source."A/C Name" then
            Error(
                'Sales Return A/C Name %1 does not match original invoice customer %2.',
                Source."A/C Name",
                Customer.Name);

        // Passenger validation.
        Passenger.Reset();

        Passenger.SetRange(
            "Return No.",
            Source."Return No.");

        Passenger.SetRange(
            PNR,
            Source.PNR);

        if Passenger.Count() <> Source.PAX then
            Error(
                'Passenger count %1 must equal return PAX %2.',
                Passenger.Count(),
                Source.PAX);

        if Passenger.FindSet() then
            repeat
                Passenger.TestField("Passenger Name");
            until Passenger.Next() = 0;

        // Create Sales Credit Memo Header.
        Header.Init();

        Header."Document Type" :=
            Header."Document Type"::"Credit Memo";

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

        // Standard BC Copy Document Management.
        CopyDoc.SetProperties(
            false,
            false,
            false,
            false,
            true,
            true,
            false);

        DocTypeFrom := DocTypeFrom::"Posted Invoice";

        CopyDoc.CopySalesDoc(
            DocTypeFrom,
            OriginalInvoice."No.",
            Header);

        RemainingQty := Source.PAX;

        CreditLine.Reset();

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

                    CreditLine."AIRIQ Country" :=
                        Source.Country;

                    CreditLine."AIRIQ State" :=
                        Source.State;

                    CreditLine."AIRIQ City" :=
                        Source.City;

                    CreditLine."AIRIQ Travel Time" :=
                        Source.Time;

                    CreditLine."AIRIQ Airline" :=
                        Source.Airline;

                    CreditLine."AIRIQ Airline Code" :=
                        Source."Airline Code";

                    CreditLine."AIRIQ Reference" :=
                        Source.Reference;

                    CreditLine."AIRIQ XXLN Charges" :=
                        Source."XXLN Charges";

                    CreditLine."AIRIQ Refund Amount" :=
                        Source."Refund Amount";

                    CreditLine.Modify(true);
                end;

            until CreditLine.Next() = 0;

        if RemainingQty <> 0 then
            Error(
                'Unable to reverse requested %1 PAX for PNR %2; remaining quantity %3.',
                Source.PAX,
                Source.PNR,
                RemainingQty);

        // Keep original Posted Invoice No.
        // separately from custom Bill No.

        Header."AIRIQ Return No." :=
            Source."Return No.";

        Header."AIRIQ Return Serial" :=
            Source."Serial No.";

        Header."AIRIQ Bill No." :=
            Source."Bill No.";

        Header."AIRIQ Original Invoice" :=
            OriginalInvoice."No.";

        Header."AIRIQ Entry Date" :=
            Source."Entry Date";

        Header."AIRIQ Reference" :=
            Source.Reference;

        Header."AIRIQ Narration" :=
            Source.Narration;

        Header."AIRIQ Supplier" :=
            Source.Supplier;

        Header."AIRIQ Sale Type" :=
            Source."Sale Type";

        Header."Agency ID" :=
            CopyStr(
                Source."Agency ID",
                1,
                MaxStrLen(Header."Agency ID"));

        // ==========================================
        // NEW MODIFICATION 1
        // Fetch Location Code from Posted Invoice.
        // ==========================================

        Header.Validate(
            "Location Code",
            OriginalInvoice."Location Code");

        Header.Modify(true);

        // ==========================================
        // NEW MODIFICATION 2
        // Automatically link GST Reference Invoice.
        // ==========================================

        CreateReferenceInvoiceNo(
            Header,
            OriginalInvoice);

        // Update original Sales Return tracking.
        Source."AIRIQ Memo Created" := true;

        Source."AIRIQ Memo No." :=
            Header."No.";

        Source.Modify(true);

        Message(
            'Sales Credit Memo %1 created successfully.\Original Posted Invoice: %2\Bill No.: %3\PNR: %4\Location Code: %5\Reference Invoice No.: %2\\Review selected lines, quantities and GST before posting.',
            Header."No.",
            OriginalInvoice."No.",
            Source."Bill No.",
            Source.PNR,
            Header."Location Code");
    end;

    // ==========================================
    // NEW LOCAL PROCEDURE
    // GST Reference Invoice No. Mapping
    // ==========================================

    local procedure CreateReferenceInvoiceNo(
        var CreditMemoHeader: Record "Sales Header";
        PostedInvoice: Record "Sales Invoice Header")
    var
        RefInvoice: Record "Reference Invoice No.";
    begin
        RefInvoice.Reset();

        RefInvoice.SetRange(
            "Document Type",
            RefInvoice."Document Type"::"Credit Memo");

        RefInvoice.SetRange(
            "Document No.",
            CreditMemoHeader."No.");

        RefInvoice.SetRange(
            "Source Type",
            RefInvoice."Source Type"::Customer);

        RefInvoice.SetRange(
            "Source No.",
            CreditMemoHeader."Sell-to Customer No.");

        RefInvoice.SetRange(
            "Reference Invoice Nos.",
            PostedInvoice."No.");

        // Avoid creating the same reference twice.
        if RefInvoice.FindFirst() then
            exit;

        RefInvoice.Init();

        RefInvoice.Validate(
            "Document Type",
            RefInvoice."Document Type"::"Credit Memo");

        RefInvoice.Validate(
            "Document No.",
            CreditMemoHeader."No.");

        RefInvoice.Validate(
            "Source Type",
            RefInvoice."Source Type"::Customer);

        RefInvoice.Validate(
            "Source No.",
            CreditMemoHeader."Sell-to Customer No.");

        RefInvoice.Validate(
            "Reference Invoice Nos.",
            PostedInvoice."No.");

        RefInvoice.Insert(true);
    end;
}
