codeunit 50741 "AIRIQ PLB Posted Mapping"
{
    // Test-stage mapping only. Reads posted purchasing data; does not save PLB rows.
    procedure Fetch(FilterJson: Text): Text
    var
        Request: JsonObject;
        Response: JsonObject;
        VendorRec: Record Vendor;
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvHdr: Record "Purch. Inv. Header";
        PurchCrLine: Record "Purch. Cr. Memo Line";
        PurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        AirlineName: Text;
        PNRFilter: Text;
        Basis: Text;
        TransType: Text;
        FromBooking: Date;
        ToBooking: Date;
        FromFlown: Date;
        ToFlown: Date;
        PurchaseBase: Decimal;
        PurchaseOthers: Decimal;
        ReturnBase: Decimal;
        ReturnOthers: Decimal;
        PurchaseCount: Integer;
        ReturnCount: Integer;
        VendorCount: Integer;
        Qty: Decimal;
        StateRec: Record State;
        AirlineStateName: Text[100];
    begin
        if not Request.ReadFrom(FilterJson) then
            Error('Invalid PLB filter JSON.');

        AirlineName := GetText(Request, 'airline');
        if AirlineName = '' then
            Error('Enter the exact Airline (Vendor) name before fetching.');

        VendorRec.Reset();
        VendorRec.SetRange(Name, AirlineName);
        VendorCount := VendorRec.Count();
        if VendorCount = 0 then
            Error('No Vendor found for Airline name "%1".', AirlineName);
        if VendorCount > 1 then
            Error('Multiple Vendors found for Airline "%1". Please resolve duplicate Vendor names.', AirlineName);
        VendorRec.FindFirst();

        Basis := GetText(Request, 'basis');
        TransType := GetText(Request, 'ttype');
        PNRFilter := GetText(Request, 'ref');
        FromBooking := GetDate(Request, 'bfrom');
        ToBooking := GetDate(Request, 'bto');
        FromFlown := GetDate(Request, 'ffrom');
        ToFlown := GetDate(Request, 'fto');

        if not (Basis in ['booking', 'travel', 'combined']) then
            Error('Invalid Commission Basis: %1.', Basis);
        if not (TransType in ['purchase', 'return', 'both']) then
            Error('Invalid Transaction type: %1.', TransType);
        CheckDateRange(FromBooking, ToBooking, 'Booking');
        CheckDateRange(FromFlown, ToFlown, 'Flown');

        if TransType in ['purchase', 'both'] then begin
            PurchInvLine.Reset();
            PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
            if PNRFilter <> '' then
                PurchInvLine.SetRange("No.", PNRFilter);
            if PurchInvLine.FindSet() then
                repeat
                    if PurchInvHdr.Get(PurchInvLine."Document No.") then
                        if PurchInvHdr."Buy-from Vendor No." = VendorRec."No." then
                            if MatchesDates(Basis, PurchInvLine."Sample Purchase Date", PurchInvLine."Sample Travel Date", FromBooking, ToBooking, FromFlown, ToFlown) then begin
                                // Sample Purchase creates per-passenger amounts, with Quantity = Pax.
                                Qty := Abs(PurchInvLine.Quantity);
                                PurchaseBase += PurchInvLine."Sample Base Fare" * Qty;
                                PurchaseOthers += PurchInvLine."Sample Other Charges" * Qty;
                                PurchaseCount += 1;
                            end;
                until PurchInvLine.Next() = 0;
        end;

        if TransType in ['return', 'both'] then begin
            PurchCrLine.Reset();
            PurchCrLine.SetRange(Type, PurchCrLine.Type::Item);
            if PNRFilter <> '' then
                PurchCrLine.SetRange("AIRIQ PNR", PNRFilter);
            if PurchCrLine.FindSet() then
                repeat
                    if PurchCrHdr.Get(PurchCrLine."Document No.") then
                        if PurchCrHdr."Buy-from Vendor No." = VendorRec."No." then
                            if MatchesDates(Basis, PurchCrHdr."AIRIQ Purchase Date", PurchCrLine."Sample Travel Date", FromBooking, ToBooking, FromFlown, ToFlown) then begin
                                // Return source provides a separate pax field; preserve that convention.
                                Qty := Abs(PurchCrLine."AIRIQ Pax");
                                ReturnBase += PurchCrLine."Sample Base Fare" * Qty;
                                ReturnOthers += PurchCrLine."Sample Other Charges" * Qty;
                                ReturnCount += 1;
                            end;
                until PurchCrLine.Next() = 0;
        end;

        Response.Add('ok', true);
        Response.Add('vendorNo', VendorRec."No.");
        Response.Add('airline', VendorRec.Name);
        // Fetch Airline State Name from Vendor State Code
        Clear(AirlineStateName);
        StateRec.Reset();

        if VendorRec."State Code" <> '' then
            if StateRec.Get(VendorRec."State Code") then
                AirlineStateName := StateRec.Description;

        Response.Add('airlineState', AirlineStateName);
        Response.Add('plbPct', VendorRec.PLB);
        Response.Add('pbase', Round(PurchaseBase, 0.01));
        Response.Add('pyq', Round(PurchaseOthers, 0.01));
        Response.Add('rbase', Round(ReturnBase, 0.01));
        Response.Add('ryq', Round(ReturnOthers, 0.01));
        Response.Add('purchaseLines', PurchaseCount);
        Response.Add('returnLines', ReturnCount);
        Response.Add('message', StrSubstNo('Posted data fetched. Purchase lines: %1; Credit memo lines: %2. Base fare and Other Charges multiplied by line Pax/Quantity. Review actual figures before saving.', PurchaseCount, ReturnCount));
        Response.WriteTo(FilterJson);
        exit(FilterJson);
    end;

    local procedure GetText(Data: JsonObject; PropertyName: Text): Text
    var
        Token: JsonToken;
    begin
        if Data.Get(PropertyName, Token) then
            if Token.IsValue() then
                exit(Token.AsValue().AsText());
        exit('');
    end;

    local procedure GetDate(Data: JsonObject; PropertyName: Text): Date
    var
        DateString: Text;
        Result: Date;
    begin
        DateString := GetText(Data, PropertyName);
        if DateString = '' then
            exit(0D);
        if not Evaluate(Result, DateString, 9) then
            Error('Invalid %1: %2', PropertyName, DateString);
        exit(Result);
    end;

    local procedure CheckDateRange(FromDate: Date; ToDate: Date; LabelText: Text)
    begin
        if (FromDate <> 0D) and (ToDate <> 0D) and (FromDate > ToDate) then
            Error('%1 date From cannot be later than To.', LabelText);
    end;

    local procedure MatchesDates(Basis: Text; BookingDateTime: DateTime; FlownDateTime: DateTime; BookFrom: Date; BookTo: Date; FlownFrom: Date; FlownTo: Date): Boolean
    begin
        case Basis of
            'booking':
                exit(InRange(BookingDateTime, BookFrom, BookTo));
            'travel':
                exit(InRange(FlownDateTime, FlownFrom, FlownTo));
            'combined':
                exit(InRange(BookingDateTime, BookFrom, BookTo) and InRange(FlownDateTime, FlownFrom, FlownTo));
        end;
        exit(false);
    end;

    local procedure InRange(Value: DateTime; FromDate: Date; ToDate: Date): Boolean
    var
        ActualDate: Date;
    begin
        if Value = 0DT then
            exit(false);
        ActualDate := DT2Date(Value);
        if (FromDate <> 0D) and (ActualDate < FromDate) then
            exit(false);
        if (ToDate <> 0D) and (ActualDate > ToDate) then
            exit(false);
        exit(true);
    end;
}
