
codeunit 50736 "AIRIQ API SR Create Memo"
{
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rimd,
        tabledata "API Sales Return" = rm,
        tabledata "Reference Invoice No." = rim;

    // Passenger-wise Sales Credit Memo creation.
    // Original Posted Invoice used for validation and reference.
    // Item lines: blank GST Group and HSN/SAC (not exempt).
    // Cancellation G/L line: Standard GST applicable.
    // API Sold Value and XXLN Charges are booking totals.
    // RATE is the original per-passenger rate.

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(
        Serial: Code[20];
        var Header: Record "Sales Header")
    var
        Source: Record "API Sales Return";
        Customer: Record Customer;
        Passenger: Record "API Sales Return Passenger";
        Existing: Record "Sales Header";
        PostedMemo: Record "Sales Cr.Memo Header";
        OriginalInvoice: Record "Sales Invoice Header";
        OriginalLine: Record "Sales Invoice Line";
        ReversibleQty: Decimal;
        SalesSetup: Record "Sales & Receivables Setup";
        CancellationAccount: Record "G/L Account";
        ItemNoForPNR: Code[20];
        NextLineNo: Integer;
        NoSeries: Codeunit "No. Series";
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

        Source.TestField(RATE);
        if (Source.RATE < 0) or (Source."Sold Value" <= 0) or
           (Source."XXLN Charges" < 0) then
            Error('Rate and Sold Value must be positive and cancellation charges cannot be negative.');

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

        if Source."Sales Credit Memo Created" then
            Error(
                'Return %1 is already linked to a Sales Credit Memo.',
                Source."Return No.");

        // Bill No. is custom Invoice Number.
        // It is not the BC Posted Invoice No.
        OriginalInvoice.Reset();
        OriginalInvoice.SetRange(
            "Invoice Number",
            Source."Bill No.");
        OriginalInvoice.SetRange("Sales Type", OriginalInvoice."Sales Type"::"API Sales");

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
                OriginalLine.TestField(
                    Type,
                    OriginalLine.Type::Item);

                OriginalLine.TestField("No.");

                if ItemNoForPNR = '' then
                    ItemNoForPNR := OriginalLine."No."
                else
                    if ItemNoForPNR <> OriginalLine."No." then
                        Error(
                            'PNR %1 has multiple Item Nos. in Posted Invoice %2. Cannot create a single passenger-wise item mapping.',
                            Source.PNR,
                            OriginalInvoice."No.");

                ReversibleQty += OriginalLine.Quantity;

            until OriginalLine.Next() = 0;

        if Source.PAX > ReversibleQty then
            Error(
                'Return PAX %1 exceeds original PNR invoiced quantity %2.',
                Source.PAX,
                ReversibleQty);

        // Customer from original posted invoice.
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
        Header."No. Series" := 'API-SR-CM';
        Header."No." := NoSeries.GetNextNo(Header."No. Series");
        Header.Insert(true);

        Header.Validate(
            "Sell-to Customer No.",
            OriginalInvoice."Sell-to Customer No.");

        // This credit memo uses tax-exclusive staging amounts.
        Header.Validate("Prices Including VAT", false);

        if Source."Entry Date" <> 0DT then
            Header.Validate(
                "Document Date",
                DT2Date(Source."Entry Date"));

        Header.Modify(true);

        // IMPORTANT GST FIX:
        // DO NOT CopySalesDoc here. The credit memo is rebuilt entirely
        // from staging passengers and the original posted item number.
        // Copying a taxable invoice first may leave tax calculation state
        // even after the copied Sales Lines are deleted.
        // Original posted invoice is still used for all matching,
        // customer, location and reference validations above.

        // Original Posted Invoice Location.
        Header.Validate(
            "Location Code",
            OriginalInvoice."Location Code");

        Header.Modify(true);

        // ==========================================
        // PASSENGER-WISE ITEM LINES
        // ==========================================

        NextLineNo := 10000;

        Passenger.Reset();
        Passenger.SetRange(
            "Return No.",
            Source."Return No.");
        Passenger.SetRange(
            PNR,
            Source.PNR);
        Passenger.SetCurrentKey(
            "Return No.",
            PNR,
            "SL No.");

        if Passenger.FindSet() then
            repeat
                AddPassengerItemLine(
                    Header,
                    Source,
                    Passenger,
                    ItemNoForPNR,
                    NextLineNo);

                NextLineNo += 10000;
            until Passenger.Next() = 0;

        // ==========================================
        // DYNAMIC CANCELLATION G/L ACCOUNT
        // ==========================================

        if not SalesSetup.Get() then
            Error(
                'Sales & Receivables Setup does not exist.');

        SalesSetup.TestField(
            "Credit Memo Cancilation G/L");

        CancellationAccount.Get(
            SalesSetup."Credit Memo Cancilation G/L");

        CancellationAccount.TestField(
            "Direct Posting",
            true);

        CancellationAccount.TestField(
            Blocked,
            false);

        AddCancellationLine(
            Header,
            Source,
            CancellationAccount,
            NextLineNo);

        // ==========================================
        // HEADER CUSTOM FIELD MAPPING
        // ==========================================

        Header."AIRIQ Return No." :=
            Source."Return No.";

        Header."AIRIQ API Return Serial" :=
            Source."Serial No.";

        Header."AIRIQ Bill No." :=
            CopyStr(Source."Bill No.", 1, MaxStrLen(Header."AIRIQ Bill No."));

        Header."AIRIQ Original Invoice" :=
            OriginalInvoice."No.";

        Header."AIRIQ Entry Date" :=
            Source."Entry Date";

        Header."AIRIQ Narration" :=
            Source.Narration;

        Header."AIRIQ Supplier" :=
            CopyStr(Source.Supplier, 1, MaxStrLen(Header."AIRIQ Supplier"));

        Header."AIRIQ Sale Type" :=
            Header."AIRIQ Sale Type"::API;
        Header."Sales Type" := Header."Sales Type"::"API Sales";

        Header."Agency ID" :=
            CopyStr(
                Source."Agency ID",
                1,
                MaxStrLen(Header."Agency ID"));

        Header.Modify(true);

        // Original Posted Invoice Reference.
        CreateReferenceInvoiceNo(
            Header,
            OriginalInvoice);

        // Update Sales Return tracking.
        Source."Sales Credit Memo Created" := true;

        Source.Modify(true);

        Message(
            'Sales Credit Memo %1 created successfully.\Original Posted Invoice: %2\Bill No.: %3\PNR: %4\Location Code: %5\Reference Invoice No.: %2\\Verify GST Statistics and Preview Posting before posting.',
            Header."No.",
            OriginalInvoice."No.",
            Source."Bill No.",
            Source.PNR,
            Header."Location Code");
    end;

    // ==========================================
    // PASSENGER ITEM LINE CREATION
    // NO ITEM GST - API SALES PATTERN
    // ==========================================

    local procedure AddPassengerItemLine(
        CreditHeader: Record "Sales Header";
        Source: Record "API Sales Return";
        Passenger: Record "API Sales Return Passenger";
        ItemNo: Code[20];
        LineNo: Integer)
    var
        Line: Record "Sales Line";
    begin
        Line.Init();

        Line."Document Type" :=
            CreditHeader."Document Type";
        Line."Document No." :=
            CreditHeader."No.";
        Line."Line No." := LineNo;

        Line.Insert(true);

        Line.Validate(
            Type,
            Line.Type::Item);

        Line.Validate(
            "No.",
            ItemNo);

        Line.Description :=
            CopyStr(
                Source.PNR,
                1,
                MaxStrLen(Line.Description));

        Line.Validate(
            Quantity,
            1);

        // Sold Value is the total for all return passengers.
        Line.Validate(
            "Unit Price",
            Source."Sold Value" / Source.PAX);

        // Original AIRIQ fields.
        Line."Travel Date" :=
            Source."Travel Date";

        Line.Sector :=
            Source.Sector;

        // Avoid custom invoice-only FlightType tax trigger.
        Line.FlightType :=
            Source.Type;

        Line."AIRIQ Rate" := Source.RATE;

        Line."Passenger Name" :=
            Passenger."Passenger Name";

        Line."AIRIQ Passenger Type" :=
            Passenger.Type;



        SetReturnMetadata(
            Line,
            Source);

        // ==========================================
        // FIX: NO GST ON PASSENGER ITEM LINES
        // ==========================================

        // Item Master GST configuration remains unchanged.
        // Clear GST classification on this Credit Memo line.
        Line.Validate(
            "GST Group Code",
            '');

        Line.Validate(
            "HSN/SAC Code",
            '');

        // Same approach as working API Sales invoices:
        // Keep the item line non-exempt, with no GST classification.
        // No original invoice lines have been copied.
        Line.Validate(
            Exempted,
            false);

        Line.Modify(true);

        // Re-run the India tax engine against the final line state.
        // The original invoice's tax values are NOT carried forward.
        RefreshPassengerLineTax(Line);
    end;

    local procedure RefreshPassengerLineTax(var Line: Record "Sales Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
        PreviousLine: Record "Sales Line";
    begin
        // Get the final persisted Sales Line and calculate using its
        // blank GST Group/HSN setup, not a copied invoice line.
        Line.Get(
            Line."Document Type",
            Line."Document No.",
            Line."Line No.");

        PreviousLine := Line;

        CalculateTax.CallTaxEngineOnSalesLine(
            Line,
            PreviousLine);
    end;

    // ==========================================
    // CANCELLATION G/L LINE CREATION
    // STANDARD BC GST CALCULATION
    // ==========================================

    local procedure AddCancellationLine(
        CreditHeader: Record "Sales Header";
        Source: Record "API Sales Return";
        GLAccount: Record "G/L Account";
        LineNo: Integer)
    var
        Line: Record "Sales Line";
    begin
        Line.Init();

        Line."Document Type" :=
            CreditHeader."Document Type";
        Line."Document No." :=
            CreditHeader."No.";
        Line."Line No." := LineNo;

        Line.Insert(true);

        Line.Validate(
            Type,
            Line.Type::"G/L Account");

        Line.Validate(
            "No.",
            GLAccount."No.");

        Line.Validate(
            "Unit of Measure Code",
            'PAX');

        // One negative quantity for all cancelled PAX.
        Line.Validate(
            Quantity,
            -Source.PAX);

        // Spread the total cancellation charge across the returned PAX.
        Line.Validate(
            "Unit Price",
            Source."XXLN Charges" / Source.PAX);

        // Cancellation G/L must remain taxable.
        Line.Validate(
            Exempted,
            false);

        // GST comes from configured G/L Account.
        // No hardcoded GST percentage.
        Line.TestField(
            "GST Group Code");

        Line.TestField(
            "HSN/SAC Code");

        SetReturnMetadata(
            Line,
            Source);

        Line.Modify(true);
    end;

    // ==========================================
    // AIRIQ CUSTOM FIELD MAPPING
    // ==========================================

    local procedure SetReturnMetadata(
        var Line: Record "Sales Line";
        Source: Record "API Sales Return")
    begin
        Line."AIRIQ Sold Value" :=
            Source."Sold Value";

        Line."AIRIQ XXLN Charges" :=
            Source."XXLN Charges";

        Line."AIRIQ Refund Amount" :=
            Source."Refund Amount";

        Line."AIRIQ Country" :=
            CopyStr(Source.Country, 1, MaxStrLen(Line."AIRIQ Country"));

        Line."AIRIQ State" :=
            CopyStr(Source.State, 1, MaxStrLen(Line."AIRIQ State"));

        Line."AIRIQ City" :=
            CopyStr(Source.City, 1, MaxStrLen(Line."AIRIQ City"));

        Line."AIRIQ Travel Time" :=
            Source."Flight Time";

        Line."AIRIQ Airline" :=
            Source.Airline;

        Line."AIRIQ Airline Code" :=
            CopyStr(Source."Airline Code", 1, MaxStrLen(Line."AIRIQ Airline Code"));

    end;

    // ==========================================
    // GST REFERENCE INVOICE NO.
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

        // Avoid duplicate reference entries.
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
