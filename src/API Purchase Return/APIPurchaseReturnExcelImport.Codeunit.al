
codeunit 50488 "API Purchase Return Exl Import"
{
    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        PurchaseReturn: Record "API Purchase Return";
        ExistingReturn: Record "API Purchase Return";
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        InStr: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        PNRValue: Text;
    begin
        // Upload Excel File
        FileName := FileManagement.BLOBImportWithFilter(
            TempBlob,
            'Select API Purchase Return Excel',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            'xlsx');

        if FileName = '' then
            exit;

        // No hardcoded worksheet name.
        // User can select any worksheet.
        TempBlob.CreateInStream(InStr);
        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);

        if SheetName = '' then
            exit;

        // Recreate stream before reading workbook
        TempBlob.CreateInStream(InStr);

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();

        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();
        ExcelBuffer.CloseBook();

        // Find last row
        ExcelBuffer.Reset();

        if not ExcelBuffer.FindLast() then
            Error('The selected Excel file is empty.');

        LastRowNo := ExcelBuffer."Row No.";

        if LastRowNo < 2 then
            Error('No data rows found in Excel.');

        ValidateHeaders(ExcelBuffer);

        ImportedCount := 0;

        for RowNo := 2 to LastRowNo do begin

            // Column M = PNR
            PNRValue := GetCellValue(
                ExcelBuffer, RowNo, 13);

            if not IsBlankRow(ExcelBuffer, RowNo) then begin

                if PNRValue = '' then
                    Error(
                        'Row %1: PNR cannot be blank.',
                        RowNo);

                // Duplicate Check by PNR only
                ExistingReturn.Reset();
                ExistingReturn.SetRange(PNR, PNRValue);

                if ExistingReturn.FindFirst() then
                    Error(
                        'Row %1: Duplicate PNR %2 already exists. Serial No.: %3.',
                        RowNo,
                        PNRValue,
                        ExistingReturn."Serial No.");

                PurchaseReturn.Init();

                // A - Select
                PurchaseReturn."Select" := false;

                // B - Invoice Created
                PurchaseReturn.
                    "Third Party Purchase Return Inv Created" := false;

                // C - Serial No.
                // Generated automatically by Table OnInsert

                // D - Entry Date
                PurchaseReturn."Entry Date" :=
                    GetDateTimeValue(
                        ExcelBuffer, RowNo, 4);

                // E - Refund Date
                PurchaseReturn."Refund Date" :=
                    GetDateTimeValue(
                        ExcelBuffer, RowNo, 5);

                // F - Bill No.
                PurchaseReturn."Bill No." :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 6),
                        1, 50);

                // G - Invoice No.
                PurchaseReturn."Invoice No." :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 7),
                        1, 50);

                // H - Return No.
                PurchaseReturn."Return No." :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 8),
                        1, 50);

                // I - Airline
                PurchaseReturn."Airline" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 9),
                        1, 100);

                // J - Country
                PurchaseReturn."Country" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 10),
                        1, 100);

                // K - Type
                PurchaseReturn."Type" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 11),
                        1, 50);

                // L - Sector
                PurchaseReturn."Sector" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 12),
                        1, 100);

                // M - PNR
                PurchaseReturn.Validate(
                    PNR,
                    CopyStr(PNRValue, 1, 50));

                // N - Narration
                PurchaseReturn."Narration" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 14),
                        1, 250);

                // O - Pax
                PurchaseReturn."Pax" :=
                    CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 15),
                        1, 50);

                // P - Rate
                PurchaseReturn."Rate" :=
                    GetDecimalValue(
                        ExcelBuffer, RowNo, 16);

                // Q - COST VALUE
                PurchaseReturn."Cost Value" :=
                    GetDecimalValue(
                        ExcelBuffer, RowNo, 17);

                // R - Cancellation Charges
                PurchaseReturn."Cancellation Charges" :=
                    GetDecimalValue(
                        ExcelBuffer, RowNo, 18);

                // S - Amount
                PurchaseReturn."Amount" :=
                    GetDecimalValue(
                        ExcelBuffer, RowNo, 19);

                // T - Travel Date
                PurchaseReturn."Travel Date" :=
                    GetDateTimeValue(
                        ExcelBuffer, RowNo, 20);

                // Table OnInsert generates Serial No.
                PurchaseReturn.Insert(true);

                ImportedCount += 1;
            end;
        end;

        Message(
            'API Purchase Return Import Completed Successfully.\Imported Records: %1',
            ImportedCount);
    end;

    local procedure GetCellValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColumnNo) then
            exit(
                DelChr(
                    ExcelBuffer."Cell Value as Text",
                    '<>',
                    ' '));

        exit('');
    end;

    local procedure GetDecimalValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Decimal
    var
        CellText: Text;
        DecimalValue: Decimal;
    begin
        CellText := GetCellValue(
            ExcelBuffer, RowNo, ColumnNo);

        if CellText = '' then
            exit(0);

        if Evaluate(DecimalValue, CellText) then
            exit(DecimalValue);

        // Remove thousand separators
        CellText := DelChr(CellText, '=', ',');

        if Evaluate(DecimalValue, CellText, 9) then
            exit(DecimalValue);

        Error(
            'Row %1, Column %2: Invalid decimal value %3.',
            RowNo,
            ColumnNo,
            CellText);
    end;

    local procedure GetDateTimeValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): DateTime
    var
        CellText: Text;
        ParsedDateTime: DateTime;
        ParsedDate: Date;
        ExcelSerial: Decimal;
        SerialDays: Integer;
        Milliseconds: Integer;
        TimePart: Time;
    begin
        CellText := GetCellValue(
            ExcelBuffer, RowNo, ColumnNo);

        if CellText = '' then
            exit(0DT);

        // Try standard DateTime
        if Evaluate(ParsedDateTime, CellText) then
            exit(ParsedDateTime);

        // Try Date only
        if Evaluate(ParsedDate, CellText) then
            exit(
                CreateDateTime(
                    ParsedDate,
                    000000T));

        // Try XML format
        if Evaluate(ParsedDateTime, CellText, 9) then
            exit(ParsedDateTime);

        if Evaluate(ParsedDate, CellText, 9) then
            exit(
                CreateDateTime(
                    ParsedDate,
                    000000T));

        // Excel numeric date serial
        if Evaluate(ExcelSerial, CellText, 9) then begin

            SerialDays := Round(
                ExcelSerial, 1, '<');

            Milliseconds := Round(
                (ExcelSerial - SerialDays) * 86400000,
                1, '=');

            if Milliseconds >= 86400000 then begin
                SerialDays += 1;
                Milliseconds := 0;
            end;

            ParsedDate :=
                DMY2Date(30, 12, 1899) + SerialDays;

            TimePart := 000000T + Milliseconds;

            exit(
                CreateDateTime(
                    ParsedDate,
                    TimePart));
        end;

        Error(
            'Row %1, Column %2: Invalid DateTime value %3.',
            RowNo,
            ColumnNo,
            CellText);
    end;

    local procedure IsBlankRow(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer): Boolean
    var
        ColumnNo: Integer;
    begin
        for ColumnNo := 4 to 20 do
            if GetCellValue(
                ExcelBuffer, RowNo, ColumnNo) <> ''
            then
                exit(false);

        exit(true);
    end;

    local procedure ValidateHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    begin
        CheckHeader(ExcelBuffer, 1, 'Select');

        CheckHeader(
            ExcelBuffer, 2,
            'Third Party Purchase Return Invoice Created');

        CheckHeader(ExcelBuffer, 3, 'Serial No.');
        CheckHeader(ExcelBuffer, 4, 'Entry Date');
        CheckHeader(ExcelBuffer, 5, 'Refund Date');
        CheckHeader(ExcelBuffer, 6, 'Bill No.');
        CheckHeader(ExcelBuffer, 7, 'Invoice No.');
        CheckHeader(ExcelBuffer, 8, 'Return No.');
        CheckHeader(ExcelBuffer, 9, 'Airline');
        CheckHeader(ExcelBuffer, 10, 'Country');
        CheckHeader(ExcelBuffer, 11, 'Type');
        CheckHeader(ExcelBuffer, 12, 'Sector');
        CheckHeader(ExcelBuffer, 13, 'PNR');
        CheckHeader(ExcelBuffer, 14, 'Narration');
        CheckHeader(ExcelBuffer, 15, 'Pax');
        CheckHeader(ExcelBuffer, 16, 'Rate');
        CheckHeader(ExcelBuffer, 17, 'COST VALUE');
        CheckHeader(
            ExcelBuffer, 18,
            'Cancellation Charges');
        CheckHeader(ExcelBuffer, 19, 'Amount');
        CheckHeader(ExcelBuffer, 20, 'Travel Date');
    end;

    local procedure CheckHeader(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        ColumnNo: Integer;
        ExpectedHeader: Text)
    var
        ActualHeader: Text;
    begin
        ActualHeader := GetCellValue(
            ExcelBuffer, 1, ColumnNo);

        if UpperCase(ActualHeader) <>
           UpperCase(ExpectedHeader)
        then
            Error(
                'Invalid Excel Header at Column %1.\Expected: %2\Found: %3',
                ColumnNo,
                ExpectedHeader,
                ActualHeader);
    end;
}
