
codeunit 50420 "Own Sales API Mgt."
{
    procedure ImportOwnSalesByDate(FromDate: Date; ToDate: Date)
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
        FromDateText: Text;
        ToDateText: Text;
    begin
        // Validate date range
        if (FromDate = 0D) or (ToDate = 0D) then
            Error('Please select both From Date and To Date.');

        if FromDate > ToDate then
            Error('From Date cannot be later than To Date.');

        // Format dates for API
        FromDateText :=
            Format(FromDate, 0, '<Year4>-<Month,2>-<Day,2>');
        ToDateText :=
            Format(ToDate, 0, '<Year4>-<Month,2>-<Day,2>');

        // Build API URL
        APIUrl := StrSubstNo(
            'https://airiqvendorapi.azurewebsites.net/api/ms_business_central/SaleDetails/OwnSale?fromDate=%1&toDate=%2',
            FromDateText,
            ToDateText
        );

        // API credentials
        Username := 'om namah shivay';
        Password := 'prince';
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

        // Parse JSON response
        if not RootObject.ReadFrom(ResponseText) then
            Error('Invalid JSON response received from API.');

        // Get data array
        if not RootObject.Get('data', Token) then
            Error('The "data" field was not found in API response.');

        DataArray := Token.AsArray();
        RecordCount := DataArray.Count();

        if RecordCount = 0 then begin
            Message(
                'No sales data was returned for %1 to %2.',
                FromDateText,
                ToDateText
            );
            exit;
        end;

        // Process all API records
        for i := 0 to RecordCount - 1 do begin
            DataArray.Get(i, Token);
            RowObject := Token.AsObject();

            // Get RefNo
            if not RowObject.Get('RefNo', Token) then
                Error('RefNo was not found in API response.');

            RefNoValue := Token.AsValue().AsInteger();

            // Check duplicate Ref No.
            ExistingNormalSales.Reset();
            ExistingNormalSales.SetRange(
                "Ref No./AQ Number",
                RefNoValue
            );

            if ExistingNormalSales.FindFirst() then begin
                // Skip existing record
                SkippedCount += 1;

                if SkippedRefNos <> '' then
                    SkippedRefNos += ', ';

                SkippedRefNos += Format(RefNoValue);
            end else begin
                // Clear previous record state
                Clear(NormalSales);
                NormalSales.Reset();
                NormalSales.Init();

                // Ref No.
                NormalSales.Validate(
                    "Ref No./AQ Number",
                    RefNoValue
                );

                // EntryDateTime
                if not RowObject.Get('EntryDateTime', Token) then
                    Error('EntryDateTime was not found in API response.');

                NormalSales.Validate(
                    "Date",
                    Token.AsValue().AsDateTime()
                );

                // BillNo
                if not RowObject.Get('BillNo', Token) then
                    Error('BillNo was not found in API response.');

                NormalSales.Validate(
                    "Invoice Number",
                    Token.AsValue().AsText()
                );

                // PNR
                if not RowObject.Get('PNR', Token) then
                    Error('PNR was not found in API response.');

                NormalSales.Validate(
                    PNR,
                    Token.AsValue().AsText()
                );

                // AgencyID
                if not RowObject.Get('AgencyID', Token) then
                    Error('AgencyID was not found in API response.');

                NormalSales.Validate(
                    "Agency ID",
                    Format(Token.AsValue().AsInteger())
                );

                // AgencyName
                if not RowObject.Get('AgencyName', Token) then
                    Error('AgencyName was not found in API response.');

                NormalSales.Validate(
                    "Agency Name",
                    Token.AsValue().AsText()
                );

                // Pax
                if not RowObject.Get('Pax', Token) then
                    Error('Pax was not found in API response.');

                NormalSales.Validate(
                    Pax,
                    Token.AsValue().AsInteger()
                );

                // Sector
                if not RowObject.Get('Sector', Token) then
                    Error('Sector was not found in API response.');

                NormalSales.Validate(
                    Sector,
                    Token.AsValue().AsText()
                );

                // TravelDate
                if not RowObject.Get('TravelDate', Token) then
                    Error('TravelDate was not found in API response.');

                NormalSales.Validate(
                    "Travel Date",
                    Token.AsValue().AsDateTime()
                );

                // Type - Text field
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
                'Import completed for %1 to %2.\' +
                'Imported: %3\' +
                'Skipped: %4\' +
                'Skipped Ref No./AQ Number: %5',
                FromDateText,
                ToDateText,
                ImportedCount,
                SkippedCount,
                SkippedRefNos
            )
        else
            Message(
                'Import completed successfully for %1 to %2.\' +
                'Imported: %3\' +
                'Skipped: 0',
                FromDateText,
                ToDateText,
                ImportedCount
            );
    end;
}
