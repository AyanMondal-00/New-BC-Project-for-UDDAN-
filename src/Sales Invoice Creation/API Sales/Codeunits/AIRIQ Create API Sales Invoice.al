
codeunit 50435 "AIRIQ Create API Sales Invoice"
{
    procedure CreateAPISalesInvoice(var APISales: Record "API Sales Format")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "API Sales Passenger Name";
        PassengerNames: TextBuilder;
        AQNumber: Integer;
    begin
        AQNumber := APISales."Ref No./AQ Number";

        if APISales."Sales Invoice Created" then
            Error(
                'Sales Invoice has already been created for AQ Number %1.',
                AQNumber);

        if AQNumber = 0 then
            Error('AQ Number is required.');

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

        // STEP 3: PASSENGER NAME COLLECTION
        Passenger.Reset();
        Passenger.SetRange("Ref No./AQ Number", AQNumber);
        Passenger.SetRange(PNR, APISales.PNR);

        if Passenger.FindSet() then begin
            repeat
                if PassengerNames.Length() > 0 then
                    PassengerNames.Append(', ');

                PassengerNames.Append(Passenger."Passenger Name");
            until Passenger.Next() = 0;
        end;

        // STEP 4: CREATE SALES INVOICE HEADER
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

        SalesHeader."AQ Number" := AQNumber;
        SalesHeader."Agency ID" := APISales."Agency ID";
        SalesHeader."Sales Type" :=
            SalesHeader."Sales Type"::"API Sales";

        SalesHeader.Modify(true);

        // STEP 5: CREATE SALES INVOICE LINE
        SalesLine.Init();

        SalesLine."Document Type" :=
            SalesHeader."Document Type";

        SalesLine."Document No." :=
            SalesHeader."No.";

        SalesLine."Line No." := 10000;

        SalesLine.Insert(true);

        SalesLine.Validate(
            Type,
            SalesLine.Type::Item);

        SalesLine.Validate(
            "No.",
            Item."No.");

        // PNR DESCRIPTION
        SalesLine.Description := APISales.PNR;

        // FLIGHT TYPE BEFORE QUANTITY AND PRICE
        SalesLine.Validate(
            FlightType,
            APISales.Type);

        // EXISTING QUANTITY
        SalesLine.Validate(
            Quantity,
            APISales.Pax);

        // EXISTING UNIT PRICE
        SalesLine.Validate(
            "Unit Price",
            APISales."Rate");

        // TRAVEL DETAILS
        SalesLine."Travel Date" :=
            APISales."Travel Date";

        SalesLine.Sector := APISales.Sector;

        // PASSENGER NAMES
        SalesLine."Passenger Name" :=
            PassengerNames.ToText();

        SalesLine.Modify(true);

        // STEP 6: UPDATE API SALES
        APISales."Select" := false;
        APISales."Sales Invoice Created" := true;

        APISales.Modify(true);

        Message(
            'Sales Invoice %1 created successfully for AQ Number %2.',
            SalesHeader."No.",
            AQNumber);
    end;
}
