
codeunit 50330 "Sample Purchase Excel Import"
{
    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        SamplePurchase: Record "Sample Purchase";
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        SkippedCount: Integer;
        PurchaseDateColumn: Integer;
        EntryDateColumn: Integer;
        AirlineColumn: Integer;
        SupplierIDColumn: Integer;
        PNRColumn: Integer;
        TotalPaxColumn: Integer;
        TravelDateColumn: Integer;
        SectorColumn: Integer;
        RateColumn: Integer;
        BaseFareColumn: Integer;
        OtherChargesColumn: Integer;
        TotalAmountColumn: Integer;
        TypeColumn: Integer;
        PNRValue: Text;
    begin
        if not UploadIntoStream(
            'Select Sample Purchase Excel File',
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

        PurchaseDateColumn := GetHeaderColumn(TempExcelBuffer, 'Purchase Date');
        EntryDateColumn := GetHeaderColumn(TempExcelBuffer, 'Entry Date');
        AirlineColumn := GetHeaderColumn(TempExcelBuffer, 'Airline');
        SupplierIDColumn := GetHeaderColumn(TempExcelBuffer, 'Supplier ID');
        PNRColumn := GetHeaderColumn(TempExcelBuffer, 'PNR');
        TotalPaxColumn := GetHeaderColumn(TempExcelBuffer, 'Total Pax');
        TravelDateColumn := GetHeaderColumn(TempExcelBuffer, 'Travel Date');
        SectorColumn := GetHeaderColumn(TempExcelBuffer, 'Sector');
        RateColumn := GetHeaderColumn(TempExcelBuffer, 'Rate');
        BaseFareColumn := GetHeaderColumn(TempExcelBuffer, 'Base Fare');
        OtherChargesColumn := GetHeaderColumn(TempExcelBuffer, 'Other Charges');
        TotalAmountColumn := GetHeaderColumn(TempExcelBuffer, 'Total Amount');
        TypeColumn := GetHeaderColumn(TempExcelBuffer, 'Type');

        for RowNo := 2 to LastRowNo do begin
            PNRValue := DelChr(
                GetCellValue(TempExcelBuffer, RowNo, PNRColumn),
                '<>', ' ');

            if PNRValue <> '' then begin
                SamplePurchase.Init();

                SamplePurchase.Validate(
                    "Purchase Date",
                    GetDateTimeValue(
                        GetCellValue(TempExcelBuffer, RowNo, PurchaseDateColumn)));

                SamplePurchase.Validate(
                    "Entry Date",
                    GetDateTimeValue(
                        GetCellValue(TempExcelBuffer, RowNo, EntryDateColumn)));

                SamplePurchase.Validate(
                    Airline,
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, AirlineColumn), 1, 100));

                SamplePurchase.Validate(
                    "Supplier ID",
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, SupplierIDColumn), 1, 20));

                SamplePurchase.Validate(PNR, CopyStr(PNRValue, 1, 10));

                SamplePurchase.Validate(
                    "Total Pax",
                    GetIntegerValue(
                        GetCellValue(TempExcelBuffer, RowNo, TotalPaxColumn)));

                SamplePurchase.Validate(
                    "Travel Date",
                    GetDateTimeValue(
                        GetCellValue(TempExcelBuffer, RowNo, TravelDateColumn)));

                SamplePurchase.Validate(
                    Sector,
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, SectorColumn), 1, 200));

                SamplePurchase.Validate(
                    Rate,
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, RateColumn)));

                SamplePurchase.Validate(
                    "Base Fare",
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, BaseFareColumn)));

                SamplePurchase.Validate(
                    "Other Charges",
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, OtherChargesColumn)));

                SamplePurchase.Validate(
                    "Total Amount",
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, TotalAmountColumn)));

                SamplePurchase.Validate(
                    Type,
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, TypeColumn), 1, 50));

                SamplePurchase.Insert(true);
                ImportedCount += 1;
            end else
                SkippedCount += 1;
        end;

        Message(
            'Sample Purchase Excel import completed.\Imported: %1\Skipped (blank PNR): %2',
            ImportedCount,
            SkippedCount);
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

    local procedure GetIntegerValue(ValueText: Text): Integer
    var
        CleanText: Text;
        DecVal: Decimal;
        IntVal: Integer;
    begin
        CleanText := DelChr(ValueText, '<>', ' ');
        CleanText := DelChr(CleanText, '=', ',');

        if CleanText = '' then
            exit(0);

        if Evaluate(IntVal, CleanText) then
            exit(IntVal);

        if Evaluate(DecVal, CleanText) then
            exit(Round(DecVal, 1, '='));

        exit(0);
    end;

    local procedure GetDecimalValue(ValueText: Text): Decimal
    var
        CleanText: Text;
        DecVal: Decimal;
    begin
        CleanText := DelChr(ValueText, '<>', ' ');
        CleanText := DelChr(CleanText, '=', ',');

        if CleanText = '' then
            exit(0);

        if Evaluate(DecVal, CleanText) then
            exit(DecVal);

        exit(0);
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
    begin
        CleanText := DelChr(ValueText, '<>', ' ');

        if CleanText = '' then
            exit(0DT);

        // 1. Standard DateTime value.
        if Evaluate(DateTimeValue, CleanText) then
            exit(DateTimeValue);

        // 2. Date-only value.
        if Evaluate(DateValue, CleanText) then
            exit(CreateDateTime(DateValue, 0T));

        // 3. Excel serial date/time value.
        if Evaluate(ExcelSerial, CleanText) then begin
            if ExcelSerial < 1 then
                Error(
                    'The Excel cell contains only a time or an invalid date: %1. Enter the complete date and time.',
                    CleanText);

            WholeDays := Round(ExcelSerial, 1, '<');
            BaseDate := DMY2Date(30, 12, 1899);
            DateValue := BaseDate + WholeDays;

            Milliseconds := Round(
                (ExcelSerial - WholeDays) * 86400000,
                1,
                '=');

            exit(CreateDateTime(DateValue, 0T) + Milliseconds);
        end;

        // 4. Text date/time: 28-09-2026 19:30
        SeparatorPosition := StrPos(CleanText, ' ');

        if SeparatorPosition > 0 then begin
            DatePart := CopyStr(CleanText, 1, SeparatorPosition - 1);
            TimePart := CopyStr(CleanText, SeparatorPosition + 1);

            DatePart := DatePart.Replace('/', '-');
            DateParts := DatePart.Split('-');

            if DateParts.Count = 3 then begin
                Clear(DayNo);
                Clear(MonthNo);
                Clear(YearNo);

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

                if (YearNo < 1900) or
                   (MonthNo < 1) or (MonthNo > 12) or
                   (DayNo < 1) or (DayNo > 31)
                then
                    Error('Invalid date "%1".', DatePart);

                if not TryCreateDate(DayNo, MonthNo, YearNo, DateValue) then
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

        Error(
            'Cannot read Excel DateTime value "%1". Use DD-MM-YYYY HH:MM, e.g. 28-09-2026 19:30.',
            ValueText);
    end;

    local procedure TryCreateDate(
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        var DateValue: Date): Boolean
    begin
        if not Evaluate(DateValue, Format(DMY2Date(DayNo, MonthNo, YearNo))) then
            exit(false);

        exit(true);
    end;
}
