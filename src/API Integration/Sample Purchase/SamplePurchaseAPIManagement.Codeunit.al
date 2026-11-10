
codeunit 50320 "Sample Purchase API Management"
{
    procedure ImportFromAPI()
    var
        DateDialog: Page "Sample Purchase Date Dialog";
        FromDate: Date;
        ToDate: Date;
    begin
        DateDialog.SetDates(Today, Today);

        if DateDialog.RunModal() <> Action::OK then
            exit;

        DateDialog.GetDates(FromDate, ToDate);

        ImportSamplePurchaseByDate(FromDate, ToDate);
    end;

    procedure ImportSamplePurchaseByDate(
        FromDate: Date;
        ToDate: Date)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        Base64Convert: Codeunit "Base64 Convert";
        RootObject: JsonObject;
        DataArray: JsonArray;
        RowObject: JsonObject;
        Token: JsonToken;
        SamplePurchase: Record "Sample Purchase";
        ExistingPurchase: Record "Sample Purchase";
        APIEndpoint: Text;
        APIUrl: Text;
        Username: Text;
        Password: Text;
        AuthString: Text;
        ResponseText: Text;
        FromDateText: Text;
        ToDateText: Text;
        PNRValue: Text;
        SkippedPNRs: Text;
        ImportedCount: Integer;
        SkippedCount: Integer;
        RecordCount: Integer;
        i: Integer;
    begin
        // ==========================================
        // VALIDATE DATE RANGE
        // ==========================================
        if (FromDate = 0D) or (ToDate = 0D) then
            Error('Please select both From Date and To Date.');

        if FromDate > ToDate then
            Error('From Date cannot be later than To Date.');

        FromDateText :=
            Format(FromDate, 0, '<Year4>-<Month,2>-<Day,2>');

        ToDateText :=
            Format(ToDate, 0, '<Year4>-<Month,2>-<Day,2>');

        // ==========================================
        // ORIGINAL AIRIQ API CONFIGURATION
        // ==========================================
        // Enter endpoint without date parameters.
        APIEndpoint :=
            'https://airiqvendorapi.azurewebsites.net/api/ms_business_central/PurchaseDetails';

        Username := 'om namah shivay';
        Password := 'prince';

        APIUrl := StrSubstNo(
            '%1?fromDate=%2&toDate=%3',
            APIEndpoint,
            FromDateText,
            ToDateText
        );

        AuthString := Username + ':' + Password;

        // ==========================================
        // HTTP GET WITH BASIC AUTHENTICATION
        // ==========================================
        Request.SetRequestUri(APIUrl);
        Request.Method := 'GET';

        Request.GetHeaders(Headers);
        Headers.Add(
            'Authorization',
            'Basic ' + Base64Convert.ToBase64(AuthString)
        );

        if not Client.Send(Request, Response) then
            Error('Unable to connect to Sample Purchase API.');

        if not Response.IsSuccessStatusCode() then
            Error(
                'Sample Purchase API failed. HTTP Status: %1',
                Response.HttpStatusCode()
            );

        if not Response.Content.ReadAs(ResponseText) then
            Error('Unable to read API response.');

        // ==========================================
        // PARSE API RESPONSE
        // ==========================================
        if not RootObject.ReadFrom(ResponseText) then
            Error('Invalid JSON response received.');

        if not RootObject.Get('status', Token) then
            Error('API response status is missing.');

        if not Token.AsValue().AsBoolean() then
            Error('Sample Purchase API returned failure.');

        if not RootObject.Get('data', Token) then
            Error('API response data array is missing.');

        if not Token.IsArray() then
            Error('API data must be an array.');

        DataArray := Token.AsArray();
        RecordCount := DataArray.Count();

        if RecordCount = 0 then begin
            Message(
                'No Sample Purchase records found between %1 and %2.',
                FromDateText,
                ToDateText
            );
            exit;
        end;

        // ==========================================
        // PROCESS ALL API RECORDS
        // ==========================================
        for i := 0 to RecordCount - 1 do begin
            DataArray.Get(i, Token);

            if not Token.IsObject() then
                Error('Invalid API record at row %1.', i + 1);

            RowObject := Token.AsObject();

            PNRValue :=
                UpperCase(
                    DelChr(
                        GetRequiredText(RowObject, 'PNR'),
                        '<>',
                        ' '
                    )
                );

            if PNRValue = '' then
                Error('PNR is blank at API row %1.', i + 1);

            if StrLen(PNRValue) > MaxStrLen(SamplePurchase.PNR) then
                Error(
                    'PNR %1 exceeds maximum length at row %2.',
                    PNRValue,
                    i + 1
                );

            // ======================================
            // DUPLICATE PNR CHECK
            // ======================================
            ExistingPurchase.Reset();
            ExistingPurchase.SetRange(PNR, PNRValue);

            if ExistingPurchase.FindFirst() then begin
                SkippedCount += 1;

                if SkippedPNRs <> '' then
                    SkippedPNRs += ', ';

                SkippedPNRs += PNRValue;
            end else begin
                Clear(SamplePurchase);
                SamplePurchase.Init();

                // PurchaseDate can be null
                SamplePurchase."Purchase Date" :=
                    GetOptionalDateTime(
                        RowObject,
                        'PurchaseDate'
                    );

                // EntryDate
                SamplePurchase.Validate(
                    "Entry Date",
                    GetRequiredDateTime(
                        RowObject,
                        'EntryDate'
                    )
                );

                // Airline
                SamplePurchase.Validate(
                    Airline,
                    GetRequiredText(RowObject, 'Airline')
                );

                // Supplier
                SamplePurchase.Validate(
                    "Supplier ID",
                    GetRequiredText(RowObject, 'Supplier')
                );

                // Sector
                SamplePurchase.Validate(
                    Sector,
                    GetRequiredText(RowObject, 'Sector')
                );

                // Type
                SamplePurchase.Validate(
                    Type,
                    GetRequiredText(RowObject, 'Type')
                );

                // PNR
                SamplePurchase.Validate(PNR, PNRValue);

                // Pax
                SamplePurchase.Validate(
                    "Total Pax",
                    GetRequiredInteger(RowObject, 'Pax')
                );

                // TravelDate
                SamplePurchase.Validate(
                    "Travel Date",
                    GetRequiredDateTime(
                        RowObject,
                        'TravelDate'
                    )
                );

                // ==================================
                // FINAL FINANCIAL MAPPING
                // ==================================

                // Rate = API Price
                SamplePurchase.Rate :=
                    GetRequiredDecimal(RowObject, 'Price');

                // Base Fare = API BaseFare
                SamplePurchase."Base Fare" :=
                    GetRequiredDecimal(RowObject, 'BaseFare');

                // Total Amount = API Amount
                SamplePurchase."Total Amount" :=
                    GetRequiredDecimal(RowObject, 'Amount');

                // Other Charges = Amount - BaseFare*PAX

                SamplePurchase."Other Charges" :=
                    SamplePurchase."Total Amount" -
                    (SamplePurchase."Base Fare" *
                     SamplePurchase."Total Pax");


                // ==================================
                // INSERT INTO SAMPLE PURCHASE
                // ==================================
                SamplePurchase.Insert(true);

                ImportedCount += 1;
            end;
        end;

        // ==========================================
        // IMPORT SUMMARY
        // ==========================================
        Message(
            'Sample Purchase API Import Completed.\' +
            'From Date: %1\' +
            'To Date: %2\' +
            'Total API Records: %3\' +
            'Imported: %4\' +
            'Skipped: %5\' +
            'Skipped PNRs: %6',
            FromDateText,
            ToDateText,
            RecordCount,
            ImportedCount,
            SkippedCount,
            SkippedPNRs
        );
    end;

    // ==========================================
    // JSON HELPER METHODS
    // ==========================================

    local procedure GetRequiredText(
        RowObject: JsonObject;
        KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        if not RowObject.Get(KeyName, Token) then
            Error('Missing API field: %1.', KeyName);

        if not Token.IsValue() then
            Error('Invalid API field: %1.', KeyName);

        if Token.AsValue().IsNull() then
            Error('API field %1 cannot be null.', KeyName);

        exit(Token.AsValue().AsText());
    end;

    local procedure GetRequiredInteger(
        RowObject: JsonObject;
        KeyName: Text): Integer
    var
        Token: JsonToken;
    begin
        if not RowObject.Get(KeyName, Token) then
            Error('Missing API field: %1.', KeyName);

        if not Token.IsValue() then
            Error('Invalid API field: %1.', KeyName);

        if Token.AsValue().IsNull() then
            Error('API field %1 cannot be null.', KeyName);

        exit(Token.AsValue().AsInteger());
    end;

    local procedure GetRequiredDecimal(
        RowObject: JsonObject;
        KeyName: Text): Decimal
    var
        Token: JsonToken;
    begin
        if not RowObject.Get(KeyName, Token) then
            Error('Missing API field: %1.', KeyName);

        if not Token.IsValue() then
            Error('Invalid API field: %1.', KeyName);

        if Token.AsValue().IsNull() then
            Error('API field %1 cannot be null.', KeyName);

        exit(Token.AsValue().AsDecimal());
    end;

    local procedure GetRequiredDateTime(
        RowObject: JsonObject;
        KeyName: Text): DateTime
    var
        DateTimeValue: DateTime;
        DateTimeText: Text;
    begin
        DateTimeText := GetRequiredText(RowObject, KeyName);

        if not Evaluate(DateTimeValue, DateTimeText, 9) then
            Error(
                'Invalid datetime for %1: %2.',
                KeyName,
                DateTimeText
            );

        exit(DateTimeValue);
    end;

    local procedure GetOptionalDateTime(
        RowObject: JsonObject;
        KeyName: Text): DateTime
    var
        Token: JsonToken;
    begin
        if not RowObject.Get(KeyName, Token) then
            exit(0DT);

        if not Token.IsValue() then
            Error('Invalid API field: %1.', KeyName);

        if Token.AsValue().IsNull() then
            exit(0DT);

        exit(GetRequiredDateTime(RowObject, KeyName));
    end;
}
