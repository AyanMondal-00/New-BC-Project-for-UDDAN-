
codeunit 50475 "TP Sales Return Excel Import"
{
    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        SalesReturn: Record "Third Party Sales Return";
        ExistingReturn: Record "Third Party Sales Return";
        UploadStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        DuplicateCount: Integer;
        SkippedCount: Integer;
        ReturnNoValue: Code[50];
        PNRValue: Text[50];
        NamesValue: Text;
        IDsValue: Text;
        TypesValue: Text;
    begin
        if not UploadIntoStream(
            'Select Third Party Sales Return Excel',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            UploadStream)
        then
            exit;

        SheetName :=
            ExcelBuffer.SelectSheetsNameStream(UploadStream);

        if SheetName = '' then
            exit;

        UploadStream.ResetPosition();

        ExcelBuffer.OpenBookStream(UploadStream, SheetName);
        ExcelBuffer.ReadSheet();

        CheckHeaders(ExcelBuffer);

        ExcelBuffer.Reset();
        ExcelBuffer.SetCurrentKey("Row No.", "Column No.");

        if not ExcelBuffer.FindLast() then
            Error('Excel file is empty.');

        LastRowNo := ExcelBuffer."Row No.";

        for RowNo := 2 to LastRowNo do begin
            if not IsBlankRow(ExcelBuffer, RowNo) then begin

                // Skip the Excel data-type instruction row.
                if not IsInstructionRow(ExcelBuffer, RowNo) then begin

                    ReturnNoValue := CopyStr(
                        GetCellValue(ExcelBuffer, RowNo, 5),
                        1, 50);

                    if ReturnNoValue = '' then
                        Error(
                            'Return No. is blank at Excel row %1.',
                            RowNo);

                    ExistingReturn.Reset();
                    ExistingReturn.SetRange(
                        "Return No.", ReturnNoValue);

                    if not ExistingReturn.IsEmpty() then
                        DuplicateCount += 1
                    else begin

                        PNRValue := CopyStr(
                            GetCellValue(ExcelBuffer, RowNo, 17),
                            1, 50);

                        if PNRValue = '' then
                            Error(
                                'PNR is blank at Excel row %1.',
                                RowNo);

                        NamesValue :=
                            GetCellValue(ExcelBuffer, RowNo, 18);

                        IDsValue :=
                            GetCellValue(ExcelBuffer, RowNo, 19);

                        TypesValue :=
                            GetCellValue(ExcelBuffer, RowNo, 20);

                        CheckPassengers(
                            NamesValue,
                            IDsValue,
                            TypesValue,
                            RowNo);

                        Clear(SalesReturn);
                        SalesReturn.Init();

                        // Column 1: Serial No. ignored.
                        // BC Table OnInsert generates it.

                        SalesReturn.Validate(
                            "Entry Date",
                            GetDateTimeValue(
                                ExcelBuffer, RowNo, 2));

                        SalesReturn.Validate(
                            "Bill No.",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 3),
                                1, 50));

                        SalesReturn.Validate(
                            "Invoice No.",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 4),
                                1, 50));

                        SalesReturn.Validate(
                            "Return No.",
                            ReturnNoValue);

                        SalesReturn.Validate(
                            "Agency ID",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 6),
                                1, 30));

                        SalesReturn.Validate(
                            "A/C Name",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 7),
                                1, 100));

                        SalesReturn.Validate(
                            Country,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 8),
                                1, 100));

                        SalesReturn.Validate(
                            State,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 9),
                                1, 100));

                        SalesReturn.Validate(
                            City,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 10),
                                1, 100));

                        SalesReturn.Validate(
                            Sector,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 11),
                                1, 200));

                        SalesReturn.Validate(
                            Type,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 12),
                                1, 50));

                        SalesReturn.Validate(
                            "Travel Date",
                            GetDateTimeValue(
                                ExcelBuffer, RowNo, 13));

                        SalesReturn.Validate(
                            "Flight Time",
                            GetTimeValue(
                                ExcelBuffer, RowNo, 14));

                        SalesReturn.Validate(
                            Airline,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 15),
                                1, 100));

                        SalesReturn.Validate(
                            "Airline Code",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 16),
                                1, 50));

                        SalesReturn.Validate(PNR, PNRValue);

                        // Columns 18-20 are passenger details.
                        // Stored in separate passenger table.

                        SalesReturn.Validate(
                            Narration,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 21),
                                1, 250));

                        SalesReturn.Validate(
                            PAX,
                            GetIntegerValue(
                                ExcelBuffer, RowNo, 22));

                        SalesReturn.Validate(
                            RATE,
                            GetDecimalValue(
                                ExcelBuffer, RowNo, 23));

                        SalesReturn.Validate(
                            "Sold Value",
                            GetDecimalValue(
                                ExcelBuffer, RowNo, 24));

                        SalesReturn.Validate(
                            "XXLN Charges",
                            GetDecimalValue(
                                ExcelBuffer, RowNo, 25));

                        SalesReturn.Validate(
                            "Refund Amount",
                            GetDecimalValue(
                                ExcelBuffer, RowNo, 26));

                        SalesReturn.Validate(
                            "Sale Type",
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 27),
                                1, 50));

                        SalesReturn.Validate(
                            Supplier,
                            CopyStr(
                                GetCellValue(ExcelBuffer, RowNo, 28),
                                1, 100));

                        SalesReturn."Select" := false;
                        SalesReturn."Sales Credit Memo Created" := false;

                        SalesReturn.Insert(true);

                        ImportPassengers(
                            ReturnNoValue,
                            PNRValue,
                            NamesValue,
                            IDsValue,
                            TypesValue);

                        ImportedCount += 1;
                    end;
                end else
                    SkippedCount += 1;
            end else
                SkippedCount += 1;
        end;

        ExcelBuffer.CloseBook();

        Message(
            'Third Party Sales Return Import Completed.\' +
            'Imported: %1\' +
            'Duplicate Return No.: %2\' +
            'Skipped Rows: %3',
            ImportedCount,
            DuplicateCount,
            SkippedCount);
    end;

    local procedure CheckHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    var
        Headers: List of [Text];
        Expected: Text;
        Actual: Text;
        ColNo: Integer;
    begin
        Headers.Add('Serial No.');
        Headers.Add('Entry Date');
        Headers.Add('Bill No.');
        Headers.Add('Invoice No.');
        Headers.Add('Return No.');
        Headers.Add('Agency ID');
        Headers.Add('A/C Name');
        Headers.Add('Country');
        Headers.Add('State');
        Headers.Add('City');
        Headers.Add('Sector');
        Headers.Add('Type');
        Headers.Add('Travel Date');
        Headers.Add('Time');
        Headers.Add('Airline');
        Headers.Add('Airline Code');
        Headers.Add('PNR');
        Headers.Add('View Passenger');
        Headers.Add('Passenger ID');
        Headers.Add('Passenger Type');
        Headers.Add('Narration');
        Headers.Add('PAX');
        Headers.Add('RATE');
        Headers.Add('Sold Value');
        Headers.Add('XXLN Charges');
        Headers.Add('Refund Amount');
        Headers.Add('Sale Type');
        Headers.Add('Supplier');

        ColNo := 0;

        foreach Expected in Headers do begin
            ColNo += 1;

            Actual := GetCellValue(
                ExcelBuffer, 1, ColNo);

            if UpperCase(DelChr(Actual, '<>', ' ')) <>
               UpperCase(DelChr(Expected, '<>', ' '))
            then
                Error(
                    'Excel header mismatch at column %1. Expected %2, found %3.',
                    ColNo, Expected, Actual);
        end;
    end;

    local procedure GetCellValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): Text
    begin
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ColNo);

        if ExcelBuffer.FindFirst() then
            exit(ExcelBuffer."Cell Value as Text");

        exit('');
    end;

    local procedure IsBlankRow(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer): Boolean
    var
        ColNo: Integer;
    begin
        for ColNo := 1 to 28 do
            if DelChr(
                GetCellValue(ExcelBuffer, RowNo, ColNo),
                '<>', ' ') <> ''
            then
                exit(false);

        exit(true);
    end;

    local procedure IsInstructionRow(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer): Boolean
    var
        FirstValue: Text;
        SecondValue: Text;
    begin
        FirstValue := LowerCase(
            GetCellValue(ExcelBuffer, RowNo, 1));

        SecondValue := LowerCase(
            GetCellValue(ExcelBuffer, RowNo, 2));

        exit(
            (StrPos(FirstValue, 'auto generate') > 0) and
            (StrPos(SecondValue, 'date time') > 0));
    end;

    local procedure GetIntegerValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): Integer
    var
        ValueText: Text;
        ResultValue: Integer;
    begin
        ValueText := GetCellValue(
            ExcelBuffer, RowNo, ColNo);

        if ValueText = '' then
            exit(0);

        if not Evaluate(ResultValue, ValueText) then
            Error(
                'Invalid integer at row %1, column %2: %3',
                RowNo, ColNo, ValueText);

        exit(ResultValue);
    end;

    local procedure GetDecimalValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): Decimal
    var
        ValueText: Text;
        ResultValue: Decimal;
    begin
        ValueText := GetCellValue(
            ExcelBuffer, RowNo, ColNo);

        if ValueText = '' then
            exit(0);

        if Evaluate(ResultValue, ValueText, 9) then
            exit(ResultValue);

        if Evaluate(ResultValue, ValueText) then
            exit(ResultValue);

        Error(
            'Invalid decimal at row %1, column %2: %3',
            RowNo, ColNo, ValueText);
    end;

    local procedure GetDateTimeValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): DateTime
    var
        ValueText: Text;
        ParsedDateTime: DateTime;
        ParsedDate: Date;
        ParsedTime: Time;
        DatePart: Text;
        TimePart: Text;
        Parts: List of [Text];
    begin
        ValueText := DelChr(
            GetCellValue(ExcelBuffer, RowNo, ColNo),
            '<>', ' ');

        if ValueText = '' then
            exit(0DT);

        // Explicit DD-MM-YYYY HH:MM parsing.
        if StrLen(ValueText) >= 16 then begin
            DatePart := CopyStr(ValueText, 1, 10);
            TimePart := CopyStr(ValueText, 12);

            if (DatePart[3] in ['-', '/', '.']) and
               (DatePart[6] in ['-', '/', '.']) then begin

                Parts := DatePart.Split('-/.');

                if Parts.Count() = 3 then
                    if TryParseDMYDateTime(
                        DatePart, TimePart, ParsedDateTime)
                    then
                        exit(ParsedDateTime);
            end;
        end;

        if Evaluate(ParsedDateTime, ValueText) then
            exit(ParsedDateTime);

        if Evaluate(ParsedDateTime, ValueText, 9) then
            exit(ParsedDateTime);

        if Evaluate(ParsedDate, ValueText) then
            exit(CreateDateTime(ParsedDate, 000000T));

        Error(
            'Invalid DateTime at Excel row %1, column %2: %3',
            RowNo, ColNo, ValueText);
    end;

    [TryFunction]
    local procedure TryParseDMYDateTime(
        DatePart: Text;
        TimePart: Text;
        var ResultDateTime: DateTime)
    var
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        ParsedDate: Date;
        ParsedTime: Time;
        NormalizedDate: Text;
    begin
        NormalizedDate :=
            ConvertStr(DatePart, './', '--');

        Evaluate(DayNo, CopyStr(NormalizedDate, 1, 2));
        Evaluate(MonthNo, CopyStr(NormalizedDate, 4, 2));
        Evaluate(YearNo, CopyStr(NormalizedDate, 7, 4));

        ParsedDate := DMY2Date(DayNo, MonthNo, YearNo);

        if not Evaluate(ParsedTime, TimePart) then
            Error('Invalid time.');

        ResultDateTime :=
            CreateDateTime(ParsedDate, ParsedTime);
    end;

    local procedure GetTimeValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): Time
    var
        ValueText: Text;
        ParsedTime: Time;
        ParsedDateTime: DateTime;
    begin
        ValueText := GetCellValue(
            ExcelBuffer, RowNo, ColNo);

        if ValueText = '' then
            exit(000000T);

        if Evaluate(ParsedTime, ValueText) then
            exit(ParsedTime);

        if Evaluate(ParsedDateTime, ValueText) then
            exit(DT2Time(ParsedDateTime));

        Error(
            'Invalid Time at Excel row %1, column %2: %3',
            RowNo, ColNo, ValueText);
    end;

    local procedure SplitValues(
        ValueText: Text): List of [Text]
    var
        Result: List of [Text];
        Parts: List of [Text];
        Part: Text;
    begin
        if DelChr(ValueText, '<>', ' ') = '' then
            exit(Result);

        Parts := ValueText.Split(',');

        foreach Part in Parts do
            Result.Add(DelChr(Part, '<>', ' '));

        exit(Result);
    end;

    local procedure CheckPassengers(
        NamesText: Text;
        IDsText: Text;
        TypesText: Text;
        RowNo: Integer)
    var
        Names: List of [Text];
        IDs: List of [Text];
        Types: List of [Text];
        NameValue: Text;
        IDValue: Text;
        TypeValue: Text;
        NumericID: BigInteger;
        I: Integer;
    begin
        Names := SplitValues(NamesText);
        IDs := SplitValues(IDsText);
        Types := SplitValues(TypesText);

        if (Names.Count() <> IDs.Count()) or
           (Names.Count() <> Types.Count()) then
            Error(
                'Passenger count mismatch at Excel row %1. Names=%2, IDs=%3, Types=%4.',
                RowNo,
                Names.Count(),
                IDs.Count(),
                Types.Count());

        for I := 1 to Names.Count() do begin
            Names.Get(I, NameValue);
            IDs.Get(I, IDValue);
            Types.Get(I, TypeValue);

            if (NameValue = '') or
               (IDValue = '') or
               (TypeValue = '') then
                Error(
                    'Blank passenger detail at row %1, passenger %2.',
                    RowNo, I);

            if StrLen(NameValue) > 100 then
                Error(
                    'Passenger Name too long at row %1.',
                    RowNo);

            if StrLen(TypeValue) > 50 then
                Error(
                    'Passenger Type too long at row %1.',
                    RowNo);

            if not Evaluate(NumericID, IDValue) then
                Error(
                    'Invalid Passenger ID %1 at row %2.',
                    IDValue, RowNo);
        end;
    end;

    local procedure ImportPassengers(
        ReturnNumber: Code[50];
        PNRNumber: Text[50];
        NamesText: Text;
        IDsText: Text;
        TypesText: Text)
    var
        Passenger: Record "TP Sales Return Passenger";
        Names: List of [Text];
        IDs: List of [Text];
        Types: List of [Text];
        NameValue: Text;
        IDValue: Text;
        TypeValue: Text;
        I: Integer;
    begin
        Names := SplitValues(NamesText);
        IDs := SplitValues(IDsText);
        Types := SplitValues(TypesText);

        if Names.Count() = 0 then
            exit;

        for I := 1 to Names.Count() do begin
            Names.Get(I, NameValue);
            IDs.Get(I, IDValue);
            Types.Get(I, TypeValue);

            Clear(Passenger);
            Passenger.Init();

            Passenger."Return No." := ReturnNumber;
            Passenger.PNR := PNRNumber;

            Passenger."Passenger Name" :=
                CopyStr(NameValue, 1, 100);

            Evaluate(Passenger.ID, IDValue);

            Passenger.Type :=
                CopyStr(TypeValue, 1, 50);

            // SL No. auto-generated by Passenger Table.
            Passenger.Insert(true);
        end;
    end;
}
