
codeunit 50432 "Third Party Sales Excel Import"
{
    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ThirdPartySales: Record "Third-Party Supplier Sales";
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        SkippedCount: Integer;
        DateColumn: Integer;
        InvoiceNumberColumn: Integer;
        AgencyIDColumn: Integer;
        AgencyNameColumn: Integer;
        RefNoColumn: Integer;
        SelectColumn: Integer;
        SalesInvoiceCreatedColumn: Integer;
        PNRColumn: Integer;
        PassengerColumn: Integer;
        PaxColumn: Integer;
        TravelDateColumn: Integer;
        SectorColumn: Integer;
        TypeColumn: Integer;
        RateColumn: Integer;
        PNRValue: Text;
        RefNoValue: BigInteger;
    begin
        if not UploadIntoStream(
            'Select Third-Party Sales Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            UploadInStream)
        then
            exit;

        SheetName := TempExcelBuffer.SelectSheetsNameStream(UploadInStream);
        UploadInStream.ResetPosition();

        TempExcelBuffer.OpenBookStream(UploadInStream, SheetName);
        TempExcelBuffer.ReadSheet();

        TempExcelBuffer.Reset();
        if not TempExcelBuffer.FindLast() then
            Error('The selected Excel file is empty.');

        LastRowNo := TempExcelBuffer."Row No.";

        if LastRowNo < 2 then
            Error('No data rows found. Row 1 must contain the column headers.');

        DateColumn := GetHeaderColumn(TempExcelBuffer, 'Date');
        InvoiceNumberColumn := GetHeaderColumn(TempExcelBuffer, 'Invoice Number');
        AgencyIDColumn := GetHeaderColumn(TempExcelBuffer, 'Agency ID');
        AgencyNameColumn := GetHeaderColumn(TempExcelBuffer, 'Agency Name');
        RefNoColumn := GetHeaderColumn(TempExcelBuffer, 'Ref No./AQ Number');
        SelectColumn := GetHeaderColumn(TempExcelBuffer, 'Select');
        SalesInvoiceCreatedColumn := GetHeaderColumn(TempExcelBuffer, 'Sales Invoice Created');
        PNRColumn := GetHeaderColumn(TempExcelBuffer, 'PNR');
        PassengerColumn := GetHeaderColumn(TempExcelBuffer, 'View Passenger');
        PaxColumn := GetHeaderColumn(TempExcelBuffer, 'Pax');
        TravelDateColumn := GetHeaderColumn(TempExcelBuffer, 'Travel Date');
        SectorColumn := GetHeaderColumn(TempExcelBuffer, 'Sector');
        TypeColumn := GetHeaderColumn(TempExcelBuffer, 'Type');
        RateColumn := GetRateHeaderColumn(TempExcelBuffer);

        for RowNo := 2 to LastRowNo do begin
            PNRValue := DelChr(
                GetCellValue(TempExcelBuffer, RowNo, PNRColumn),
                '<>', ' ');

            if PNRValue <> '' then begin
                ThirdPartySales.Init();

                ThirdPartySales.Validate(
                    "Date",
                    GetDateTimeValue(
                        GetCellValue(TempExcelBuffer, RowNo, DateColumn)));

                ThirdPartySales.Validate(
                    "Invoice Number",
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, InvoiceNumberColumn),
                        1, 50));

                ThirdPartySales.Validate(
                    "Agency ID",
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, AgencyIDColumn),
                        1, 30));

                ThirdPartySales.Validate(
                    "Agency Name",
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, AgencyNameColumn),
                        1, 100));

                if not Evaluate(
                    RefNoValue,
                    GetCellValue(TempExcelBuffer, RowNo, RefNoColumn))
                then
                    Error(
                        'Invalid Ref No./AQ Number at Excel row %1.',
                        RowNo);

                ThirdPartySales.Validate("Ref No./AQ Number", RefNoValue);

                ThirdPartySales.Validate(
                    "Select",
                    GetBooleanValue(
                        GetCellValue(TempExcelBuffer, RowNo, SelectColumn),
                        RowNo,
                        'Select'));

                ThirdPartySales.Validate(
                    "Sales Invoice Created",
                    GetBooleanValue(
                        GetCellValue(TempExcelBuffer, RowNo, SalesInvoiceCreatedColumn),
                        RowNo,
                        'Sales Invoice Created'));

                ThirdPartySales.Validate(PNR, CopyStr(PNRValue, 1, 10));

                ThirdPartySales.Validate(
                    Passenger,
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, PassengerColumn),
                        1, 100));

                ThirdPartySales.Validate(
                    Pax,
                    GetIntegerValue(
                        GetCellValue(TempExcelBuffer, RowNo, PaxColumn),
                        RowNo,
                        'Pax'));

                ThirdPartySales.Validate(
                    "Travel Date",
                    GetDateTimeValue(
                        GetCellValue(TempExcelBuffer, RowNo, TravelDateColumn)));

                ThirdPartySales.Validate(
                    Sector,
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, SectorColumn),
                        1, 200));

                ThirdPartySales.Validate(
                    Type,
                    CopyStr(
                        GetCellValue(TempExcelBuffer, RowNo, TypeColumn),
                        1, 50));

                ThirdPartySales.Validate(
                    Rate,
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, RateColumn),
                        RowNo,
                        'Rate'));

                ThirdPartySales.Insert(true);
                ImportedCount += 1;
            end else
                SkippedCount += 1;
        end;

        Message(
            'Third-Party Sales Excel import completed.\Imported: %1\Skipped (blank PNR): %2',
            ImportedCount,
            SkippedCount);
    end;

        local procedure GetRateHeaderColumn(var TempExcelBuffer: Record "Excel Buffer" temporary): Integer
    var
        Col: Integer;
    begin
        Col := FindHeaderColumnOptional(TempExcelBuffer, 'Rate');
        if Col = 0 then
            Col := FindHeaderColumnOptional(TempExcelBuffer, 'Base Fare');
        if Col = 0 then
            Error('Excel header "Rate" or "Base Fare" was not found in row 1.');
        exit(Col);
    end;

    local procedure FindHeaderColumnOptional(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        HeaderName: Text): Integer
    var
        HeaderValue: Text;
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetRange("Row No.", 1);

        if TempExcelBuffer.FindSet() then
            repeat
                HeaderValue := UpperCase(
                    DelChr(TempExcelBuffer."Cell Value as Text", '<>', ' '));

                if HeaderValue = UpperCase(HeaderName) then
                    exit(TempExcelBuffer."Column No.");
            until TempExcelBuffer.Next() = 0;

        exit(0);
    end;

local procedure GetHeaderColumn(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        HeaderName: Text): Integer
    var
        ColumnNo: Integer;
        HeaderValue: Text;
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetRange("Row No.", 1);

        if TempExcelBuffer.FindSet() then
            repeat
                HeaderValue := UpperCase(
                    DelChr(TempExcelBuffer."Cell Value as Text", '<>', ' '));

                if HeaderValue = UpperCase(HeaderName) then
                    ColumnNo := TempExcelBuffer."Column No.";
            until TempExcelBuffer.Next() = 0;

        if ColumnNo = 0 then
            Error('Excel header "%1" was not found in row 1.', HeaderName);

        exit(ColumnNo);
    end;

    local procedure GetCellValue(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetRange("Row No.", RowNo);
        TempExcelBuffer.SetRange("Column No.", ColumnNo);

        if TempExcelBuffer.FindFirst() then
            exit(TempExcelBuffer."Cell Value as Text");

        exit('');
    end;

    local procedure GetBooleanValue(
        ValueText: Text;
        RowNo: Integer;
        FieldName: Text): Boolean
    var
        NormalizedValue: Text;
        BooleanValue: Boolean;
    begin
        NormalizedValue := UpperCase(DelChr(ValueText, '=', ' '));

        case NormalizedValue of
            'TRUE', 'YES', '1':
                exit(true);
            'FALSE', 'NO', '0', '':
                exit(false);
            else
                if Evaluate(BooleanValue, ValueText) then
                    exit(BooleanValue);

                Error(
                    'Invalid value "%1" for %2 at Excel row %3. Use TRUE/FALSE or Yes/No.',
                    ValueText, FieldName, RowNo);
        end;
    end;

    local procedure GetIntegerValue(
        ValueText: Text;
        RowNo: Integer;
        FieldName: Text): Integer
    var
        IntegerValue: Integer;
    begin
        ValueText := DelChr(ValueText, '<>', ' ');

        if ValueText = '' then
            exit(0);

        if not Evaluate(IntegerValue, ValueText) then
            Error('Invalid %1 at Excel row %2: %3', FieldName, RowNo, ValueText);

        exit(IntegerValue);
    end;

    local procedure GetDecimalValue(
        ValueText: Text;
        RowNo: Integer;
        FieldName: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        ValueText := DelChr(ValueText, '<>', ' ');

        if ValueText = '' then
            exit(0);

        if not Evaluate(DecimalValue, ValueText) then
            Error('Invalid %1 at Excel row %2: %3', FieldName, RowNo, ValueText);

        exit(DecimalValue);
    end;

    local procedure GetDateTimeValue(ValueText: Text): DateTime
    var
        DateTimeValue: DateTime;
        DateValue: Date;
        TimeValue: Time;
        ExcelSerial: Decimal;
        WholeDays: Integer;
        Milliseconds: Duration;
        BaseDate: Date;
        CleanText: Text;
        DatePart: Text;
        TimePart: Text;
        DateParts: List of [Text];
        TimeParts: List of [Text];
        SeparatorPosition: Integer;
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        HourNo: Integer;
        MinuteNo: Integer;
        SecondNo: Integer;
        ISODateText: Text;
    begin
        CleanText := DelChr(ValueText, '<>', ' ');

        if CleanText = '' then
            exit(0DT);

        // Text format: DD-MM-YYYY HH:MM
        SeparatorPosition := StrPos(CleanText, ' ');

        if SeparatorPosition > 0 then begin
            DatePart := CopyStr(CleanText, 1, SeparatorPosition - 1);
            TimePart := CopyStr(CleanText, SeparatorPosition + 1);
            DatePart := DatePart.Replace('/', '-');
            DateParts := DatePart.Split('-');

            if DateParts.Count = 3 then begin
                if StrLen(DateParts.Get(1)) = 4 then begin
                    if not Evaluate(YearNo, DateParts.Get(1)) then
                        Error('Invalid year in date "%1".', DatePart);
                    if not Evaluate(MonthNo, DateParts.Get(2)) then
                        Error('Invalid month in date "%1".', DatePart);
                    if not Evaluate(DayNo, DateParts.Get(3)) then
                        Error('Invalid day in date "%1".', DatePart);
                end else begin
                    if not Evaluate(DayNo, DateParts.Get(1)) then
                        Error('Invalid day in date "%1".', DatePart);
                    if not Evaluate(MonthNo, DateParts.Get(2)) then
                        Error('Invalid month in date "%1".', DatePart);
                    if not Evaluate(YearNo, DateParts.Get(3)) then
                        Error('Invalid year in date "%1".', DatePart);
                end;

                ISODateText :=
                    Format(YearNo) + '-' +
                    PadNumber(MonthNo) + '-' +
                    PadNumber(DayNo);

                if not Evaluate(DateValue, ISODateText, 9) then
                    Error('Invalid calendar date "%1".', DatePart);

                TimeParts := TimePart.Split(':');

                if (TimeParts.Count < 2) or (TimeParts.Count > 3) then
                    Error('Invalid time "%1". Use HH:MM or HH:MM:SS.', TimePart);

                if not Evaluate(HourNo, TimeParts.Get(1)) then
                    Error('Invalid hour in time "%1".', TimePart);
                if not Evaluate(MinuteNo, TimeParts.Get(2)) then
                    Error('Invalid minute in time "%1".', TimePart);

                Clear(SecondNo);
                if TimeParts.Count = 3 then
                    if not Evaluate(SecondNo, TimeParts.Get(3)) then
                        Error('Invalid second in time "%1".', TimePart);

                if (HourNo < 0) or (HourNo > 23) or
                   (MinuteNo < 0) or (MinuteNo > 59) or
                   (SecondNo < 0) or (SecondNo > 59)
                then
                    Error('Invalid time "%1". Use 24-hour time.', TimePart);

                TimeValue :=
                    000000T +
                    (HourNo * 3600000) +
                    (MinuteNo * 60000) +
                    (SecondNo * 1000);

                exit(CreateDateTime(DateValue, TimeValue));
            end;
        end;

        if Evaluate(DateTimeValue, CleanText) then
            exit(DateTimeValue);

        if Evaluate(DateValue, CleanText) then
            exit(CreateDateTime(DateValue, 0T));

        if Evaluate(ExcelSerial, CleanText) then begin
            if ExcelSerial < 1 then
                Error('Excel cell contains only a time or invalid date: %1.', CleanText);

            WholeDays := Round(ExcelSerial, 1, '<');
            BaseDate := DMY2Date(30, 12, 1899);
            DateValue := BaseDate + WholeDays;

            Milliseconds := Round(
                (ExcelSerial - WholeDays) * 86400000,
                1,
                '=');

            exit(CreateDateTime(DateValue, 0T) + Milliseconds);
        end;

        Error(
            'Cannot read date/time "%1". Use DD-MM-YYYY HH:MM, e.g. 28-09-2026 19:30.',
            ValueText);
    end;

    local procedure PadNumber(NumberValue: Integer): Text
    begin
        if NumberValue < 10 then
            exit('0' + Format(NumberValue));

        exit(Format(NumberValue));
    end;
}
