codeunit 50420 "Own Sales API Mgt."
{
    procedure ImportOneNormalSale()
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;

        ResponseText: Text;
        RootObject: JsonObject;
        DataArray: JsonArray;
        RowObject: JsonObject;
        Token: JsonToken;

        NormalSales: Record "Normal Sales";

        Base64Convert: Codeunit "Base64 Convert";

        APIUrl: Text;
        Username: Text;
        Password: Text;
        AuthString: Text;
    begin
        APIUrl := 'https://airiqvendorapi.azurewebsites.net/api/ms_business_central/SaleDetails/OwnSale?fromDate=2026-09-23&toDate=2026-09-24';

        Username := 'om namah shivay';
        Password := 'prince';

        // Basic Authentication
        AuthString := Username + ':' + Password;

        // Create GET request
        Request.SetRequestUri(APIUrl);
        Request.Method := 'GET';

        Request.GetHeaders(Headers);

        Headers.Add(
            'Authorization',
            'Basic ' + Base64Convert.ToBase64(AuthString)
        );

        // Send request
        if not Client.Send(Request, Response) then begin
            Error(
                'Unable to connect to API.\URL: %1',
                APIUrl
            );
        end;

        // Check response
        if not Response.IsSuccessStatusCode() then
            Error(
                'API request failed. Status Code: %1',
                Response.HttpStatusCode()
            );

        // Read response
        Response.Content().ReadAs(ResponseText);

        // Convert response to JSON
        if not RootObject.ReadFrom(ResponseText) then
            Error('Invalid JSON response received from API.');

        // Get data array
        if not RootObject.Get('data', Token) then
            Error('The "data" field was not found in API response.');

        DataArray := Token.AsArray();

        if DataArray.Count() = 0 then
            Error('No sales data was returned by the API.');

        // Get first data record
        DataArray.Get(0, Token);

        RowObject := Token.AsObject();

        // Get RefNo
        if not RowObject.Get('RefNo', Token) then
            Error('RefNo was not found in API response.');

        // Insert into Normal Sales
        NormalSales.Init();


        NormalSales.Validate(
            "Ref No./AQ Number",
            Token.AsValue().AsInteger()
        );
        NormalSales.Validate(
       "PNR",
       Token.AsValue().AsText()
   );
        NormalSales.Insert(true);

        Message(
            'Successfully imported Ref No./AQ Number: %1',
            NormalSales."Ref No./AQ Number"
        );
    end;
}