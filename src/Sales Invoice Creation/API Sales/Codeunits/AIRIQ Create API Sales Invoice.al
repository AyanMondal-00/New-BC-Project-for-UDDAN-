codeunit 50435 "AIRIQ Create API Sales Invoice"
{
    procedure CreateAPISalesInvoice(var APISales: Record "API Sales Format")
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Item: Record Item;
        PassengerNames: List of [Text];
        PassengerName: Text;
        NoSeries: Codeunit "No. Series";
        AQNumber: BigInteger;
        LineNo: Integer;
    begin
        AQNumber := APISales."Ref No./AQ Number";

        if APISales."Sales Invoice Created" then
            Error(
                'Sales Invoice has already been created for AQ Number %1.',
                AQNumber);

        if AQNumber = 0 then
            Error('AQ Number is required.');

        if APISales.Pax <= 0 then
            Error(
                'Pax must be greater than zero for AQ Number %1.',
                AQNumber);

        // STEP 1: CUSTOMER MATCHING
        Customer.Reset();
        Customer.SetRange(Name, APISales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                APISales."Agency Name",
                AQNumber);

        // STEP 2: ITEM MATCHING BY PNR
        Item.Reset();
        Item.SetRange(Description, APISales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                APISales.PNR,
                AQNumber);

        // STEP 3: CHECK EXISTING UNPOSTED API INVOICE
        SalesHeader.Reset();

        SalesHeader.SetRange(
            "Document Type",
            SalesHeader."Document Type"::Invoice);

        SalesHeader.SetRange(
            "Sales Type",
            SalesHeader."Sales Type"::"API Sales");

        SalesHeader.SetRange("AQ Number", AQNumber);

        if not SalesHeader.IsEmpty() then
            Error(
                'An API Sales Invoice already exists for AQ Number %1.',
                AQNumber);

        SalesHeader.Reset();

        // Resolve and validate passenger names
        // before consuming invoice numbering.
        GetPassengerNames(APISales, PassengerNames);

        // STEP 4: CREATE SALES INVOICE HEADER
        SalesHeader.Init();

        SalesHeader."Document Type" :=
            SalesHeader."Document Type"::Invoice;

        // Dedicated API Sales Invoice No. Series
        SalesHeader."No. Series" := 'API-SLI';

        SalesHeader."No." :=
            NoSeries.GetNextNo(SalesHeader."No. Series");

        SalesHeader.Insert(true);

        SalesHeader.Validate(
            "Sell-to Customer No.",
            Customer."No.");

        SalesHeader.Validate(
            "Document Date",
            Today());

        SalesHeader.Validate(
            "Location Code",
            'SILIGURI');

        SalesHeader."AQ Number" := AQNumber;

        SalesHeader."Agency ID" :=
            APISales."Agency ID";

        // Dynamic Sales Type
        SalesHeader."Sales Type" :=
            SalesHeader."Sales Type"::"API Sales";

        SalesHeader."Invoice Number" :=
            APISales."Invoice Number";

        SalesHeader.Modify(true);

        // STEP 5-6: CREATE ONE SALES LINE PER PASSENGER
        LineNo := 10000;

        foreach PassengerName in PassengerNames do begin
            CreateAPISalesInvoiceLine(
                SalesHeader,
                APISales,
                Item,
                CopyStr(PassengerName, 1, 100),
                LineNo,
                1);

            LineNo += 10000;
        end;

        // STEP 7: UPDATE STAGING RECORD
        APISales."Select" := false;
        APISales."Sales Invoice Created" := true;

        APISales.Modify(true);

        Message(
            'Sales Invoice %1 created successfully for AQ Number %2.',
            SalesHeader."No.",
            AQNumber);
    end;

    // ============================================
    // FETCH AND VALIDATE INDIVIDUAL PASSENGER NAMES
    // ============================================

    local procedure GetPassengerNames(
        APISales: Record "API Sales Format";
        var PassengerNames: List of [Text])
    var
        Passenger: Record "API Sales Passenger Name";
        StagingNames: List of [Text];
        PassengerName: Text;
    begin
        Clear(PassengerNames);

        Passenger.SetCurrentKey(
            "Ref No./AQ Number",
            PNR,
            "SL No.");

        Passenger.SetRange(
            "Ref No./AQ Number",
            APISales."Ref No./AQ Number");

        Passenger.SetRange(
            PNR,
            APISales.PNR);

        // PRIMARY SOURCE:
        // Fetch passengers from API Sales Passenger Table.
        if Passenger.FindSet() then begin
            repeat
                PassengerNames.Add(
                    DelChr(
                        Passenger."Passenger Name",
                        '<>',
                        ' '));
            until Passenger.Next() = 0;
        end else begin

            // FALLBACK SOURCE:
            // Split comma-separated passenger names
            // from the existing API Sales staging table.

            StagingNames := APISales.Passenger.Split(',');

            foreach PassengerName in StagingNames do
                PassengerNames.Add(
                    DelChr(
                        PassengerName,
                        '<>',
                        ' '));
        end;

        // VALIDATE PASSENGER COUNT WITH PAX
        if PassengerNames.Count() <> APISales.Pax then
            Error(
                'Passenger count mismatch for AQ Number %1, PNR %2. PAX: %3, passenger names: %4. Check View Passenger before creating the invoice.',
                APISales."Ref No./AQ Number",
                APISales.PNR,
                APISales.Pax,
                PassengerNames.Count());

        // VALIDATE BLANK PASSENGER NAME
        foreach PassengerName in PassengerNames do
            if PassengerName = '' then
                Error(
                    'Passenger Name cannot be blank for AQ Number %1, PNR %2. Check View Passenger before creating the invoice.',
                    APISales."Ref No./AQ Number",
                    APISales.PNR);
    end;

    // ============================================
    // CREATE INDIVIDUAL PASSENGER INVOICE LINE
    // ============================================

    local procedure CreateAPISalesInvoiceLine(
        var SalesHeader: Record "Sales Header";
        var APISales: Record "API Sales Format";
        var Item: Record Item;
        PassengerName: Text[100];
        LineNo: Integer;
        LineQuantity: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();

        SalesLine."Document Type" :=
            SalesHeader."Document Type";

        SalesLine."Document No." :=
            SalesHeader."No.";

        SalesLine."Line No." := LineNo;

        SalesLine.Insert(true);

        // STEP 1: ITEM MAPPING
        SalesLine.Validate(
            Type,
            SalesLine.Type::Item);

        SalesLine.Validate(
            "No.",
            Item."No.");

        // PNR as Description
        SalesLine.Description := APISales.PNR;

        // STEP 2: FLIGHT TYPE
        // Direct assignment prevents the custom
        // FlightType OnValidate GST Tax Engine call.
        SalesLine.FlightType := APISales.Type;

        // STEP 3: PASSENGER-WISE QUANTITY
        SalesLine.Validate(
            Quantity,
            LineQuantity);

        // STEP 4: UNIT PRICE = API RATE
        SalesLine.Validate(
            "Unit Price",
            APISales.Rate);

        // STEP 5: API SALES NON-GST HANDLING
        // Item validation may populate GST setup.
        // Remove it on this API invoice line only.
        // The Item Card itself is not modified.

        SalesLine.Validate(
            "GST Group Code",
            '');

        SalesLine.Validate(
            "HSN/SAC Code",
            '');

        // STEP 6: TRAVEL DETAILS
        SalesLine."Travel Date" :=
            APISales."Travel Date";

        SalesLine.Sector :=
            APISales.Sector;

        // STEP 7: INDIVIDUAL PASSENGER
        SalesLine."Passenger Name" :=
            PassengerName;

        // No API mapping for:
        // BaseFare
        // Other Charges
        // AIRIQ GST Base Fare
        // CGST / SGST / IGST

        SalesLine.Modify(true);
    end;
}