
codeunit 50715 "AIRIQ SR Create Memo"
{
    Permissions =
        tabledata "Sales Header" = rim,
        tabledata "Sales Line" = rim,
        tabledata "Sales Return" = rm;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(Serial: Integer; var Header: Record "Sales Header")
    var
        Source: Record "Sales Return";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Sales Return Passenger Name";
        Existing: Record "Sales Header";
        Posted: Record "Sales Cr.Memo Header";
        OriginalInvoice: Record "Sales Invoice Header";
        Setup: Record "Sales & Receivables Setup";
        LineNo: Integer;
    begin
        Source.LockTable();

        if not Source.Get(Serial) then
            Error('Sales Return %1 does not exist.', Serial);

        Source.TestField("Return No.");
        Source.TestField("Invoice No.");
        Source.TestField("A/C Name");
        Source.TestField(PNR);

        // Prevent duplicate Credit Memo for same return
        Existing.SetRange(
            "Document Type",
            Existing."Document Type"::"Credit Memo");
        Existing.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if Existing.FindFirst() then
            Error(
                'Sales Return %1 already has Sales Credit Memo %2.',
                Source."Return No.",
                Existing."No.");

        Posted.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if Posted.FindFirst() then
            Error(
                'Sales Return %1 already has posted Sales Credit Memo %2.',
                Source."Return No.",
                Posted."No.");

        if Source."AIRIQ Memo Created" or
           (Source."AIRIQ Memo No." <> '') then
            Error(
                'Sales Return %1 already has Sales Credit Memo %2. Deleted drafts retain their source link.',
                Source."Return No.",
                Source."AIRIQ Memo No.");

        if (Source.PAX <= 0) or
           (Source."Base Fare" <= 0) then
            Error(
                'Positive PAX and Base Fare are required. Base Fare supplies Unit Price Excl. VAT.');

        // Find Customer
        Customer.SetRange(Name, Source."A/C Name");

        if Customer.Count() <> 1 then
            Error(
                'Exactly one Customer must match A/C Name %1.',
                Source."A/C Name");

        Customer.FindFirst();

        // NEW: Find original Posted Sales Invoice
        if not OriginalInvoice.Get(Source."Invoice No.") then
            Error(
                'Original Posted Sales Invoice %1 was not found. Check Invoice No. in Sales Return %2.',
                Source."Invoice No.",
                Source."Return No.");

        // NEW: Verify Customer
        if OriginalInvoice."Sell-to Customer No." <>
           Customer."No." then
            Error(
                'Customer mismatch for Original Invoice %1. Invoice Customer: %2. Sales Return Customer: %3.',
                OriginalInvoice."No.",
                OriginalInvoice."Sell-to Customer No.",
                Customer."No.");

        if StrLen(Source."Agency ID") >
           MaxStrLen(Header."Agency ID") then
            Error(
                'Agency ID %1 exceeds the existing Sales Header Agency ID length.',
                Source."Agency ID");

        // Find Item by PNR
        Item.SetRange(Description, Source.PNR);

        if Item.Count() <> 1 then
            Error(
                'Exactly one Item Description must match PNR %1.',
                Source.PNR);

        Item.FindFirst();
        Item.TestField("GST Group Code");
        Item.TestField("HSN/SAC Code");

        // Passenger validation
        Passenger.SetCurrentKey(
            "Return No.", PNR, "SL No.");

        Passenger.SetRange(
            "Return No.",
            Source."Return No.");

        Passenger.SetRange(PNR, Source.PNR);

        ValidatePassengers(Source, Passenger);

        if (Passenger.Count() <> 0) and
           (Passenger.Count() <> Source.PAX) then
            Error(
                'Passenger count %1 differs from PAX %2 for Return %3 / PNR %4.',
                Passenger.Count(),
                Source.PAX,
                Source."Return No.",
                Source.PNR);

        Setup.Get();
        Setup.TestField("Credit Memo Nos.");

        // Create Credit Memo Header
        Header.Init();
        Header."Document Type" :=
            Header."Document Type"::"Credit Memo";
        Header.Insert(true);

        Header.Validate(
            "Sell-to Customer No.",
            Customer."No.");

        Header.Validate("Prices Including VAT", false);
        Header.Validate("Document Date", Today());
        Header.Validate("Location Code", 'SILIGURI');

        Header."Agency ID" := Source."Agency ID";

        if Source."Sale Type" =
           Source."Sale Type"::Own then
            Header."Sales Type" :=
                Header."Sales Type"::"Own Sales"
        else
            Header."Sales Type" :=
                Header."Sales Type"::"Third Party Sales";

        Header."AIRIQ Return No." :=
            Source."Return No.";

        Header."AIRIQ Return Serial" :=
            Source."Serial No.";

        Header."AIRIQ Bill No." :=
            Source."Bill No.";

        // NEW: Automatically map verified Posted Invoice No.
        Header."AIRIQ Original Invoice" :=
            OriginalInvoice."No.";

        Header."AIRIQ Entry Date" :=
            Source."Entry Date";

        Header."AIRIQ Reference" :=
            Source."Reference";

        Header."AIRIQ Narration" :=
            Source."Narration";

        Header."AIRIQ Supplier" :=
            Source."Supplier";

        Header."AIRIQ Sale Type" :=
            Source."Sale Type";

        Header.Modify(true);

        // Create Passenger Lines
        LineNo := 10000;

        if Passenger.FindSet() then
            repeat
                AddLine(
                    Header,
                    Source,
                    Item,
                    Passenger."Passenger Name",
                    Passenger.Type,
                    Passenger."SL No.",
                    1,
                    LineNo);

                LineNo += 10000;
            until Passenger.Next() = 0
        else
            AddLine(
                Header,
                Source,
                Item,
                Source."Passenger Name",
                '',
                0,
                Source.PAX,
                LineNo);

        // Update Sales Return
        Source."AIRIQ Memo Created" := true;
        Source."AIRIQ Memo No." := Header."No.";
        Source.Modify(true);

        ReportGST(Header, Source);

        Message(
            'Sales Credit Memo %1 created against Original Posted Sales Invoice %2. Review standard GST Reference Invoice No. before posting.',
            Header."No.",
            OriginalInvoice."No.");
    end;

    local procedure ValidatePassengers(
        Source: Record "Sales Return";
        var Passenger: Record "Sales Return Passenger Name")
    var
        ReturnPassenger: Record "Sales Return Passenger Name";
    begin
        if Passenger.IsEmpty() then begin
            ReturnPassenger.SetRange(
                "Return No.",
                Source."Return No.");

            if not ReturnPassenger.IsEmpty() then
                Error(
                    'Passenger records exist for Return No. %1, but none match PNR %2. Correct the passenger PNR before creating the credit memo.',
                    Source."Return No.",
                    Source.PNR);

            if DelChr(
                Source."Passenger Name",
                '<>', ' ') = '' then
                Error(
                    'No passenger names were found for Return No. %1 / PNR %2. Open View Passenger on the Sales Return and add the passenger names before creating the credit memo.',
                    Source."Return No.",
                    Source.PNR);

            exit;
        end;

        if Passenger.FindSet() then
            repeat
                if DelChr(
                    Passenger."Passenger Name",
                    '<>', ' ') = '' then
                    Error(
                        'Passenger name is blank at SL No. %1 for Return No. %2 / PNR %3.',
                        Passenger."SL No.",
                        Source."Return No.",
                        Source.PNR);
            until Passenger.Next() = 0;
    end;

    local procedure ReportGST(
        Header: Record "Sales Header";
        Source: Record "Sales Return")
    var
        Line: Record "Sales Line";
        TaxValue: Record "Tax Transaction Value";
        Component: Record "Tax Component";
        CGSTAmount: Decimal;
        SGSTAmount: Decimal;
        IGSTAmount: Decimal;
        FoundGST: Boolean;
    begin
        Line.SetRange(
            "Document Type",
            Header."Document Type");

        Line.SetRange(
            "Document No.",
            Header."No.");

        if Line.FindSet() then
            repeat
                TaxValue.Reset();
                TaxValue.SetRange(
                    "Tax Record ID",
                    Line.RecordId());

                TaxValue.SetRange("Tax Type", 'GST');

                TaxValue.SetRange(
                    "Value Type",
                    TaxValue."Value Type"::COMPONENT);

                if TaxValue.FindSet() then
                    repeat
                        Component.Reset();

                        Component.SetRange(
                            "Tax Type",
                            TaxValue."Tax Type");

                        Component.SetRange(
                            ID,
                            TaxValue."Value ID");

                        if Component.FindFirst() then begin
                            case UpperCase(Component.Name) of
                                'CGST':
                                    begin
                                        CGSTAmount += TaxValue.Amount;
                                        FoundGST := true;
                                    end;

                                'SGST':
                                    begin
                                        SGSTAmount += TaxValue.Amount;
                                        FoundGST := true;
                                    end;

                                'IGST':
                                    begin
                                        IGSTAmount += TaxValue.Amount;
                                        FoundGST := true;
                                    end;
                            end;
                        end;
                    until TaxValue.Next() = 0;
            until Line.Next() = 0;

        if not FoundGST then
            Message(
                'No standard GST component results were found for Credit Memo %1. Review tax configuration and posting preview before posting. Source CGST/SGST/IGST: %2 / %3 / %4.',
                Header."No.",
                Source.CGST,
                Source.SGST,
                Source.IGST)
        else
            if (Abs(CGSTAmount - Source.CGST) > 0.01) or
               (Abs(SGSTAmount - Source.SGST) > 0.01) or
               (Abs(IGSTAmount - Source.IGST) > 0.01) then
                Message(
                    'GST differs for Credit Memo %1. Source CGST/SGST/IGST: %2 / %3 / %4. BC calculated: %5 / %6 / %7. Standard GST has not been overridden.',
                    Header."No.",
                    Source.CGST,
                    Source.SGST,
                    Source.IGST,
                    CGSTAmount,
                    SGSTAmount,
                    IGSTAmount);
    end;

    local procedure AddLine(
        Header: Record "Sales Header";
        Source: Record "Sales Return";
        Item: Record Item;
        PassengerName: Text[100];
        PassengerType: Text[50];
        PassengerSL: Integer;
        Qty: Decimal;
        LineNo: Integer)
    var
        Line: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        Line.Init();

        Line."Document Type" :=
            Header."Document Type";

        Line."Document No." :=
            Header."No.";

        Line."Line No." := LineNo;
        Line.Insert(true);

        Line.Validate(Type, Line.Type::Item);
        Line.Validate("No.", Item."No.");

        Line.Description := Source.PNR;

        Line.Validate(FlightType, Source.Type);
        Line.Validate(Quantity, Qty);

        Line.BaseFare := Format(Source."Base Fare");

        Line.Validate(
            "Unit Price",
            Source."Base Fare");

        Line.Validate("Line Discount %", 0);
        Line.Validate("Allow Invoice Disc.", false);

        Line."Travel Date" :=
            Source."Travel Date";

        Line.Sector := Source.Sector;

        Line."Passenger Name" :=
            PassengerName;

        Line."AIRIQ Taxable Value" :=
            Source."Taxable Value";

        Line."AIRIQ Source CGST" :=
            Source."CGST";

        Line."AIRIQ Source SGST" :=
            Source."SGST";

        Line."AIRIQ Source IGST" :=
            Source."IGST";

        Line."AIRIQ Sold Value" :=
            Source."Sold Value";

        Line."AIRIQ XXLN Charges" :=
            Source."XXLN Charges";

        Line."AIRIQ Refund Amount" :=
            Source."Refund Amount";

        Line."AIRIQ Country" :=
            Source."Country";

        Line."AIRIQ State" :=
            Source."State";

        Line."AIRIQ City" :=
            Source."City";

        Line."AIRIQ Travel Time" :=
            Source."Time";

        Line."AIRIQ Airline" :=
            Source."Airline";

        Line."AIRIQ Airline Code" :=
            Source."Airline Code";

        Line."AIRIQ Reference" :=
            Source."Reference";

        Line."AIRIQ Passenger Type" :=
            PassengerType;

        Line."AIRIQ Passenger SL" :=
            PassengerSL;

        Line.Modify(true);

        CalculateTax.CallTaxEngineOnSalesLine(
            Line,
            Line);
    end;
}
