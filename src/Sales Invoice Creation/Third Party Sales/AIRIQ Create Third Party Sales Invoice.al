codeunit 50437 "Third Party Sales Invoice"
{
    procedure CreateThirdPartySalesInvoice(
        var ThirdPartySales: Record "Third-Party Supplier Sales")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Third Party Passenger Name";
        PassengerNames: TextBuilder;
        AQNumber: Integer;
    begin
        AQNumber := ThirdPartySales."Ref No./AQ Number";

        if ThirdPartySales."Sales Invoice Created" then
            Error(
                'Sales Invoice has already been created for AQ Number %1.',
                AQNumber);

        if AQNumber = 0 then
            Error('AQ Number is required.');

        // Customer matching by Agency Name
        Customer.Reset();
        Customer.SetRange(Name, ThirdPartySales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                ThirdPartySales."Agency Name",
                AQNumber);

        // Item matching by Item Description = PNR
        Item.Reset();
        Item.SetRange(Description, ThirdPartySales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                ThirdPartySales.PNR,
                AQNumber);

        // Get passenger names by AQ Number + PNR
        Passenger.Reset();
        Passenger.SetRange("Ref No./AQ Number", AQNumber);
        Passenger.SetRange(PNR, ThirdPartySales.PNR);

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
        SalesHeader."Agency ID" := ThirdPartySales."Agency ID";
        SalesHeader."Sales Type" :=
            SalesHeader."Sales Type"::"Third Party Sales";

        SalesHeader.Modify(true);

        // Create Sales Invoice Line
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;

        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Description := ThirdPartySales.PNR;
        SalesLine.Validate(Quantity, ThirdPartySales.Pax);
        SalesLine.Validate("Unit Price", ThirdPartySales."Rate");

        SalesLine."Travel Date" := ThirdPartySales."Travel Date";
        SalesLine.Sector := ThirdPartySales.Sector;
        SalesLine.FlightType := ThirdPartySales.Type;
        SalesLine."Passenger Name" := PassengerNames.ToText();

        SalesLine.Modify(true);

        // Update source Third Party Sales record
        ThirdPartySales."Select" := false;
        ThirdPartySales."Sales Invoice Created" := true;
        ThirdPartySales.Modify(true);

        Message(
            'Sales Invoice %1 created successfully for AQ Number %2.',
            SalesHeader."No.",
            AQNumber);
    end;
}
