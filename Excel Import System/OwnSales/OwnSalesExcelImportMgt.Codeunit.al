
codeunit 50430 "Own Sales Excel Import Mgt."
{
    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        NormalSales: Record "Normal Sales";
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        SkippedCount: Integer;
        PNRValue: Text;
        RefNoValue: BigInteger;
        PassengerNamesValue: Text;
    begin
        if not UploadIntoStream(
            'Select Own Sales Excel File',
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

        for RowNo := 2 to LastRowNo do begin
            PNRValue := GetCellValue(TempExcelBuffer, RowNo, 9);

            if PNRValue <> '' then begin
                Clear(NormalSales);
                NormalSales.Init();

                // Serial No. is generated automatically by table OnInsert.

                NormalSales.Validate(
                    "Date",
                    GetDateTimeValue(TempExcelBuffer, RowNo, 2));

                NormalSales.Validate(
                    "Invoice Number",
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, 3), 1, 50));

                NormalSales.Validate(
                    "Agency ID",
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, 4), 1, 30));

                NormalSales.Validate(
                    "Agency Name",
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, 5), 1, 100));

                if not Evaluate(
                    RefNoValue,
                    GetCellValue(TempExcelBuffer, RowNo, 6))
                then
                    Error('Invalid Ref No./AQ Number at Excel row %1.', RowNo);

                NormalSales.Validate("Ref No./AQ Number", RefNoValue);

                NormalSales.Validate(
                    "Select",
                    GetBooleanValue(
                        GetCellValue(TempExcelBuffer, RowNo, 7),
                        RowNo,
                        'Select'));

                NormalSales.Validate(
                    "Sales Invoice Created",
                    GetBooleanValue(
                        GetCellValue(TempExcelBuffer, RowNo, 8),
                        RowNo,
                        'Sales Invoice Created'));

                NormalSales.Validate("PNR", CopyStr(PNRValue, 1, 10));

                NormalSales.Validate(
                    Pax,
                    GetIntegerValue(
                        GetCellValue(TempExcelBuffer, RowNo, 11),
                        RowNo,
                        'Pax'));

                NormalSales.Validate(
                    "Travel Date",
                    GetDateTimeValue(TempExcelBuffer, RowNo, 12));

                NormalSales.Validate(
                    Sector,
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, 13), 1, 200));

                NormalSales.Validate(
                    Type,
                    CopyStr(GetCellValue(TempExcelBuffer, RowNo, 14), 1, 50));

                NormalSales.Validate(
                    "Base Fare",
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 15),
                        RowNo,
                        'Base Fare'));

                NormalSales.Validate(
                    "Other Charges",
                    GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 16),
                        RowNo,
                        'Other Charges'));

                NormalSales.CalculateGST();

                NormalSales.Insert(true);

                PassengerNamesValue := GetCellValue(TempExcelBuffer, RowNo, 10);

                if PassengerNamesValue <> '' then
                    ImportPassengerNames(
                        RefNoValue,
                        CopyStr(PNRValue, 1, 10),
                        PassengerNamesValue);

                ImportedCount += 1;
            end else
                SkippedCount += 1;
        end;

        Message(
            'Own Sales Excel import completed.\Imported: %1\Skipped (blank PNR): %2',
            ImportedCount,
            SkippedCount);
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

            else begin
                if Evaluate(BooleanValue, ValueText) then
                    exit(BooleanValue);

                Error(
                    'Invalid value "%1" for %2 at Excel row %3. Use TRUE/FALSE or Yes/No.',
                    ValueText,
                    FieldName,
                    RowNo);
            end;
        end;
    end;

    local procedure GetIntegerValue(
        ValueText: Text;
        RowNo: Integer;
        FieldName: Text): Integer
    var
        IntegerValue: Integer;
    begin
        if ValueText = '' then
            exit(0);

        if not Evaluate(IntegerValue, ValueText) then
            Error(
                'Invalid %1 at Excel row %2: %3',
                FieldName,
                RowNo,
                ValueText);

        exit(IntegerValue);
    end;

    local procedure GetDecimalValue(
        ValueText: Text;
        RowNo: Integer;
        FieldName: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        if ValueText = '' then
            exit(0);

        if not Evaluate(DecimalValue, ValueText, 9) then
            Error(
                'Invalid %1 at Excel row %2: %3',
                FieldName,
                RowNo,
                ValueText);

        exit(DecimalValue);
    end;

    local procedure GetDateTimeValue(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): DateTime
    var
        CellValue: Text;
        ParsedDateTime: DateTime;
        ParsedDate: Date;
        ParsedTime: Time;
    begin
        CellValue := DelChr(
            GetCellValue(TempExcelBuffer, RowNo, ColumnNo),
            '<>',
            ' ');

        if CellValue = '' then
            exit(0DT);

        // Try normal DateTime conversion.
        if Evaluate(ParsedDateTime, CellValue) then
            exit(ParsedDateTime);

        // Try conversion using regional format.
        if Evaluate(ParsedDateTime, CellValue, 9) then
            exit(ParsedDateTime);

        // Try date-only value.
        if Evaluate(ParsedDate, CellValue) then
            exit(CreateDateTime(ParsedDate, 000000T));

        // Time-only values cannot provide a complete DateTime.
        if Evaluate(ParsedTime, CellValue) then
            Error(
                'Excel row %1, column %2 contains only time: "%3". Please provide both date and time.',
                RowNo,
                ColumnNo,
                CellValue);

        Error(
            'Invalid Date/Time at Excel row %1, column %2: "%3". Please check the Excel cell format and value.',
            RowNo,
            ColumnNo,
            CellValue);
    end;

    local procedure ImportPassengerNames(
        RefNo: BigInteger;
        PNRCode: Text[10];
        NamesText: Text)
    var
        OwnSalesPassengerName: Record "Own Sales Passenger Name";
        NameList: List of [Text];
        SingleName: Text;
        SLNo: Integer;
    begin
        OwnSalesPassengerName.Reset();
        OwnSalesPassengerName.SetRange("Ref No./AQ Number", RefNo);
        OwnSalesPassengerName.SetRange("PNR", PNRCode);

        if not OwnSalesPassengerName.IsEmpty() then
            OwnSalesPassengerName.DeleteAll();

        NameList := NamesText.Split(',');

        SLNo := 1;

        foreach SingleName in NameList do begin
            SingleName := DelChr(SingleName, '<>', ' ');

            if SingleName <> '' then begin
                Clear(OwnSalesPassengerName);
                OwnSalesPassengerName.Init();

                OwnSalesPassengerName.Validate("Ref No./AQ Number", RefNo);
                OwnSalesPassengerName.Validate("PNR", PNRCode);
                OwnSalesPassengerName.Validate("SL No.", SLNo);

                OwnSalesPassengerName.Validate(
                    "Passenger Name",
                    CopyStr(SingleName, 1, 100));

                OwnSalesPassengerName.Insert(true);

                SLNo += 1;
            end;
        end;
    end;
}
