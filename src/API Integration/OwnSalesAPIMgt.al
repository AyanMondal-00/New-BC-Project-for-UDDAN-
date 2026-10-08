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
        i: Integer;
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
        for i := 0 to DataArray.Count() - 1
             do begin
            DataArray.Get(i, Token);
            RowObject := Token.AsObject();

            // Insert into Normal Sales
            NormalSales.Init();
            if not RowObject.Get('EntryDateTime', Token) then
                Error('EntryDateTime was not found in API response.');

            NormalSales.Validate(
                "Date",
                Token.AsValue().AsDateTime()
            );
            // Get RefNo
            if not RowObject.Get('RefNo', Token) then
                Error('RefNo was not found in API response.');

            NormalSales.Validate(
                "Ref No./AQ Number",
                Token.AsValue().AsInteger()
            );

            // Get Bill No.
            if not RowObject.Get('BillNo', Token) then
                Error('BillNo was not found in API response.');

            NormalSales.Validate(
                "Invoice Number",
                Token.AsValue().AsText()
            );

            // Get PNR
            if not RowObject.Get('PNR', Token) then
                Error('PNR was not found in API response.');

            NormalSales.Validate(
                "PNR",
                Token.AsValue().AsText()
            );

            // Get Agency ID
            if not RowObject.Get('AgencyID', Token) then
                Error('AgencyID was not found in API response.');

            NormalSales.Validate(
                "Agency ID",
                Format(Token.AsValue().AsInteger())
            );

            // Get Agency Name
            if not RowObject.Get('AgencyName', Token) then
                Error('AgencyName was not found in API response.');

            NormalSales.Validate(
                "Agency Name",
                Token.AsValue().AsText()
            );

            // Get Pax
            if not RowObject.Get('Pax', Token) then
                Error('Pax was not found in API response.');

            NormalSales.Validate(
                "Pax",
                Token.AsValue().AsInteger()
            );
            // Get Sector 
            if not RowObject.Get('Sector', Token) then
                Error('Sector was not found in API response.');

            NormalSales.Validate(
            "Sector",
            Token.AsValue().AsText()
        );
            // Get Travel Date
            if not RowObject.Get('TravelDate', Token) then
                Error('TravelDate was not found in API response.');
            NormalSales.Validate(
                "Travel Date",
                Token.AsValue().AsDateTime()
            );
            //Get Type 
            if not RowObject.Get('Type', Token) then
                Error('Type was not found in API response.');
            NormalSales.Validate(
            "Type",
            Token.AsValue().AsText()
        );

            // Insert record
            NormalSales.Insert(true);
        end;

        Message('Successfully imported %1 records.', DataArray.Count());
    end;
}