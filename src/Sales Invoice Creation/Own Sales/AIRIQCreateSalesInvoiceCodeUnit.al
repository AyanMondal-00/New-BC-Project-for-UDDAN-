
codeunit 50426 "AIRIQ Create Sales Invoice"
{
    TableNo = "Normal Sales";

    trigger OnRun()
    begin
        CreateOwnSalesInvoice(Rec);
    end;

    [CommitBehavior(CommitBehavior::Error)]
    procedure CreateOwnSalesInvoice(var NormalSales: Record "Normal Sales")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Own Sales Passenger Name";
        SameAQSales: Record "Normal Sales";
        PostedInvoice: Record "Sales Invoice Header";
        AQNumber: BigInteger;
        LineNo: Integer;
        UnitPriceValue: Decimal;
    begin
        AlreadyCreated := false;
        AQNumber := NormalSales."Ref No./AQ Number";
        if AQNumber = 0 then
            Error('AQ Number is required.');

        // Acquire the same first source-row update lock for all workers for this AQ.
        // This also serializes legacy duplicate source rows without changing import logic.
        SameAQSales.LockTable();
        SameAQSales.SetRange("Ref No./AQ Number", AQNumber);
        if not SameAQSales.FindFirst() then
            Error('No source record remains for AQ Number %1. Refresh the page and retry.', AQNumber);
        NormalSales.Get(NormalSales."Serial No.");
        if NormalSales."Ref No./AQ Number" <> AQNumber then
            Error('AQ Number changed during selection. Refresh the page and retry.');

        if NormalSales."Sales Invoice Created" then begin
            AlreadyCreated := true;
            exit;
        end;

        SameAQSales.SetRange("Sales Invoice Created", true);
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Sales Type", SalesHeader."Sales Type"::"Own Sales");
        SalesHeader.SetRange("AQ Number", AQNumber);
        PostedInvoice.SetRange("Sales Type", PostedInvoice."Sales Type"::"Own Sales");
        PostedInvoice.SetRange("AQ Number", AQNumber);
        if not SameAQSales.IsEmpty() or not SalesHeader.IsEmpty() or not PostedInvoice.IsEmpty() then begin
            AlreadyCreated := true;
            exit;
        end;
        SalesHeader.Reset();

        // STEP 1: CUSTOMER MATCHING
        Customer.Reset();
        Customer.SetRange(Name, NormalSales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                NormalSales."Agency Name",
                AQNumber);

        // STEP 2: ITEM MATCHING BY PNR
        Item.Reset();
        Item.SetRange(Description, NormalSales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                NormalSales.PNR,
                AQNumber);

        // STEP 3: EXISTING UNIT PRICE CALCULATION
        UnitPriceValue :=
            NormalSales."Base Fare" +
            NormalSales."Other Charges";

        // STEP 4: PASSENGER FILTERING
        Passenger.Reset();

        Passenger.SetCurrentKey(
            "Ref No./AQ Number",
            PNR,
            "SL No.");

        Passenger.SetRange(
            "Ref No./AQ Number",
            AQNumber);

        Passenger.SetRange(
            PNR,
            NormalSales.PNR);

        // STEP 5: CREATE SALES INVOICE HEADER
        SalesHeader.Init();

        SalesHeader."Document Type" :=
            SalesHeader."Document Type"::Invoice;

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
            NormalSales."Agency ID";

        SalesHeader."Sales Type" :=
            SalesHeader."Sales Type"::"Own Sales";

        SalesHeader.Modify(true);

        // STEP 6: CREATE PASSENGER-WISE LINES
        LineNo := 10000;

        if Passenger.FindSet() then begin
            repeat
                CreateSalesInvoiceLine(
                    SalesHeader,
                    NormalSales,
                    Item,
                    Passenger."Passenger Name",
                    LineNo,
                    1,
                    UnitPriceValue);

                LineNo += 10000;

            until Passenger.Next() = 0;
        end else begin
            // Existing fallback behavior
            CreateSalesInvoiceLine(
                SalesHeader,
                NormalSales,
                Item,
                NormalSales.Passenger,
                LineNo,
                NormalSales.Pax,
                UnitPriceValue);
        end;

        // STEP 7: UPDATE NORMAL SALES
        NormalSales."Select" := false;
        NormalSales."Sales Invoice Created" := true;

        NormalSales.Modify(true);
    end;

    procedure WasAlreadyCreated(): Boolean
    begin
        exit(AlreadyCreated);
    end;

    local procedure CreateSalesInvoiceLine(
        var SalesHeader: Record "Sales Header";
        var NormalSales: Record "Normal Sales";
        var Item: Record Item;
        PassengerName: Text[100];
        LineNo: Integer;
        LineQuantity: Decimal;
        UnitPriceValue: Decimal)
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

        // Item Mapping
        SalesLine.Validate(
            Type,
            SalesLine.Type::Item);

        SalesLine.Validate(
            "No.",
            Item."No.");

        // PNR as Description
        SalesLine.Description :=
            NormalSales.PNR;

        // Flight Type before price validation
        SalesLine.Validate(
            FlightType,
            NormalSales.Type);

        // Passenger-wise Quantity
        SalesLine.Validate(
            Quantity,
            LineQuantity);

        // Original Base Fare
        SalesLine.BaseFare :=
            Format(NormalSales."Base Fare");

        // Numeric fare per passenger, available to the Tax Engine before price validation.
        SalesLine."AIRIQ GST Base Fare" := NormalSales."Base Fare";

        // EXISTING UNIT PRICE MAPPING
        SalesLine.Validate(
            "Unit Price",
            UnitPriceValue);

        // Travel Details
        SalesLine."Travel Date" :=
            NormalSales."Travel Date";

        SalesLine.Sector :=
            NormalSales.Sector;

        // Other Charges
        SalesLine."Other Charges" :=
            NormalSales."Other Charges";

        // Custom CGST, SGST, IGST mapping removed.
        // Standard BC Tax Engine handles GST separately.

        // Individual Passenger Name
        SalesLine."Passenger Name" :=
            PassengerName;

        SalesLine.Modify(true);
    end;

    var
        AlreadyCreated: Boolean;
}
