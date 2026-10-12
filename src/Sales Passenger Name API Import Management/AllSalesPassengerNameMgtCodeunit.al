codeunit 50440 "Passenger Name Import Mgt."
{
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
