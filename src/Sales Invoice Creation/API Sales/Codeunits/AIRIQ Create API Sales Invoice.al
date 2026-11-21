
codeunit 50435 "AIRIQ Create API Sales Invoice"
{
    procedure CreateAPISalesInvoice(var APISales: Record "API Sales Format")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "API Sales Passenger Name";
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

        // STEP 5: FILTER PASSENGERS
        Passenger.Reset();

        Passenger.SetRange(
            "Ref No./AQ Number",
            AQNumber);

        Passenger.SetRange(PNR, APISales.PNR);

        Passenger.SetCurrentKey(
            "Ref No./AQ Number",
            PNR,
            "SL No.");

        LineNo := 10000;

        // STEP 6: CREATE PASSENGER-WISE SALES LINES
        if Passenger.FindSet() then begin
            repeat
                CreateAPISalesInvoiceLine(
                    SalesHeader,
                    APISales,
                    Item,
                    Passenger."Passenger Name",
                    LineNo,
                    1);

                LineNo += 10000;

            until Passenger.Next() = 0;
        end else begin
            // Fallback when no passenger details exist
            CreateAPISalesInvoiceLine(
                SalesHeader,
                APISales,
                Item,
                APISales.Passenger,
                LineNo,
                APISales.Pax);
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
