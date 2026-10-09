
codeunit 50420 "Own Sales API Mgt."
{
    procedure ImportOneNormalSale()
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        RecordCount: Integer;
        ImportedCount: Integer;
        SkippedCount: Integer;
        RefNoValue: Integer;
        ResponseText: Text;
        SkippedRefNos: Text;
        RootObject: JsonObject;
        DataArray: JsonArray;
        RowObject: JsonObject;
        Token: JsonToken;
        i: Integer;
        NormalSales: Record "Normal Sales";
        ExistingNormalSales: Record "Normal Sales";
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
        if not Client.Send(Request, Response) then
            Error(
                'Unable to connect to API.\URL: %1',
                APIUrl
            );

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

        if DataArray.Count() = 0 then begin
            Message('No sales data was returned by the API.');
            exit;
        end;

        // Process maximum first 5 records
        RecordCount := DataArray.Count();
        if RecordCount > 6 then
            RecordCount := 6;

        for i := 0 to RecordCount - 1 do begin
            DataArray.Get(i, Token);
            RowObject := Token.AsObject();

            // Get RefNo
            if not RowObject.Get('RefNo', Token) then
                Error('RefNo was not found in API response.');

            RefNoValue := Token.AsValue().AsInteger();

            // Check whether Ref No. already exists
            ExistingNormalSales.Reset();
            ExistingNormalSales.SetRange(
                "Ref No./AQ Number",
                RefNoValue
            );

            if ExistingNormalSales.FindFirst() then begin
                // Skip duplicate record
                SkippedCount += 1;

                if SkippedRefNos <> '' then
                    SkippedRefNos += ', ';

                SkippedRefNos += Format(RefNoValue);
            end else begin
                // Clear previous record values and primary key
                Clear(NormalSales);
                NormalSales.Reset();
                NormalSales.Init();

                // Set Ref No.
                NormalSales.Validate(
                    "Ref No./AQ Number",
                    RefNoValue
                );

                // Get EntryDateTime
                if not RowObject.Get('EntryDateTime', Token) then
                    Error('EntryDateTime was not found in API response.');

                NormalSales.Validate(
                    "Date",
                    Token.AsValue().AsDateTime()
                );

                // Get BillNo
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
                    PNR,
                    Token.AsValue().AsText()
                );

                // Get AgencyID
                if not RowObject.Get('AgencyID', Token) then
                    Error('AgencyID was not found in API response.');

                NormalSales.Validate(
                    "Agency ID",
                    Format(Token.AsValue().AsInteger())
                );

                // Get AgencyName
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
                    Pax,
                    Token.AsValue().AsInteger()
                );

                // Get Sector
                if not RowObject.Get('Sector', Token) then
                    Error('Sector was not found in API response.');

                NormalSales.Validate(
                    Sector,
                    Token.AsValue().AsText()
                );

                // Get TravelDate
                if not RowObject.Get('TravelDate', Token) then
                    Error('TravelDate was not found in API response.');

                NormalSales.Validate(
                    "Travel Date",
                    Token.AsValue().AsDateTime()
                );

                // Get Type
                if not RowObject.Get('Type', Token) then
                    Error('Type was not found in API response.');

                NormalSales.Validate(
                    Type,
                    Token.AsValue().AsText()
                );

                // Insert new record
                NormalSales.Insert(true);
                ImportedCount += 1;
            end;
        end;

        // Final summary
        if SkippedCount > 0 then
            Message(
                'Import completed.\' +
                'Imported: %1\' +
                'Skipped: %2\' +
                'Skipped Ref No./AQ Number: %3',
                ImportedCount,
                SkippedCount,
                SkippedRefNos
            )
        else
            Message(
                'Import completed successfully.\' +
                'Imported: %1\' +
                'Skipped: 0',
                ImportedCount
            );
    end;
}
