codeunit 50726 "AIRIQ TP Return Invoice Fetch"
{
    procedure Fetch(var Source: Record "Third Party Sales Return"): Boolean
    var
        PostedHeader: Record "Sales Invoice Header";
        PostedLine: Record "Sales Invoice Line";
        InvoiceQty: Decimal;
        RateTotal: Decimal;
        EffectivePax: Integer;
    begin
        // Preserve the existing manual/imported RATE when no invoice matches.
        if (Source."Bill No." = '') or (Source.PNR = '') then
            exit(false);

        PostedHeader.SetRange("Invoice Number", Source."Bill No.");
        PostedHeader.SetRange("Sales Type", PostedHeader."Sales Type"::"Third Party Sales");
        if PostedHeader.Count() <> 1 then
            exit(false);
        PostedHeader.FindFirst();
        PostedLine.SetRange("Document No.", PostedHeader."No.");
        PostedLine.SetRange(Type, PostedLine.Type::Item);
        // Third Party invoice creation explicitly sets Description to PNR.
        PostedLine.SetRange(Description, Source.PNR);
        PostedLine.SetFilter(Quantity, '>0');
        if not PostedLine.FindSet() then
            exit(false);
        repeat
            InvoiceQty += PostedLine.Quantity;
            RateTotal += PostedLine."Unit Price" * PostedLine.Quantity;
        until PostedLine.Next() = 0;
        EffectivePax := Source.PAX;
        if EffectivePax <= 0 then
            EffectivePax := 1;
        if (InvoiceQty <= 0) or (EffectivePax > InvoiceQty) then
            exit(false);
        Source.RATE := Round(RateTotal / InvoiceQty, 0.01);
        exit(true);
    end;
}
