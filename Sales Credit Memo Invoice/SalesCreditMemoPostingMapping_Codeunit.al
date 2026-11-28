
codeunit 50719 "AIRIQ SR Posting"
{
    // =========================================
    // SALES HEADER
    // ->
    // POSTED SALES CREDIT MEMO HEADER
    // =========================================

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Sales-Post",
        'OnBeforeSalesCrMemoHeaderInsert',
        '',
        false,
        false)]
    local procedure HeaderCopy(
        var SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        var SalesHeader: Record "Sales Header";
        CommitIsSuppressed: Boolean;
        var IsHandled: Boolean;
        var SalesInvHeader: Record "Sales Invoice Header")
    begin
        // Only AIRIQ Sales Return Credit Memos.
        if SalesHeader."AIRIQ Return No." = '' then
            exit;

        if SalesHeader."AIRIQ API Return Serial" <> '' then
            SalesCrMemoHeader."AIRIQ API Return Serial" := SalesHeader."AIRIQ API Return Serial";

        if SalesHeader."AIRIQ TP Return Serial" <> '' then
            SalesCrMemoHeader."AIRIQ TP Return Serial" := SalesHeader."AIRIQ TP Return Serial";

        SalesCrMemoHeader."AIRIQ Return No." :=
            SalesHeader."AIRIQ Return No.";

        SalesCrMemoHeader."AIRIQ Return Serial" :=
            SalesHeader."AIRIQ Return Serial";

        SalesCrMemoHeader."AIRIQ Bill No." :=
            SalesHeader."AIRIQ Bill No.";

        SalesCrMemoHeader."AIRIQ Original Invoice" :=
            SalesHeader."AIRIQ Original Invoice";

        SalesCrMemoHeader."AIRIQ Entry Date" :=
            SalesHeader."AIRIQ Entry Date";

        SalesCrMemoHeader."AIRIQ Reference" :=
            SalesHeader."AIRIQ Reference";

        SalesCrMemoHeader."AIRIQ Narration" :=
            SalesHeader."AIRIQ Narration";

        SalesCrMemoHeader."AIRIQ Supplier" :=
            SalesHeader."AIRIQ Supplier";

        SalesCrMemoHeader."AIRIQ Sale Type" :=
            SalesHeader."AIRIQ Sale Type";
    end;


    // =========================================
    // SALES LINE
    // ->
    // POSTED SALES CREDIT MEMO LINE
    // =========================================

    [EventSubscriber(
        ObjectType::Codeunit,
        Codeunit::"Sales-Post",
        'OnBeforeSalesCrMemoLineInsert',
        '',
        false,
        false)]
    local procedure LineCopy(
        var SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesLine: Record "Sales Line";
        CommitIsSuppressed: Boolean;
        var IsHandled: Boolean;
        var SalesHeader: Record "Sales Header";
        var SalesShptHeader: Record "Sales Shipment Header";
        var ReturnRcptHeader: Record "Return Receipt Header";
        var PostingSalesLine: Record "Sales Line")
    begin
        if SalesHeader."AIRIQ Return No." = '' then
            exit;

        // =========================================
        // ORIGINAL LINE INFORMATION
        // =========================================

        if (SalesHeader."AIRIQ TP Return Serial" <> '') or
           (SalesHeader."AIRIQ API Return Serial" <> '') then
            SalesCrMemoLine."AIRIQ Rate" := SalesLine."AIRIQ Rate";

        SalesCrMemoLine."Travel Date" :=
            SalesLine."Travel Date";

        SalesCrMemoLine.Sector :=
            SalesLine.Sector;

        SalesCrMemoLine.FlightType :=
            SalesLine.FlightType;

        SalesCrMemoLine.BaseFare :=
            SalesLine.BaseFare;

        SalesCrMemoLine."Other Charges" :=
            SalesLine."Other Charges";

        SalesCrMemoLine."Passenger Name" :=
            SalesLine."Passenger Name";

        // =========================================
        // SALES RETURN FINANCIAL INFORMATION
        // =========================================

        SalesCrMemoLine."AIRIQ Taxable Value" :=
            SalesLine."AIRIQ Taxable Value";

        SalesCrMemoLine."AIRIQ Source CGST" :=
            SalesLine."AIRIQ Source CGST";

        SalesCrMemoLine."AIRIQ Source SGST" :=
            SalesLine."AIRIQ Source SGST";

        SalesCrMemoLine."AIRIQ Source IGST" :=
            SalesLine."AIRIQ Source IGST";

        SalesCrMemoLine."AIRIQ Sold Value" :=
            SalesLine."AIRIQ Sold Value";

        SalesCrMemoLine."AIRIQ XXLN Charges" :=
            SalesLine."AIRIQ XXLN Charges";

        SalesCrMemoLine."AIRIQ Refund Amount" :=
            SalesLine."AIRIQ Refund Amount";

        // =========================================
        // AIRIQ INFORMATION
        // =========================================

        SalesCrMemoLine."AIRIQ Country" :=
            SalesLine."AIRIQ Country";

        SalesCrMemoLine."AIRIQ State" :=
            SalesLine."AIRIQ State";

        SalesCrMemoLine."AIRIQ City" :=
            SalesLine."AIRIQ City";

        SalesCrMemoLine."AIRIQ Travel Time" :=
            SalesLine."AIRIQ Travel Time";

        SalesCrMemoLine."AIRIQ Airline" :=
            SalesLine."AIRIQ Airline";

        SalesCrMemoLine."AIRIQ Airline Code" :=
            SalesLine."AIRIQ Airline Code";

        SalesCrMemoLine."AIRIQ Reference" :=
            SalesLine."AIRIQ Reference";

        SalesCrMemoLine."AIRIQ Passenger Type" :=
            SalesLine."AIRIQ Passenger Type";

        // AIRIQ Passenger SL intentionally not copied.
    end;
}