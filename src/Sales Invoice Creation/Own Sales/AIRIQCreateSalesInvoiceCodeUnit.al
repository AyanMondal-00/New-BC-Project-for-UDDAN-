
codeunit 50426 "AIRIQ Create Sales Invoice"
{
    TableNo = "Normal Sales";

    trigger OnRun()
    begin
        CreateOwnSalesInvoice(Rec);
    end;

    procedure CreateOwnSalesInvoice(var NormalSales: Record "Normal Sales")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Own Sales Passenger Name";
        AQNumber: Integer;
        LineNo: Integer;
    begin
        AQNumber := NormalSales."Ref No./AQ Number";

        if NormalSales."Sales Invoice Created" then
            Error(
                'Sales Invoice has already been created for AQ Number %1.',
                AQNumber);

        if AQNumber = 0 then
            Error('AQ Number is required.');

        // Customer Matching
        Customer.Reset();
        Customer.SetRange(Name, NormalSales."Agency Name");

        if not Customer.FindFirst() then
            Error(
                'Customer %1 was not found for AQ Number %2.',
                NormalSales."Agency Name",
                AQNumber);

        // Item Matching by PNR
        Item.Reset();
        Item.SetRange(Description, NormalSales.PNR);

        if not Item.FindFirst() then
            Error(
                'Item with Description %1 was not found for AQ Number %2.',
                NormalSales.PNR,
                AQNumber);

        // Passenger Filtering
        Passenger.Reset();
        Passenger.SetRange("Ref No./AQ Number", AQNumber);
        Passenger.SetRange(PNR, NormalSales.PNR);

        // Create Sales Invoice Header
        SalesHeader.Init();
        SalesHeader."Document Type" :=
            SalesHeader."Document Type"::Invoice;
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Document Date", Today());

        // Automatically Set Header Location Code
        SalesHeader.Validate("Location Code", 'SILIGURI');

        SalesHeader."AQ Number" := AQNumber;
        SalesHeader."Agency ID" := NormalSales."Agency ID";
        SalesHeader."Sales Type" :=
            SalesHeader."Sales Type"::"Own Sales";

        SalesHeader.Modify(true);

        // Passenger Found
        if Passenger.FindSet() then begin
            LineNo := 10000;

            repeat
                SalesLine.Init();
                SalesLine."Document Type" := SalesHeader."Document Type";
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine."Line No." := LineNo;
                SalesLine.Insert(true);

                SalesLine.Validate(Type, SalesLine.Type::Item);
                SalesLine.Validate("No.", Item."No.");

                SalesLine.Description := NormalSales.PNR;

                SalesLine.Validate(Quantity, 1);

                // Store Original Base Fare
                SalesLine.BaseFare :=
                    Format(NormalSales."Base Fare");

                // Unit Price Excl. VAT = Base Fare * 5%
                SalesLine.Validate(
                    "Unit Price",
                    NormalSales."Base Fare" * 0.05);

                SalesLine."Travel Date" := NormalSales."Travel Date";
                SalesLine.Sector := NormalSales.Sector;
                SalesLine.FlightType := NormalSales.Type;

                SalesLine."Other Charges" := NormalSales."Other Charges";
                SalesLine.CGST := NormalSales.CGST;
                SalesLine.SGST := NormalSales.SGST;
                SalesLine.IGST := NormalSales.IGST;

                SalesLine."Passenger Name" :=
                    Passenger."Passenger Name";

                SalesLine.Modify(true);

                LineNo += 10000;

            until Passenger.Next() = 0;

        end else begin

            // No Passenger Found
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := 10000;
            SalesLine.Insert(true);

            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", Item."No.");

            SalesLine.Description := NormalSales.PNR;

            SalesLine.Validate(Quantity, NormalSales.Pax);

            // Store Original Base Fare
            SalesLine.BaseFare :=
                Format(NormalSales."Base Fare");

            // Unit Price Excl. VAT = Base Fare * 5%
            SalesLine.Validate(
                "Unit Price",
                NormalSales."Base Fare" * 0.05);

            SalesLine."Travel Date" := NormalSales."Travel Date";
            SalesLine.Sector := NormalSales.Sector;
            SalesLine.FlightType := NormalSales.Type;

            SalesLine."Other Charges" := NormalSales."Other Charges";
            SalesLine.CGST := NormalSales.CGST;
            SalesLine.SGST := NormalSales.SGST;
            SalesLine.IGST := NormalSales.IGST;

            SalesLine."Passenger Name" := NormalSales.Passenger;

            SalesLine.Modify(true);
        end;

        // Update Normal Sales Record
        NormalSales."Select" := false;
        NormalSales."Sales Invoice Created" := true;
        NormalSales.Modify(true);
    end;
}
