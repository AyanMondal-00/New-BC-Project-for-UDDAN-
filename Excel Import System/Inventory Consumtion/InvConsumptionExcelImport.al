
codeunit 50456 "Inv. Cons. Excel Import"
{
    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        Consumption: Record "Inventory Consumption";
        ExistingConsumption: Record "Inventory Consumption";
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        DuplicateCount: Integer;
        BlankPNRCount: Integer;
        PNRValue: Text;
        RefNoValue: Integer;
    begin
        if not UploadIntoStream(
            'Select Inventory Consumption Excel File',
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

            // Column 10 = PNR
            PNRValue :=
                UpperCase(
                    DelChr(
                        GetCellValue(TempExcelBuffer, RowNo, 10),
                        '<>',
                        ' '));

            if PNRValue = '' then begin
                if not IsRowEmpty(TempExcelBuffer, RowNo) then
                    BlankPNRCount += 1;
            end else begin

                if StrLen(PNRValue) > 10 then
                    Error(
                        'PNR exceeds 10 characters at Excel row %1: %2',
                        RowNo,
                        PNRValue);

                // Skip existing PNR.
                ExistingConsumption.Reset();
                ExistingConsumption.SetRange(PNR, PNRValue);

                if ExistingConsumption.FindFirst() then
                    DuplicateCount += 1
                else begin
                    Clear(Consumption);
                    Consumption.Init();

                    // First 3 Excel columns are ignored.
                    Consumption.Validate(Select, false);
                    Consumption.Validate("Purchase Return Order Created", false);

                    // Column 4 = Date
                    Consumption.Validate(
                        "Date",
                        GetDateTimeValue(TempExcelBuffer, RowNo, 4));

                    // Column 5 = Invoice Number
                    Consumption.Validate(
                        "Invoice Number",
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 5), 1, 50));

                    // Column 6 = Agency ID
                    Consumption.Validate(
                        "Agency ID",
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 6), 1, 30));

                    // Column 7 = Agency Name
                    Consumption.Validate(
                        "Agency Name",
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 7), 1, 100));

                    // Column 8 = Supplier Name
                    Consumption.Validate(
                        "Supplier Name",
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 8), 1, 100));

                    // Column 9 = Ref No./AQ Number
                    if not Evaluate(
                        RefNoValue,
                        GetCellValue(TempExcelBuffer, RowNo, 9))
                    then
                        Error(
                            'Invalid Ref No./AQ Number at Excel row %1.',
                            RowNo);

                    Consumption.Validate("Ref No./AQ Number", RefNoValue);

                    // Column 10 = PNR
                    Consumption.Validate(
                        PNR,
                        CopyStr(PNRValue, 1, 10));

                    // Column 11 = Pax
                    Consumption.Validate(
                        Pax,
                        GetIntegerValue(
                            GetCellValue(TempExcelBuffer, RowNo, 11),
                            RowNo,
                            'Pax'));

                    // Column 12 = Travel Date
                    Consumption.Validate(
                        "Travel Date",
                        GetDateTimeValue(TempExcelBuffer, RowNo, 12));

                    // Column 13 = Sector
                    Consumption.Validate(
                        Sector,
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 13), 1, 200));

                    // Column 14 = Type
                    Consumption.Validate(
                        Type,
                        CopyStr(GetCellValue(TempExcelBuffer, RowNo, 14), 1, 50));

                    // Column 15 = Base Fare
                    Consumption.Validate(
                        "Base Fare",
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 15),
                            RowNo,
                            'Base Fare'));

                    // Column 16 = Other Charges
                    Consumption.Validate(
                        "Other Charges",
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 16),
                            RowNo,
                            'Other Charges'));

                    // Column 17 = Taxable Basis
                    Consumption.Validate(
                        "Taxable Basis",
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 17),
                            RowNo,
                            'Taxable Basis'));

                    // Column 18 = CGST
                    Consumption.Validate(
                        CGST,
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 18),
                            RowNo,
                            'CGST'));

                    // Column 19 = SGST
                    Consumption.Validate(
                        SGST,
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 19),
                            RowNo,
                            'SGST'));

                    // Column 20 = IGST
                    Consumption.Validate(
                        IGST,
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 20),
                            RowNo,
                            'IGST'));

                    // Column 21 = Total Amount
                    Consumption.Validate(
                        "Total Amount",
                        GetDecimalValue(
                            GetCellValue(TempExcelBuffer, RowNo, 21),
                            RowNo,
                            'Total Amount'));

                    // Serial No. generated automatically by Table OnInsert().
                    Consumption.Insert(true);

                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Inventory Consumption Excel Import Completed.\' +
            'Imported: %1\' +
            'Skipped (Duplicate PNR): %2\' +
            'Skipped (Blank PNR): %3',
            ImportedCount,
            DuplicateCount,
            BlankPNRCount);
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

    local procedure IsRowEmpty(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer): Boolean
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 1 to 21 do
            if GetCellValue(TempExcelBuffer, RowNo, ColumnNo) <> '' then
                exit(false);

        exit(true);
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
            if not Evaluate(DecimalValue, ValueText) then
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
}
