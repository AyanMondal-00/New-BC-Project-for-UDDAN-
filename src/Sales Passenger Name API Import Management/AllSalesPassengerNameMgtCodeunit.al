codeunit 50448 "Passenger Name Import Mgt."
{
    [TryFunction]
    procedure TryValidatePassengerRow(RowObject: JsonObject; RefNoValue: Integer; ExistingSale: Boolean; ExistingPax: Integer; ExistingPNR: Text[10])
    var
        Token: JsonToken;
        PassengersArray: JsonArray;
        PassengerToken: JsonToken;
        PassengerObject: JsonObject;
        ValueToken: JsonToken;
        ExistingPassenger: Record "Own Sales Passenger Name";
        PaxValidation: Codeunit "AIRIQ Pax Validation";
        PaxCount: Integer;
        PNRValue: Text[10];
        PassengerName: Text[100];
        PassengerID: BigInteger;
        PassengerType: Text[50];
        I: Integer;
    begin
        if RefNoValue = 0 then
            Error('Ref No./AQ Number must not be zero.');
        if not RowObject.Get('Pax', Token) then
            Error('Pax was not found in API response.');
        if not Token.IsValue() then
            Error('Invalid PAX in API response.');
        if Token.AsValue().IsNull() then
            Error('PAX must not be blank.');
        PaxCount := Token.AsValue().AsInteger();

        if not RowObject.Get('PNR', Token) then
            Error('PNR was not found in API response.');
        if not Token.IsValue() then
            Error('Invalid PNR in API response.');
        if Token.AsValue().IsNull() then
            Error('PNR must not be blank.');
        PNRValue := CopyStr(Token.AsValue().AsText(), 1, MaxStrLen(PNRValue));
        if PNRValue = '' then
            Error('PNR must not be blank.');

        if ExistingSale then begin
            if ExistingPax <> PaxCount then
                Error('API PAX %1 does not match existing staging PAX %2.', PaxCount, ExistingPax);
            if ExistingPNR <> PNRValue then
                Error('API PNR %1 does not match existing staging PNR %2.', PNRValue, ExistingPNR);
        end;

        if not RowObject.Get('Passengers', Token) then
            Error('Passengers array is missing.');
        if not Token.IsArray() then
            Error('Passengers must be an array.');
        PassengersArray := Token.AsArray();
        PaxValidation.CheckExactCount(PaxCount, PassengersArray.Count());

        for I := 0 to PassengersArray.Count() - 1 do begin
            PassengersArray.Get(I, PassengerToken);
            if not PassengerToken.IsObject() then
                Error('Invalid passenger at position %1.', I + 1);
            PassengerObject := PassengerToken.AsObject();
            Clear(PassengerName);
            Clear(PassengerID);
            Clear(PassengerType);

            // Match the existing API import mapping (including length and trimming).
            if PassengerObject.Get('ID', ValueToken) then
                if not ValueToken.AsValue().IsNull() then
                    PassengerID := ValueToken.AsValue().AsBigInteger();
            if PassengerObject.Get('Name', ValueToken) then
                if not ValueToken.AsValue().IsNull() then
                    PassengerName := DelChr(CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(PassengerName)), '<>', ' ');
            if PassengerObject.Get('Type', ValueToken) then
                if not ValueToken.AsValue().IsNull() then
                    PassengerType := DelChr(CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(PassengerType)), '<>', ' ');
            PaxValidation.CheckFields(PassengerName, PassengerID, PassengerType, I + 1);
        end;

        // Existing importer upserts by SL No. = array position + 1.
        // Do not delete, renumber, or append to incompatible existing rows.
        ExistingPassenger.SetRange("Ref No./AQ Number", RefNoValue);
        ExistingPassenger.SetRange(PNR, PNRValue);
        if ExistingPassenger.FindSet() then
            repeat
                if (ExistingPassenger."SL No." < 1) or (ExistingPassenger."SL No." > PaxCount) then
                    Error('Existing passenger SL No. %1 cannot be refreshed by API positions 1 to %2. Resolve existing passengers manually.', ExistingPassenger."SL No.", PaxCount);
            until ExistingPassenger.Next() = 0;
    end;

    procedure ImportPassengersFromRow(RowObject: JsonObject; RefNoValue: Integer; PnrValue: Text[10])
    var
        PassengersToken: JsonToken;
    begin
        if (RefNoValue = 0) or (PnrValue = '') then
            exit;

        if not RowObject.Get('Passengers', PassengersToken) then
            exit;

        if not PassengersToken.IsArray() then
            exit;

        ImportPassengersFromJsonArray(PassengersToken.AsArray(), RefNoValue, PnrValue);
    end;

    procedure ImportPassengersFromJsonArray(PassengersArray: JsonArray; RefNoValue: Integer; PnrValue: Text[10])
    var
        PassengerToken: JsonToken;
        PassengerObject: JsonObject;
        ValueToken: JsonToken;
        OwnSalesPassengerName: Record "Own Sales Passenger Name";
        i: Integer;
        SlNo: Integer;
        PassengerId: BigInteger;
        PassengerName: Text[100];
        PassengerType: Text[50];
    begin
        if (RefNoValue = 0) or (PnrValue = '') then
            exit;

        for i := 0 to PassengersArray.Count() - 1 do begin
            PassengersArray.Get(i, PassengerToken);
            if PassengerToken.IsObject() then begin
                PassengerObject := PassengerToken.AsObject();
                PassengerId := 0;
                PassengerName := '';
                PassengerType := '';

                if PassengerObject.Get('ID', ValueToken) then
                    if not ValueToken.AsValue().IsNull() then
                        PassengerId := ValueToken.AsValue().AsBigInteger();

                if PassengerObject.Get('Name', ValueToken) then
                    if not ValueToken.AsValue().IsNull() then
                        PassengerName := DelChr(CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(OwnSalesPassengerName."Passenger Name")), '<>', ' ');

                if PassengerObject.Get('Type', ValueToken) then
                    if not ValueToken.AsValue().IsNull() then
                        PassengerType := DelChr(CopyStr(ValueToken.AsValue().AsText(), 1, MaxStrLen(OwnSalesPassengerName."Type")), '<>', ' ');

                if (PassengerName <> '') or (PassengerId <> 0) then begin
                    SlNo := i + 1;

                    if not OwnSalesPassengerName.Get(RefNoValue, PnrValue, SlNo) then begin
                        Clear(OwnSalesPassengerName);
                        OwnSalesPassengerName.Init();
                        OwnSalesPassengerName."Ref No./AQ Number" := RefNoValue;
                        OwnSalesPassengerName.PNR := PnrValue;
                        OwnSalesPassengerName."SL No." := SlNo;
                        OwnSalesPassengerName."ID" := PassengerId;
                        OwnSalesPassengerName."Passenger Name" := PassengerName;
                        OwnSalesPassengerName."Type" := PassengerType;
                        OwnSalesPassengerName.Insert(true);
                    end else begin
                        OwnSalesPassengerName."ID" := PassengerId;
                        OwnSalesPassengerName."Passenger Name" := PassengerName;
                        OwnSalesPassengerName."Type" := PassengerType;
                        OwnSalesPassengerName.Modify(true);
                    end;
                end;
            end;
        end;
    end;
}
