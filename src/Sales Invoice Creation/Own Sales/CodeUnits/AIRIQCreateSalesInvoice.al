codeunit 50426 "AIRIQ Create Sales Invoice"
{
    procedure CreateOwnSalesInvoice(var NormalSales: Record "Normal Sales")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Own Sales Passenger Name";
        PassengerNames: TextBuilder;
        AQNumber: Integer;
    begin
        AQNumber := NormalSales."Ref No./AQ Number";

        if NormalSales."Sales Invoice Created" then
            Error(
                'Sales Invoice has already been created for AQ Number %1.',
                AQNumber);

        if AQNumber = 0 then
            Error('AQ Number is required.');

        // Customer matching by Agency Name
        Customer.Reset();
        Customer.SetRange(Name, NormalSales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                NormalSales."Agency Name",
                AQNumber);

        // Item matching by Item Description = PNR
        Item.Reset();
        Item.SetRange(Description, NormalSales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                NormalSales.PNR,
                AQNumber);

        // Get passenger names by AQ Number + PNR
        Passenger.Reset();
        Passenger.SetRange("Ref No./AQ Number", AQNumber);
        Passenger.SetRange(PNR, NormalSales.PNR);

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
        SalesHeader."Agency ID" := NormalSales."Agency ID";
        SalesHeader."Sales Type" := SalesHeader."Sales Type"::"Own Sales";

        SalesHeader.Modify(true);

        // Create Sales Invoice Line
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;

        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Description := NormalSales.PNR;
        SalesLine.Validate(Quantity, NormalSales.Pax);
        SalesLine.Validate("Unit Price", NormalSales."Base Fare");

        SalesLine."Travel Date" := NormalSales."Travel Date";
        SalesLine.Sector := NormalSales.Sector;
        SalesLine."Other Charges" := NormalSales."Other Charges";
        SalesLine.CGST := NormalSales.CGST;
        SalesLine.SGST := NormalSales.SGST;
        SalesLine.IGST := NormalSales.IGST;
        SalesLine."Passenger Name" := PassengerNames.ToText();

        SalesLine.Modify(true);

        // Update source Sales record
        NormalSales."Select" := false;
        NormalSales."Sales Invoice Created" := true;
        NormalSales.Modify(true);

        Message(
            'Sales Invoice %1 created successfully for AQ Number %2.',
            SalesHeader."No.",
            AQNumber);
    end;
}