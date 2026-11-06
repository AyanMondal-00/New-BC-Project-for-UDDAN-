
codeunit 50700 "AIRIQ Return Credit Memo"
{
    Permissions = tabledata "Purchase Return" = rm,
                  tabledata "Purchase Header" = rim,
                  tabledata "Purchase Line" = rim;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(SerialNo: Integer; var Header: Record "Purchase Header")
    var
        Source: Record "Purchase Return";
        Vendor: Record Vendor;
        Item: Record Item;
        Line: Record "Purchase Line";
        Setup: Record "Purchases & Payables Setup";
        PostingSetup: Record "General Posting Setup";
        GSTGroup: Record "GST Group";
        Numbering: Codeunit "AIRIQ AQPR No. Mgt";
        GrossAmount: Decimal;
        ExpectedAmount: Decimal;
        AmountPrecision: Decimal;
    begin
        // Lock source record before checking and creating memo.
        Source.LockTable();

        if not Source.Get(SerialNo) then
            Error(
                'Purchase Return %1 no longer exists.',
                SerialNo);

        CheckDuplicate(Source);

        Source.TestField(Airline);
        Source.TestField(PNR);
        Source.TestField("Purchase Date");

        if (Source.Pax <= 0) or
           (Source.Rate < 0) or
           (Source.Amount <= 0)
        then
            Error(
                'Purchase Return %1 requires positive Pax and Amount, and a nonnegative Rate.',
                SerialNo);

        if Source."XXLN Charges" < 0 then
            Error(
                'Purchase Return %1: XXLN Charges cannot be negative.',
                SerialNo);

        // =========================================
        // VENDOR MATCHING
        // =========================================

        Vendor.Reset();
        Vendor.SetRange(Name, Source.Airline);

        if Vendor.IsEmpty() then
            Error(
                'No Vendor matches Airline "%1". Configure the Vendor name before creating the credit memo.',
                Source.Airline);

        if Vendor.Count() <> 1 then
            Error(
                'More than one Vendor matches Airline "%1". Resolve duplicate Vendor names.',
                Source.Airline);

        Vendor.FindFirst();

        Vendor.TestField("Vendor Posting Group");
        Vendor.TestField("Gen. Bus. Posting Group");
        Vendor.TestField(Blocked, Vendor.Blocked::" ");

        // =========================================
        // ITEM MATCHING BY PNR
        // =========================================

        Item.Reset();
        Item.SetRange(Description, Source.PNR);

        if Item.IsEmpty() then
            Error(
                'No Item has Description (PNR) "%1". Run the existing AIRIQ item creation process first.',
                Source.PNR);

        if Item.Count() <> 1 then
            Error(
                'More than one Item has Description (PNR) "%1". Resolve the ambiguous PNR.',
                Source.PNR);

        Item.FindFirst();

        Item.TestField(Blocked, false);
        Item.TestField("Gen. Prod. Posting Group");
        Item.TestField("GST Group Code");
        Item.TestField("HSN/SAC Code");

        if not GSTGroup.Get(Item."GST Group Code") then
            Error(
                'GST Group %1 for Item %2 is missing.',
                Item."GST Group Code",
                Item."No.");

        if not PostingSetup.Get(
            Vendor."Gen. Bus. Posting Group",
            Item."Gen. Prod. Posting Group")
        then
            Error(
                'General Posting Setup is missing for business group %1 and product group %2.',
                Vendor."Gen. Bus. Posting Group",
                Item."Gen. Prod. Posting Group");

        PostingSetup.TestField("Purch. Credit Memo Account");

        // =========================================
        // PURCHASE SETUP
        // =========================================

        Setup.Get();
        Setup.TestField("Credit Memo Nos.");
        Setup.TestField("Posted Credit Memo Nos.");

        // =========================================
        // CREATE PURCHASE CREDIT MEMO HEADER
        // =========================================

        Clear(Header);
        Header.Init();

        Header."Document Type" :=
            Header."Document Type"::"Credit Memo";

        Header.Insert(true);

        Header.Validate(
            "Buy-from Vendor No.",
            Vendor."No.");

        Header.Validate(
            "Document Date",
            DT2Date(Source."Purchase Date"));

        // Posting Date remains the standard BC Work Date.

        Header."AIRIQ Return Serial No." :=
            Source."Serial No.";

        Header."AIRIQ Voucher Number" :=
            Source."Voucher Number";

        Header."AIRIQ Entry Date" :=
            Source."Entry Date";

        Header."AIRIQ Purchase Date" :=
            Source."Purchase Date";

        Header."AIRIQ Reference" :=
            Source."Reference";

        Header."AIRIQ Narration" :=
            Source."Narration";

        Header."AIRIQ Airline ID" :=
            Source."Airline ID";

        Header.Validate(
            "Vendor Cr. Memo No.",
            Numbering.NextNumber());

        Header.Modify(true);

        // =========================================
        // CALCULATE PURCHASE RETURN AMOUNT
        // =========================================

        AmountPrecision := GetAmountPrecision(Header);

        GrossAmount :=
            Round(Source.Pax * Source.Rate, AmountPrecision);

        if Source."XXLN Charges" > GrossAmount then
            Error(
                'Purchase Return %1: XXLN Charges %2 cannot exceed Gross Amount %3.',
                SerialNo,
                Source."XXLN Charges",
                GrossAmount);

        ExpectedAmount :=
            Round(
                GrossAmount - Source."XXLN Charges",
                AmountPrecision);

        if ExpectedAmount <> Round(Source.Amount, AmountPrecision) then
            Error(
                'Purchase Return %1: Source Amount %2 does not match calculated Amount %3. Formula: (Pax x Rate) - XXLN Charges.',
                SerialNo,
                Source.Amount,
                ExpectedAmount);

        // =========================================
        // CREATE PURCHASE CREDIT MEMO LINE
        // =========================================

        Line.Init();

        Line."Document Type" :=
            Header."Document Type";

        Line."Document No." :=
            Header."No.";

        Line."Line No." := 10000;

        Line.Validate(Type, Line.Type::Item);

        Line.Validate("No.", Item."No.");

        Line.Validate(
            "Location Code",
            'SILIGURI');

        // Quantity = Number of passengers
        Line.Validate(Quantity, Source.Pax);

        // Unit Cost = Rate per passenger
        Line.Validate(
            "Direct Unit Cost",
            Source.Rate);

        Line.Validate("Line Discount %", 0);

        Line.Validate("Allow Invoice Disc.", false);

        // =========================================
        // XXLN CHARGES DEDUCTION
        // =========================================
        // Gross Amount = Pax x Rate
        // Final Amount = Gross Amount - XXLN Charges
        //
        // Standard BC Line Discount Amount is used
        // to reduce the financial line amount.
        // =========================================

        Line.Validate(
            "Line Discount Amount",
            Source."XXLN Charges");

        // Validate standard BC financial amount.
        if Round(Line."Line Amount", AmountPrecision) <>
           Round(Source.Amount, AmountPrecision)
        then
            Error(
                'Purchase Return %1: BC Line Amount %2 differs from Source Amount %3 after XXLN deduction.',
                SerialNo,
                Line."Line Amount",
                Source.Amount);

        // =========================================
        // AIRIQ CUSTOM FIELD MAPPING
        // =========================================

        Line."AIRIQ PNR" :=
            Source."PNR";

        Line."Sample Sector" :=
            Source."Sector";

        Line."AIRIQ Country" :=
            Source."Country";

        Line."Sample Flight Type" :=
            Source."Type";

        Line."AIRIQ Pax" :=
            Source."Pax";

        Line."Sample Base Fare" :=
            Source."Base Fare";

        Line."Sample Other Charges" :=
            Source."Others";

        Line."AIRIQ Rate" :=
            Source."Rate";

        Line."AIRIQ Discount" :=
            Source."Discount";

        Line."AIRIQ XXLN Charges" :=
            Source."XXLN Charges";

        Line."AIRIQ Return Amount" :=
            Source."Amount";

        Line."Sample Travel Date" :=
            Source."Travel Date";

        Line."AIRIQ Flight No." :=
            Source."Flight No.";

        Line."AIRIQ Departure Time" :=
            Source."Departure Time";

        Line."AIRIQ Arrival Time" :=
            Source."Arrival Time";

        Line."AIRIQ Cost Revision" :=
            Source."Cost Revision";

        Line."Sample Purchase Date" :=
            Source."Purchase Date";

        Line."Sample Entry Date" :=
            Source."Entry Date";

        Line."Sample Airline" :=
            Source.Airline;

        // Insert line after all calculations and mappings.
        Line.Insert(true);

        Line.Get(Header."Document Type", Header."No.", 10000);
        if Round(Line."Line Amount", AmountPrecision) <>
           Round(Source.Amount, AmountPrecision)
        then
            Error(
                'Purchase Return %1: persisted BC Line Amount %2 differs from Source Amount %3.',
                SerialNo, Line."Line Amount", Source.Amount);

        // =========================================
        // UPDATE PURCHASE RETURN SOURCE
        // =========================================

        Source."AIRIQ Credit Memo Created" := true;

        Source."AIRIQ Credit Memo No." :=
            Header."No.";

        Source."AIRIQ Vendor Cr. Memo No." :=
            Header."Vendor Cr. Memo No.";

        Source.Modify(true);
    end;

    // =========================================
    // CURRENCY AMOUNT ROUNDING PRECISION
    // =========================================

    local procedure GetAmountPrecision(
        Header: Record "Purchase Header"): Decimal
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(Header."Currency Code");

        exit(Currency."Amount Rounding Precision");
    end;

    // =========================================
    // DUPLICATE CREDIT MEMO PROTECTION
    // =========================================

    local procedure CheckDuplicate(
        Source: Record "Purchase Return")
    var
        Header: Record "Purchase Header";
        Posted: Record "Purch. Cr. Memo Hdr.";
    begin
        Posted.SetRange(
            "AIRIQ Return Serial No.",
            Source."Serial No.");

        if Posted.FindFirst() then
            Error(
                'Purchase Return %1 already has posted Purchase Credit Memo %2.',
                Source."Serial No.",
                Posted."No.");

        Header.SetRange(
            "Document Type",
            Header."Document Type"::"Credit Memo");

        Header.SetRange(
            "AIRIQ Return Serial No.",
            Source."Serial No.");

        if Header.FindFirst() then
            Error(
                'Purchase Return %1 already has unposted Purchase Credit Memo %2.',
                Source."Serial No.",
                Header."No.");

        if Source."AIRIQ Vendor Cr. Memo No." <> '' then begin

            Posted.Reset();

            Posted.SetRange(
                "Vendor Cr. Memo No.",
                Source."AIRIQ Vendor Cr. Memo No.");

            if Posted.FindFirst() then
                Error(
                    'Purchase Return %1 is linked to posted Purchase Credit Memo %2.',
                    Source."Serial No.",
                    Posted."No.");

            Header.SetRange("AIRIQ Return Serial No.");

            Header.SetRange(
                "Vendor Cr. Memo No.",
                Source."AIRIQ Vendor Cr. Memo No.");

            if Header.FindFirst() then
                Error(
                    'Purchase Return %1 is linked to Purchase Credit Memo %2.',
                    Source."Serial No.",
                    Header."No.");
        end;

        if Source."AIRIQ Credit Memo Created" or
           (Source."AIRIQ Credit Memo No." <> '') or
           (Source."AIRIQ Posted Cr. Memo No." <> '')
        then
            Error(
                'Purchase Return %1 was already used for Purchase Credit Memo %2 (posted: %3). The link is retained even if a draft was deleted; contact your administrator.',
                Source."Serial No.",
                Source."AIRIQ Credit Memo No.",
                Source."AIRIQ Posted Cr. Memo No.");
    end;
}
