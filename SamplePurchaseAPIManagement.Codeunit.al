codeunit 50320 "Sample Purchase API Management"
{
    procedure TestAPIConnection()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Url: Text;
        ResponseText: Text;
    begin
        Url := 'https://raw.githubusercontent.com/AyanMondal-00/Gst-API/refs/heads/main/uddan.json';

        if not Client.Get(Url, Response) then
            Error('Unable to connect to the API.');

        if not Response.IsSuccessStatusCode() then
            Error(
                'API request failed. Status Code: %1',
                Response.HttpStatusCode());

        if not Response.Content.ReadAs(ResponseText) then
            Error('Unable to read the API response content.');

        Message(
            'API connection successful.\Response:\%1',
            ResponseText);
    end;

    procedure ImportFromAPI()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JsonText: Text;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        SamplePurchase: Record "Sample Purchase";
        ExistingSamplePurchase: Record "Sample Purchase";
        Url: Text;
        PnrVal: Code[20];
        ImportedCount: Integer;
        SkippedCount: Integer;
    begin
        Url := 'https://raw.githubusercontent.com/AyanMondal-00/Gst-API/refs/heads/main/uddan.json';

        if not Client.Get(Url, Response) then
            Error('Unable to connect to the API.');

        if not Response.IsSuccessStatusCode() then
            Error(
                'API request failed. Status Code: %1',
                Response.HttpStatusCode());

        Response.Content.ReadAs(JsonText);

        if not JsonArray.ReadFrom(JsonText) then
            Error('Invalid JSON response.');

        ImportedCount := 0;
        SkippedCount := 0;

        foreach JsonToken in JsonArray do begin
            JsonObject := JsonToken.AsObject();

            PnrVal := CopyStr(GetJsonText(JsonObject, 'pnr'), 1, MaxStrLen(PnrVal));

            ExistingSamplePurchase.Reset();
            ExistingSamplePurchase.SetRange(PNR, PnrVal);
            if (PnrVal <> '') and ExistingSamplePurchase.FindFirst() then
                SkippedCount += 1
            else begin
                Clear(SamplePurchase);
                SamplePurchase.Init();

                SamplePurchase."Purchase Date" :=
                    GetJsonDate(JsonObject, 'purchaseDate');

                SamplePurchase."Entry Date" :=
                    GetJsonDate(JsonObject, 'entryDate');

                SamplePurchase.Airline :=
                    GetJsonText(JsonObject, 'airline');

                SamplePurchase."Supplier ID" :=
                    GetJsonText(JsonObject, 'supplierId');

                SamplePurchase.PNR := PnrVal;

                SamplePurchase."Total Pax" :=
                    GetJsonInteger(JsonObject, 'totalPax');

                SamplePurchase."Travel Date" :=
                    GetJsonDate(JsonObject, 'travelDate');

                SamplePurchase.Sector :=
                    GetJsonText(JsonObject, 'sector');

                SamplePurchase.Rate :=
                    GetJsonDecimal(JsonObject, 'rate');

                SamplePurchase."Base Fare" :=
                    GetJsonDecimal(JsonObject, 'baseFare');

                SamplePurchase."Other Charges" :=
                    GetJsonDecimal(JsonObject, 'otherCharges');

                SamplePurchase."Total Amount" :=
                    GetJsonDecimal(JsonObject, 'totalAmount');

                SamplePurchase.Type :=
                    GetJsonOption(JsonObject, 'type');

                SamplePurchase.Insert(true);
                ImportedCount += 1;
            end;
        end;

        Message('%1 purchase record(s) imported successfully. %2 duplicate record(s) skipped.', ImportedCount, SkippedCount);
    end;

    local procedure GetJsonText(JsonObject: JsonObject; KeyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull() then
                exit(JsonToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetJsonInteger(JsonObject: JsonObject; KeyName: Text): Integer
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull() then
                exit(JsonToken.AsValue().AsInteger());
        exit(0);
    end;

    local procedure GetJsonDecimal(JsonObject: JsonObject; KeyName: Text): Decimal
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull() then
                exit(JsonToken.AsValue().AsDecimal());
        exit(0);
    end;

    local procedure GetJsonDate(JsonObject: JsonObject; KeyName: Text): Date
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull() then
                exit(JsonToken.AsValue().AsDate());
        exit(0D);
    end;

    local procedure GetJsonOption(JsonObject: JsonObject; KeyName: Text): Option
    var
        JsonToken: JsonToken;
        ValueText: Text;
    begin
        if JsonObject.Get(KeyName, JsonToken) then
            if not JsonToken.AsValue().IsNull() then begin
                ValueText := JsonToken.AsValue().AsText();
                if ValueText = 'International' then
                    exit(1);
            end;
        exit(0);
    end;
}