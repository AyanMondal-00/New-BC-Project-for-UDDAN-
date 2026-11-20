
codeunit 50437 "Third Party Sales Invoice"
{
    procedure CreateThirdPartySalesInvoice(var ThirdPartySales: Record "Third-Party Supplier Sales")
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Item: Record Item;
        Passenger: Record "Third Party Passenger Name";
        PostedInvoice: Record "Sales Invoice Header";
        NoSeries: Codeunit "No. Series";
        AQNumber: Integer;
        LineNo: Integer;
    begin
        if ThirdPartySales."Sales Invoice Created" then
            Error('Sales Invoice has already been created for AQ Number %1.', ThirdPartySales."Ref No./AQ Number");

        if (ThirdPartySales."Ref No./AQ Number" = 0) then
            Error('AQ Number is required.');
        if ThirdPartySales.Pax <= 0 then
            Error('Pax must be greater than zero for AQ Number %1.', ThirdPartySales."Ref No./AQ Number");

        AQNumber := ThirdPartySales."Ref No./AQ Number";
        Customer.SetRange(Name, ThirdPartySales."Agency Name");
        if not Customer.FindFirst() then
            Error('Customer %1 was not found for AQ Number %2.', ThirdPartySales."Agency Name", AQNumber);

        Item.SetRange(Description, ThirdPartySales.PNR);
        if not Item.FindFirst() then
            Error('Item with Description %1 was not found for AQ Number %2.', ThirdPartySales.PNR, AQNumber);

        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetRange("Sales Type", SalesHeader."Sales Type"::"Third Party Sales");
        SalesHeader.SetRange("AQ Number", AQNumber);
        if not SalesHeader.IsEmpty() then
            Error('A Third Party Sales Invoice already exists for AQ Number %1.', AQNumber);
        SalesHeader.Reset();

        // Third Party Sales Invoice numbering is separate from TP-SALES staging numbering.
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."No. Series" := 'THIRD-PARTY';
        SalesHeader."No." := NoSeries.GetNextNo(SalesHeader."No. Series");
        SalesHeader.Insert(true);

        SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
        SalesHeader.Validate("Document Date", Today());
        SalesHeader.Validate("Location Code", 'SILIGURI');
        SalesHeader."AQ Number" := AQNumber;
        SalesHeader."Agency ID" := ThirdPartySales."Agency ID";
        SalesHeader."Sales Type" := SalesHeader."Sales Type"::"Third Party Sales";
        SalesHeader.Modify(true);

        Passenger.Reset();
        Passenger.SetCurrentKey("Ref No./AQ Number", PNR, "SL No.");
        Passenger.SetRange("Ref No./AQ Number", AQNumber);
        Passenger.SetRange(PNR, ThirdPartySales.PNR);

        LineNo := 10000;
        if Passenger.FindSet() then begin
            repeat
                CreateThirdPartySalesInvoiceLine(SalesHeader, ThirdPartySales, Item, Passenger."Passenger Name", LineNo, 1);
                LineNo += 10000;
            until Passenger.Next() = 0;
        end else
            CreateThirdPartySalesInvoiceLine(SalesHeader, ThirdPartySales, Item, ThirdPartySales.Passenger, LineNo, ThirdPartySales.Pax);

        ThirdPartySales."Select" := false;
        ThirdPartySales."Sales Invoice Created" := true;
        ThirdPartySales.Modify(true);

        Message('Sales Invoice %1 created successfully for AQ Number %2.', SalesHeader."No.", AQNumber);
    end;

    local procedure CreateThirdPartySalesInvoiceLine(
        var SalesHeader: Record "Sales Header";
        var ThirdPartySales: Record "Third-Party Supplier Sales";
        var Item: Record Item;
        PassengerName: Text[100];
        LineNo: Integer;
        LineQuantity: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := LineNo;
        SalesLine.Insert(true);

        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Description := ThirdPartySales.PNR;

        // Do not call the custom FlightType OnValidate GST calculation.
        SalesLine.FlightType := ThirdPartySales.Type;
        SalesLine.Validate(Quantity, LineQuantity);
        SalesLine.Validate("Unit Price", ThirdPartySales.Rate);

        // Clear item-derived GST classification on this invoice line only.
        SalesLine.Validate("GST Group Code", '');
        SalesLine.Validate("HSN/SAC Code", '');

        SalesLine."Travel Date" := ThirdPartySales."Travel Date";
        SalesLine.Sector := ThirdPartySales.Sector;
        SalesLine."Passenger Name" := PassengerName;

        // Do not map BaseFare, Other Charges or AIRIQ GST Base Fare.
        SalesLine.Modify(true);
    end;
}
