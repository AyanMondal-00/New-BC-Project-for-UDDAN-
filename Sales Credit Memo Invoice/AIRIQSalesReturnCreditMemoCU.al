
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

        // Prevent duplicate credit memo
        Existing.Reset();
        Existing.SetRange(
            "Document Type",
            Existing."Document Type"::"Credit Memo");
        Existing.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if Existing.FindFirst() then
            Error(
                'Sales Return %1 already has Credit Memo %2.',
                Source."Return No.",
                Existing."No.");

        Posted.Reset();
        Posted.SetRange(
            "AIRIQ Return No.",
            Source."Return No.");

        if Posted.FindFirst() then
            Error(
                'Sales Return %1 already has Posted Credit Memo %2.',
                Source."Return No.",
                Posted."No.");

        if Source."AIRIQ Memo Created" or
           (Source."AIRIQ Memo No." <> '') then
            Error(
                'Sales Return %1 is already linked to Credit Memo %2.',
                Source."Return No.",
                Source."AIRIQ Memo No.");

        if Source.PAX <= 0 then
            Error('PAX must be greater than zero.');

        if Source."Base Fare" <= 0 then
            Error('Base Fare must be greater than zero.');

        if Source."Other Charges" < 0 then
            Error('Other Charges cannot be negative.');

        if Source."XXLN Charges" < 0 then
            Error('XXLN Charges cannot be negative.');

        // Customer Mapping
        Customer.Reset();
        Customer.SetRange(Name, Source."A/C Name");

        if Customer.Count() <> 1 then
            Error(
                'Exactly one Customer must match A/C Name %1.',
                Source."A/C Name");

        Customer.FindFirst();

        // Original Posted Invoice
        if not OriginalInvoice.Get(Source."Invoice No.") then
            Error(
                'Original Posted Sales Invoice %1 not found.',
                Source."Invoice No.");

        if OriginalInvoice."Sell-to Customer No." <>
           Customer."No." then
            Error(
                'Original Invoice %1 belongs to Customer %2, but Sales Return belongs to %3.',
                OriginalInvoice."No.",
                OriginalInvoice."Sell-to Customer No.",
                Customer."No.");

        if StrLen(Source."Agency ID") >
           MaxStrLen(Header."Agency ID") then
            Error(
                'Agency ID %1 exceeds Sales Header field length.',
                Source."Agency ID");

        // Item Mapping by PNR
        Item.Reset();
        Item.SetRange(Description, Source.PNR);

        if Item.Count() <> 1 then
            Error(
                'Exactly one Item must match PNR %1.',
                Source.PNR);

        Item.FindFirst();
        Item.TestField("GST Group Code");
        Item.TestField("HSN/SAC Code");

        // Passenger Mapping
        Passenger.Reset();
        Passenger.SetCurrentKey(
            "Return No.", PNR, "SL No.");

        Passenger.SetRange(
            "Return No.",
            Source."Return No.");

        Passenger.SetRange(PNR, Source.PNR);

        ValidatePassengers(Source, Passenger);

        if Passenger.Count() <> Source.PAX then
            Error(
                'Passenger Count %1 does not match PAX %2 for Return %3 / PNR %4.',
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

        if Source."Entry Date" <> 0DT then
            Header.Validate(
                "Document Date",
                DT2Date(Source."Entry Date"))
        else
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

        // Custom Header Mapping
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

        Header.Modify(true);

        // Create one line per passenger
        LineNo := 10000;

        if Passenger.FindSet() then
            repeat
                AddPassengerLine(
                    Header,
                    Source,
                    Item,
                    Passenger,
                    LineNo);

                LineNo += 10000;
            until Passenger.Next() = 0;

        // Mark source as processed
        Source."AIRIQ Memo Created" := true;
        Source."AIRIQ Memo No." := Header."No.";

        Source.Modify(true);

        Message(
            'Sales Credit Memo %1 created successfully with %2 passenger lines against Invoice %3. Review amounts and standard GST reference before posting.',
            Header."No.",
            Source.PAX,
            OriginalInvoice."No.");
    end;

    local procedure ValidatePassengers(
        Source: Record "Sales Return";
        var Passenger: Record "Sales Return Passenger Name")
    var
        ReturnPassenger: Record "Sales Return Passenger Name";
    begin
        if Passenger.IsEmpty() then begin
            ReturnPassenger.Reset();
            ReturnPassenger.SetRange(
                "Return No.",
                Source."Return No.");

            if not ReturnPassenger.IsEmpty() then
                Error(
                    'Passengers exist for Return %1 but their PNR does not match %2. Check Passenger List.',
                    Source."Return No.",
                    Source.PNR);

            Error(
                'No passengers found for Return %1 / PNR %2.',
                Source."Return No.",
                Source.PNR);
        end;

        if Passenger.FindSet() then
            repeat
                if DelChr(
                    Passenger."Passenger Name",
                    '<>', ' ') = '' then
                    Error(
                        'Passenger Name is blank at SL No. %1.',
                        Passenger."SL No.");
            until Passenger.Next() = 0;
    end;

    local procedure AddPassengerLine(
        Header: Record "Sales Header";
        Source: Record "Sales Return";
        Item: Record Item;
        Passenger: Record "Sales Return Passenger Name";
        LineNo: Integer)
    var
        Line: Record "Sales Line";
        CalculateTax: Codeunit "Calculate Tax";
        UnitTicketPrice: Decimal;
        PassengerSoldValue: Decimal;
        PassengerTaxableValue: Decimal;
        PassengerCGST: Decimal;
        PassengerSGST: Decimal;
        PassengerIGST: Decimal;
    begin
        // Base Fare and Other Charges are per passenger
        UnitTicketPrice :=
            Source."Base Fare" +
            Source."Other Charges";

        // Sold Value and source GST are total values
        PassengerSoldValue :=
            Source."Sold Value" / Source.PAX;

        PassengerTaxableValue :=
            Source."Taxable Value" / Source.PAX;

        PassengerCGST :=
            Source.CGST / Source.PAX;

        PassengerSGST :=
            Source.SGST / Source.PAX;

        PassengerIGST :=
            Source.IGST / Source.PAX;

        Line.Init();

        Line."Document Type" :=
            Header."Document Type";

        Line."Document No." :=
            Header."No.";

        Line."Line No." := LineNo;

        Line.Insert(true);

        Line.Validate(Type, Line.Type::Item);
        Line.Validate("No.", Item."No.");

        Line.Validate(
            "Location Code",
            Header."Location Code");

        Line.Validate(FlightType, Source.Type);

        // One passenger = one quantity
        Line.Validate(Quantity, 1);

        // Unit Price Excl. VAT
        Line.Validate(
            "Unit Price",
            UnitTicketPrice);

        Line.Validate("Line Discount %", 0);
        Line.Validate("Allow Invoice Disc.", false);

        Line.Description := Source.PNR;

        Line.BaseFare :=
            Format(Source."Base Fare");

        // Passenger Details
        Line."Passenger Name" :=
            Passenger."Passenger Name";

        Line."AIRIQ Passenger Type" :=
            Passenger.Type;

        Line."AIRIQ Passenger SL" :=
            Passenger."SL No.";

        // Travel Details
        Line."Travel Date" :=
            Source."Travel Date";

        Line.Sector := Source.Sector;

        Line."AIRIQ Country" :=
            Source.Country;

        Line."AIRIQ State" :=
            Source.State;

        Line."AIRIQ City" :=
            Source.City;

        Line."AIRIQ Travel Time" :=
            Source.Time;

        Line."AIRIQ Airline" :=
            Source.Airline;

        Line."AIRIQ Airline Code" :=
            Source."Airline Code";

        Line."AIRIQ Reference" :=
            Source.Reference;

        // Passenger-wise source amounts
        // Informational only; standard tax engine
        // determines actual GST.
        Line."AIRIQ Taxable Value" :=
            PassengerTaxableValue;

        Line."AIRIQ Source CGST" :=
            PassengerCGST;

        Line."AIRIQ Source SGST" :=
            PassengerSGST;

        Line."AIRIQ Source IGST" :=
            PassengerIGST;

        Line."AIRIQ Sold Value" :=
            PassengerSoldValue;

        // XXLN Charges is per passenger
        Line."AIRIQ XXLN Charges" :=
            Source."XXLN Charges";

        // Preserve source refund value without
        // assuming whether it is total or per PAX.
        Line."AIRIQ Refund Amount" :=
            Source."Refund Amount";

        Line.Modify(true);

        // Standard BC Tax Engine
        CalculateTax.CallTaxEngineOnSalesLine(
            Line,
            Line);
    end;
}
