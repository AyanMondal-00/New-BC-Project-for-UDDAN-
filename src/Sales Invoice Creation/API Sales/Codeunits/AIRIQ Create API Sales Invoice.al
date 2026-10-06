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

        // Customer matching by Agency Name
        Customer.Reset();
        Customer.SetRange(Name, APISales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                APISales."Agency Name",
                AQNumber);

        // Item matching by Item Description = PNR
        Item.Reset();
        Item.SetRange(Description, APISales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                APISales.PNR,
                AQNumber);

        // Get passenger names by AQ Number + PNR
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

        // Create Sales Invoice Header
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Document Date", Today());

        SalesHeader."AQ Number" := AQNumber;
        SalesHeader."Agency ID" := APISales."Agency ID";
        SalesHeader."Sales Type" := SalesHeader."Sales Type"::"API Sales";

        SalesHeader.Modify(true);

        // Create Sales Invoice Line
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;

        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Description := APISales.PNR;
        SalesLine.Validate(Quantity, APISales.Pax);
        SalesLine.Validate("Unit Price", APISales."Base Fare");

        SalesLine."Travel Date" := APISales."Travel Date";
        SalesLine.Sector := APISales.Sector;
        SalesLine.FlightType := APISales.Type;
        SalesLine."Other Charges" := APISales."Other Charges";
        SalesLine.CGST := APISales.CGST;
        SalesLine.SGST := APISales.SGST;
        SalesLine.IGST := APISales.IGST;
        SalesLine."Passenger Name" := PassengerNames.ToText();

        SalesLine.Modify(true);

        // Update source API Sales record
        APISales."Select" := false;
        APISales."Sales Invoice Created" := true;
        APISales.Modify(true);

        Message(
            'Sales Invoice %1 created successfully for AQ Number %2.',
            SalesHeader."No.",
            AQNumber);
    end;
}