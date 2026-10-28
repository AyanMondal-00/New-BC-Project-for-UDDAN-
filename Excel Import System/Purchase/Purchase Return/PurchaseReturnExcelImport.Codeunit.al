
codeunit 50332 "Purchase Return Excel Import"
{
    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        PurchaseReturn: Record "Purchase Return";
        ExistingPurchaseReturn: Record "Purchase Return";
        InStream: InStream;
        FileName: Text;
        SheetName: Text;
        LastRow: Integer;
        RowNo: Integer;
        CellValue: Text;
        PNRValue: Text[10];
        ImportedCount: Integer;
        DuplicateCount: Integer;
        BlankRowCount: Integer;
    begin
        if not UploadIntoStream(
            'Select Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            InStream)
        then
            exit;

        SheetName := ExcelBuffer.SelectSheetsNameStream(InStream);
        if SheetName = '' then
            exit;

        ExcelBuffer.OpenBookStream(InStream, SheetName);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.Reset();
        if ExcelBuffer.FindLast() then
            LastRow := ExcelBuffer."Row No.";

        for RowNo := 2 to LastRow do begin
            if (GetCellText(ExcelBuffer, RowNo, 4) = '') and
               (GetCellText(ExcelBuffer, RowNo, 7) = '') and
               (GetCellText(ExcelBuffer, RowNo, 11) = '')
            then
                BlankRowCount += 1
            else begin
                PNRValue := CopyStr(
                    GetCellText(ExcelBuffer, RowNo, 11),
                    1,
                    MaxStrLen(PNRValue));

                // Duplicate prevention by PNR.
                Clear(ExistingPurchaseReturn);

                if PNRValue <> '' then begin
                    ExistingPurchaseReturn.SetRange(
                        PNR, PNRValue);
                end;

                if (PNRValue <> '') and
                   ExistingPurchaseReturn.FindFirst()
                then
                    DuplicateCount += 1
                else begin
                    PurchaseReturn.Init();

                    // Column 1: Serial No. ignored.
                    // Table OnInsert generates the Serial No.

                    // Column 2: Entry Date
                    CellValue := GetCellText(ExcelBuffer, RowNo, 2);
                    if CellValue <> '' then
                        PurchaseReturn."Entry Date" :=
                            ParseExcelDateTime(CellValue, RowNo, 2);

                    // Column 3: Purchase Date
                    CellValue := GetCellText(ExcelBuffer, RowNo, 3);
                    if CellValue <> '' then
                        PurchaseReturn."Purchase Date" :=
                            ParseExcelDateTime(CellValue, RowNo, 3);

                    // Column 4: Voucher Number
                    PurchaseReturn."Voucher Number" :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 4),
                            1, MaxStrLen(PurchaseReturn."Voucher Number"));

                    // Column 5: Airline
                    PurchaseReturn.Airline :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 5),
                            1, MaxStrLen(PurchaseReturn.Airline));

                    // Column 6: Airline ID
                    PurchaseReturn."Airline ID" :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 6),
                            1, MaxStrLen(PurchaseReturn."Airline ID"));

                    // Column 7: Airline Code
                    PurchaseReturn."Airline Code" :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 7),
                            1, MaxStrLen(PurchaseReturn."Airline Code"));

                    // Column 8: Country
                    PurchaseReturn.Country :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 8),
                            1, MaxStrLen(PurchaseReturn.Country));

                    // Column 9: Type
                    PurchaseReturn.Type :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 9),
                            1, MaxStrLen(PurchaseReturn.Type));

                    // Column 10: Sector
                    PurchaseReturn.Sector :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 10),
                            1, MaxStrLen(PurchaseReturn.Sector));

                    // Column 11: PNR
                    PurchaseReturn.PNR := PNRValue;

                    // Column 12: Reference (optional)
                    PurchaseReturn.Reference :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 12),
                            1, MaxStrLen(PurchaseReturn.Reference));

                    // Column 13: Narration (optional)
                    PurchaseReturn.Narration :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 13),
                            1, MaxStrLen(PurchaseReturn.Narration));

                    // Column 14: Pax
                    CellValue := GetCellText(ExcelBuffer, RowNo, 14);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn.Pax, CellValue) then
                            Error('Invalid Pax "%1" at row %2.',
                                CellValue, RowNo);

                    // Column 15: Base Fare
                    CellValue := GetCellText(ExcelBuffer, RowNo, 15);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn."Base Fare", CellValue) then
                            Error('Invalid Base Fare at row %1.', RowNo);

                    // Column 16: Others
                    CellValue := GetCellText(ExcelBuffer, RowNo, 16);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn.Others, CellValue) then
                            Error('Invalid Others at row %1.', RowNo);

                    // Column 17: Rate
                    CellValue := GetCellText(ExcelBuffer, RowNo, 17);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn.Rate, CellValue) then
                            Error('Invalid Rate at row %1.', RowNo);

                    // Column 18: Discount
                    CellValue := GetCellText(ExcelBuffer, RowNo, 18);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn.Discount, CellValue) then
                            Error('Invalid Discount at row %1.', RowNo);

                    // Column 19: XXLN Charges
                    CellValue := GetCellText(ExcelBuffer, RowNo, 19);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn."XXLN Charges", CellValue) then
                            Error('Invalid XXLN Charges at row %1.', RowNo);

                    // Column 20: Amount
                    CellValue := GetCellText(ExcelBuffer, RowNo, 20);
                    if CellValue <> '' then
                        if not Evaluate(PurchaseReturn.Amount, CellValue) then
                            Error('Invalid Amount at row %1.', RowNo);

                    // Column 21: Travel Date
                    CellValue := GetCellText(ExcelBuffer, RowNo, 21);
                    if CellValue <> '' then
                        PurchaseReturn."Travel Date" :=
                            ParseExcelDateTime(CellValue, RowNo, 21);

                    // Column 22: Departure Time
                    CellValue := GetCellText(ExcelBuffer, RowNo, 22);
                    if CellValue <> '' then
                        PurchaseReturn."Departure Time" :=
                            ParseExcelTime(CellValue, RowNo, 22);

                    // Column 23: Arrival Time
                    CellValue := GetCellText(ExcelBuffer, RowNo, 23);
                    if CellValue <> '' then
                        PurchaseReturn."Arrival Time" :=
                            ParseExcelTime(CellValue, RowNo, 23);

                    // Column 24: Flight No.
                    PurchaseReturn."Flight No." :=
                        CopyStr(GetCellText(ExcelBuffer, RowNo, 24),
                            1, MaxStrLen(PurchaseReturn."Flight No."));

      

                    // Column 26: Cost Revision (Yes / No)
                    CellValue := GetCellText(ExcelBuffer, RowNo, 26);
                    if CellValue <> '' then begin
                        CellValue := DelChr(CellValue, '<>', ' ');
                        if not Evaluate(PurchaseReturn."Cost Revision", CellValue) then
                            Error(
                                'Invalid Cost Revision "%1" at row %2. Use Yes or No.',
                                CellValue, RowNo);
                    end;

                    // Generate Serial No. through table OnInsert.
                    PurchaseReturn.Insert(true);
                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Purchase Return Excel Import Completed.\' +
            'Imported: %1\' +
            'Duplicate PNR: %2\' +
            'Blank rows skipped: %3',
            ImportedCount,
            DuplicateCount,
            BlankRowCount);
    end;

    local procedure ParseExcelDateTime(
        InputText: Text;
        RowNo: Integer;
        ColumnNo: Integer): DateTime
    var
        ParsedDate: Date;
        ParsedTime: Time;
        DateText: Text;
        TimeText: Text;
        SeparatorPosition: Integer;
    begin
        InputText := DelChr(InputText, '<>', ' ');

        SeparatorPosition := StrPos(InputText, ' ');

        if SeparatorPosition > 0 then begin
            DateText := CopyStr(InputText, 1, SeparatorPosition - 1);
            TimeText := CopyStr(InputText, SeparatorPosition + 1);
        end else begin
            DateText := InputText;
            TimeText := '';
        end;

        if not ParseDateText(DateText, ParsedDate) then
            Error(
                'Invalid date "%1" at Excel row %2, column %3.',
                DateText, RowNo, ColumnNo);

        if TimeText = '' then
            exit(CreateDateTime(ParsedDate, 0T));

        if not Evaluate(ParsedTime, TimeText) then
            Error(
                'Invalid time "%1" at Excel row %2, column %3.',
                TimeText, RowNo, ColumnNo);

        exit(CreateDateTime(ParsedDate, ParsedTime));
    end;

    local procedure ParseDateText(
        InputText: Text;
        var ParsedDate: Date): Boolean
    var
        Part1: Text;
        Part2: Text;
        Part3: Text;
        Separator: Text[1];
        SeparatorPosition: Integer;
        SecondSeparatorPosition: Integer;
        FirstNumber: Integer;
        SecondNumber: Integer;
        ThirdNumber: Integer;
    begin
        // Try BC regional date parsing first.
        if Evaluate(ParsedDate, InputText) then
            exit(true);

        SeparatorPosition := StrPos(InputText, '-');
        if SeparatorPosition = 0 then
            SeparatorPosition := StrPos(InputText, '/');

        if SeparatorPosition = 0 then
            exit(false);

        Separator := CopyStr(InputText, SeparatorPosition, 1);
        Part1 := CopyStr(InputText, 1, SeparatorPosition - 1);

        SecondSeparatorPosition :=
            StrPos(
                CopyStr(InputText, SeparatorPosition + 1),
                Separator);

        if SecondSeparatorPosition = 0 then
            exit(false);

        SecondSeparatorPosition += SeparatorPosition;

        Part2 := CopyStr(
            InputText,
            SeparatorPosition + 1,
            SecondSeparatorPosition - SeparatorPosition - 1);

        Part3 := CopyStr(InputText, SecondSeparatorPosition + 1);

        if not Evaluate(FirstNumber, Part1) then
            exit(false);
        if not Evaluate(SecondNumber, Part2) then
            exit(false);
        if not Evaluate(ThirdNumber, Part3) then
            exit(false);

        if StrLen(Part1) = 4 then
            exit(TryCreateDate(
                ThirdNumber, SecondNumber, FirstNumber, ParsedDate));

        exit(TryCreateDate(
            FirstNumber, SecondNumber, ThirdNumber, ParsedDate));
    end;

    [TryFunction]
    local procedure TryCreateDate(
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        var ParsedDate: Date)
    begin
        ParsedDate := DMY2Date(DayNo, MonthNo, YearNo);
    end;

    local procedure ParseExcelTime(
        InputText: Text;
        RowNo: Integer;
        ColumnNo: Integer): Time
    var
        ParsedTime: Time;
    begin
        InputText := DelChr(InputText, '<>', ' ');

        if Evaluate(ParsedTime, InputText) then
            exit(ParsedTime);

        Error(
            'Invalid time "%1" at Excel row %2, column %3.',
            InputText, RowNo, ColumnNo);
    end;

    local procedure GetCellText(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Text
    begin
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ColumnNo);

        if ExcelBuffer.FindFirst() then
            exit(ExcelBuffer."Cell Value as Text");

        exit('');
    end;
}
