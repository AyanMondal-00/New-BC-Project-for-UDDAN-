codeunit 50431 "AIRIQ Posted Sales Invoice Mgt"
{
    Permissions =
        tabledata "Sales Invoice Header" = m,
        tabledata "Sales Invoice Line" = m;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvHeaderInsert', '', false, false)]
    local procedure OnAfterSalesInvHeaderInsert(
        var SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        CommitIsSuppressed: Boolean)
    begin
        SalesInvHeader."AQ Number" := SalesHeader."AQ Number";
        SalesInvHeader."Agency ID" := SalesHeader."Agency ID";
        SalesInvHeader."Sales Type" := SalesHeader."Sales Type";
        SalesInvHeader.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure OnAfterSalesInvLineInsert(
        var SalesInvLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        SalesInvHeader: Record "Sales Invoice Header")
    begin
        SalesInvLine."Travel Date" := SalesLine."Travel Date";
        SalesInvLine.Sector := SalesLine.Sector;
        SalesInvLine.FlightType := SalesLine.FlightType;
        SalesInvLine."Other Charges" := SalesLine."Other Charges";
        SalesInvLine.CGST := SalesLine.CGST;
        SalesInvLine.SGST := SalesLine.SGST;
        SalesInvLine.IGST := SalesLine.IGST;
        SalesInvLine."Passenger Name" := SalesLine."Passenger Name";
        SalesInvLine.Modify(true);
    end;
}