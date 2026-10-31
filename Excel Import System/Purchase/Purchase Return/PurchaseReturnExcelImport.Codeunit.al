
codeunit 50332 "Purchase Return Excel Import"
{
    trigger OnRun()
    begin
        ImportFromExcel();
    end;

    procedure ImportFromExcel()
    var
        PurchaseReturn: Record "Purchase Return";
        CheckPurchaseReturn: Record "Purchase Return";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UploadInStream: InStream;
        FileName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        PNRValue: Text;
        CellValue: Text;
        ImportedCount: Integer;
        SkippedCount: Integer;
    begin
        if not UploadIntoStream(
            'Select Purchase Return Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            UploadInStream)
        then
            exit;

        // Open Excel workbook
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        TempExcelBuffer.OpenBookStream(
            UploadInStream,
            'Purchase Return');

        TempExcelBuffer.ReadSheet();

        // Find last Excel row
        TempExcelBuffer.Reset();

        if TempExcelBuffer.FindLast() then
            LastRowNo := TempExcelBuffer."Row No."
        else
            LastRowNo := 0;

        // Start from Row 2 because Row 1 contains headers
        for RowNo := 2 to LastRowNo do begin

            // Column 10: PNR
            PNRValue := UpperCase(
                DelChr(
                    GetCellValue(TempExcelBuffer, RowNo, 10),
                    '=',
                    ' '));

            // Skip blank PNR
            if PNRValue = '' then begin
                SkippedCount += 1;
                continue;
            end;

            // Check PNR length
            if StrLen(PNRValue) > MaxStrLen(PurchaseReturn.PNR) then
                Error(
                    'PNR %1 at Excel row %2 exceeds maximum length of %3 characters.',
                    PNRValue,
                    RowNo,
                    MaxStrLen(PurchaseReturn.PNR));

            // Check duplicate PNR
            CheckPurchaseReturn.Reset();
            CheckPurchaseReturn.SetRange(PNR, PNRValue);

            if CheckPurchaseReturn.FindFirst() then begin
                SkippedCount += 1;
                continue;
            end;

            PurchaseReturn.Init();

            // Column 1: Serial No.
            // Not imported. Table OnInsert generates Serial No.

            // Column 2: Entry Date (DateTime)
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 2);
            if CellValue <> '' then
                PurchaseReturn."Entry Date" :=
                    ParseExcelDateTime(CellValue);

            // Column 3: Purchase Date (DateTime)
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 3);
            if CellValue <> '' then
                PurchaseReturn."Purchase Date" :=
                    ParseExcelDateTime(CellValue);

            // Column 4: Voucher Number
            PurchaseReturn."Voucher Number" := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 4),
                1,
                MaxStrLen(PurchaseReturn."Voucher Number"));

            // Column 5: Airline
            PurchaseReturn.Airline := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 5),
                1,
                MaxStrLen(PurchaseReturn.Airline));

            // Column 6: Airline ID
            PurchaseReturn."Airline ID" := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 6),
                1,
                MaxStrLen(PurchaseReturn."Airline ID"));

            // Column 7: Country
            PurchaseReturn.Country := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 7),
                1,
                MaxStrLen(PurchaseReturn.Country));

            // Column 8: Type
            PurchaseReturn.Type := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 8),
                1,
                MaxStrLen(PurchaseReturn.Type));

            // Column 9: Sector
            PurchaseReturn.Sector := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 9),
                1,
                MaxStrLen(PurchaseReturn.Sector));

            // Column 10: PNR
            PurchaseReturn.PNR := PNRValue;

            // Column 11: Reference
            PurchaseReturn.Reference := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 11),
                1,
                MaxStrLen(PurchaseReturn.Reference));

            // Column 12: Narration
            PurchaseReturn.Narration := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 12),
                1,
                MaxStrLen(PurchaseReturn.Narration));

            // Column 13: Pax
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 13);
            if CellValue <> '' then
                EvaluateInteger(
                    CellValue,
                    RowNo,
                    'Pax',
                    PurchaseReturn.Pax);

            // Column 14: Base Fare
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 14);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'Base Fare',
                    PurchaseReturn."Base Fare");

            // Column 15: Others
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 15);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'Others',
                    PurchaseReturn.Others);

            // Column 16: Rate
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 16);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'Rate',
                    PurchaseReturn.Rate);

            // Column 17: Discount
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 17);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'Discount',
                    PurchaseReturn.Discount);

            // Column 18: XXLN Charges
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 18);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'XXLN Charges',
                    PurchaseReturn."XXLN Charges");

            // Column 19: Amount
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 19);
            if CellValue <> '' then
                EvaluateDecimal(
                    CellValue,
                    RowNo,
                    'Amount',
                    PurchaseReturn.Amount);

            // Column 20: Travel Date (DateTime)
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 20);
            if CellValue <> '' then
                PurchaseReturn."Travel Date" :=
                    ParseExcelDateTime(CellValue);

            // Column 21: Departure Time (Time)
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 21);
            if CellValue <> '' then
                PurchaseReturn."Departure Time" :=
                    ParseExcelTime(CellValue);

            // Column 22: Arrival Time (Time)
            CellValue := GetCellValue(TempExcelBuffer, RowNo, 22);
            if CellValue <> '' then
                PurchaseReturn."Arrival Time" :=
                    ParseExcelTime(CellValue);

            // Column 23: Flight No.
            PurchaseReturn."Flight No." := CopyStr(
                GetCellValue(TempExcelBuffer, RowNo, 23),
                1,
                MaxStrLen(PurchaseReturn."Flight No."));

            // Column 24: Cost Revision (Option)
            CellValue := UpperCase(
                DelChr(
                    GetCellValue(TempExcelBuffer, RowNo, 24),
                    '<>',
                    ' '));

            case CellValue of
                'YES':
                    PurchaseReturn."Cost Revision" :=
                        PurchaseReturn."Cost Revision"::Yes;

                'NO':
                    PurchaseReturn."Cost Revision" :=
                        PurchaseReturn."Cost Revision"::No;

                '':
                    ;

                else
                    Error(
                        'Invalid Cost Revision "%1" at Excel row %2. Only Yes or No is allowed.',
                        CellValue,
                        RowNo);
            end;

            // Insert record and generate Serial No. through Table OnInsert
            PurchaseReturn.Insert(true);

            ImportedCount += 1;
        end;

        Message(
            'Purchase Return Excel Import Completed.\Imported: %1\Skipped: %2',
            ImportedCount,
            SkippedCount);
    end;


    // ---------------------------------------------------------
    // GET EXCEL CELL VALUE
    // ---------------------------------------------------------

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


    // ---------------------------------------------------------
    // DATETIME PARSER
    // Expected format: 20.10.2026 19:18
    // ---------------------------------------------------------

    local procedure ParseExcelDateTime(DateTimeText: Text): DateTime
    var
        SeparatorPosition: Integer;
        DatePart: Text;
        TimePart: Text;
        ParsedDate: Date;
        ParsedTime: Time;
    begin
        DateTimeText := DelChr(DateTimeText, '<>', ' ');

        if DateTimeText = '' then
            exit(0DT);

        SeparatorPosition := StrPos(DateTimeText, ' ');

        if SeparatorPosition = 0 then begin
            DatePart := DateTimeText;
            TimePart := '00:00';
        end else begin
            DatePart := CopyStr(
                DateTimeText,
                1,
                SeparatorPosition - 1);

            TimePart := DelChr(
                CopyStr(
                    DateTimeText,
                    SeparatorPosition + 1),
                '<',
                ' ');
        end;

        ParsedDate := ParseExcelDate(DatePart);
        ParsedTime := ParseExcelTime(TimePart);

        exit(CreateDateTime(ParsedDate, ParsedTime));
    end;


    // ---------------------------------------------------------
    // DATE PARSER
    // Expected format: DD.MM.YYYY
    // Also supports DD-MM-YYYY and DD/MM/YYYY
    // ---------------------------------------------------------

    local procedure ParseExcelDate(DateText: Text): Date
    var
        DateParts: List of [Text];
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        ParsedDate: Date;
    begin
        DateText := ConvertStr(DateText, './', '--');

        DateParts := DateText.Split('-');

        if DateParts.Count() <> 3 then
            Error(
                'Invalid date format "%1". Expected DD.MM.YYYY.',
                DateText);

        if not Evaluate(DayNo, DateParts.Get(1)) then
            Error('Invalid day in date: %1', DateText);

        if not Evaluate(MonthNo, DateParts.Get(2)) then
            Error('Invalid month in date: %1', DateText);

        if not Evaluate(YearNo, DateParts.Get(3)) then
            Error('Invalid year in date: %1', DateText);

        if not TryCreateDate(
            DayNo,
            MonthNo,
            YearNo,
            ParsedDate)
        then
            Error('Invalid date value: %1', DateText);

        exit(ParsedDate);
    end;


    [TryFunction]
    local procedure TryCreateDate(
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        var ParsedDate: Date)
    begin
        ParsedDate := DMY2Date(
            DayNo,
            MonthNo,
            YearNo);
    end;


    // ---------------------------------------------------------
    // TIME PARSER
    // Expected format: 19:48
    // Also supports 19:48:00
    // ---------------------------------------------------------

    local procedure ParseExcelTime(TimeText: Text): Time
    var
        TimeParts: List of [Text];
        HourNo: Integer;
        MinuteNo: Integer;
        SecondNo: Integer;
        ParsedTime: Time;
    begin
        TimeText := DelChr(TimeText, '<>', ' ');

        if TimeText = '' then
            exit(0T);

        TimeParts := TimeText.Split(':');

        if (TimeParts.Count() < 2) or
           (TimeParts.Count() > 3)
        then
            Error(
                'Invalid time format "%1". Expected HH:MM.',
                TimeText);

        if not Evaluate(HourNo, TimeParts.Get(1)) then
            Error('Invalid hour in time: %1', TimeText);

        if not Evaluate(MinuteNo, TimeParts.Get(2)) then
            Error('Invalid minute in time: %1', TimeText);

        if TimeParts.Count() = 3 then begin
            if not Evaluate(SecondNo, TimeParts.Get(3)) then
                Error('Invalid second in time: %1', TimeText);
        end else
            SecondNo := 0;

        if (HourNo < 0) or (HourNo > 23) or
           (MinuteNo < 0) or (MinuteNo > 59) or
           (SecondNo < 0) or (SecondNo > 59)
        then
            Error('Invalid time value: %1', TimeText);

        // Convert text into Business Central Time
        if TimeParts.Count() = 2 then
            TimeText := TimeText + ':00';

        if not Evaluate(ParsedTime, TimeText) then
            Error('Unable to convert time: %1', TimeText);

        exit(ParsedTime);
    end;


    // ---------------------------------------------------------
    // INTEGER PARSER
    // ---------------------------------------------------------

    local procedure EvaluateInteger(
        CellValue: Text;
        RowNo: Integer;
        FieldCaption: Text;
        var IntegerValue: Integer)
    begin
        if not Evaluate(IntegerValue, CellValue) then
            Error(
                'Invalid %1 value "%2" at Excel row %3.',
                FieldCaption,
                CellValue,
                RowNo);
    end;


    // ---------------------------------------------------------
    // DECIMAL PARSER
    // ---------------------------------------------------------

    local procedure EvaluateDecimal(
        CellValue: Text;
        RowNo: Integer;
        FieldCaption: Text;
        var DecimalValue: Decimal)
    begin
        if not Evaluate(DecimalValue, CellValue) then
            Error(
                'Invalid %1 value "%2" at Excel row %3.',
                FieldCaption,
                CellValue,
                RowNo);
    end;
}
