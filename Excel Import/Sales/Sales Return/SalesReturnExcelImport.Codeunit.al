
codeunit 50333 "Sales Return Excel Import"
{
    var
        ImportColumns: Dictionary of [Integer, Integer];

    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        SalesReturn: Record "Sales Return";
        ExistingSalesReturn: Record "Sales Return";
        Passenger: Record "Sales Return Passenger Name";
        InStream: InStream;
        FileName: Text;
        SheetName: Text;
        InvoiceNo: Code[50];
        ReturnNo: Code[50];
        LastRow: Integer;
        RowNo: Integer;
        ImportedCount: Integer;
        ExcelValidation: Codeunit "AIRIQ Excel Validation Mgt.";
        PrecheckPassenger: Record "Sales Return Passenger Name";
        PrecheckPNR: Text;
        PrecheckLinkText: Text;
        PrecheckLinkValid: Boolean;
        DuplicateCount: Integer;
        BlankCount: Integer;
        Names: List of [Text];
        Ids: List of [Text];
        Types: List of [Text];
        CellText: Text;
    begin
        if not UploadIntoStream(
            'Select Sales Return Excel',
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

        // Phase 1A: collect all header errors without writing business records.
        ExcelValidation.Initialize();
        ExcelValidation.CheckDuplicateHeaders(ExcelBuffer, true);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Serial No.', true, true, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Entry Date', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Bill No.', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Invoice No.', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Return No.', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Agency ID', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'A/C Name', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Country', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'State', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'City', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Sector', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Type', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Travel Date', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Time', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Airline', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Airline Code', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'PNR', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'View Passenger', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Passenger ID', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Passenger Type', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Reference', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Narration', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'PAX', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Base Fare', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Other Charges', true, true, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Taxable Value', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'CGST', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'SGST', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'IGST', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Sold Value', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'XXLN Charges', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Refund Amount', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Sale Type', true, false, false);
        ExcelValidation.CheckHeaderName(ExcelBuffer, 'Supplier', true, false, false);
        if ExcelValidation.HasErrors() then begin
            ExcelValidation.ShowErrors(ExcelBuffer, 'Own Sales Return', FileName, SheetName);
            ExcelBuffer.CloseBook();
            exit;
        end;


        CheckHeaders(ExcelBuffer);

        ExcelBuffer.Reset();

        if not ExcelBuffer.FindLast() then
            exit;

        LastRow := ExcelBuffer."Row No.";

        // Phase 1B: scan the complete data sheet before allocating serial numbers or inserting records.
        // Existing blank/instruction-row handling is preserved. Duplicate rows are validated too;
        // the original duplicate skip logic below still decides which valid rows are inserted.
        for RowNo := 2 to LastRow do begin
            PrecheckPNR := Cell(ExcelBuffer, RowNo, 17);
            PrecheckLinkText := Cell(ExcelBuffer, RowNo, 5);
            if not IsBlankRow(ExcelBuffer, RowNo) then begin
                ExcelValidation.CheckPassengerRow(RowNo, PrecheckPNR, Cell(ExcelBuffer, RowNo, 23), Cell(ExcelBuffer, RowNo, 18), Cell(ExcelBuffer, RowNo, 19), Cell(ExcelBuffer, RowNo, 20), ImportColumns.Get(23), ImportColumns.Get(18), ImportColumns.Get(19), ImportColumns.Get(20));
                ReturnNo := CopyStr(PrecheckLinkText, 1, MaxStrLen(ReturnNo));
                PrecheckLinkValid := ReturnNo <> '';
                if not PrecheckLinkValid then
                    ExcelValidation.AddIssue(RowNo, ImportColumns.Get(5), PrecheckPNR, 0, 'Return No.', PrecheckLinkText, 'Return No. is blank.', 'Enter the return number.');
                if PrecheckLinkValid then begin
                    ExistingSalesReturn.Reset();
                    ExistingSalesReturn.SetRange("Return No.", ReturnNo);
                    if ExistingSalesReturn.IsEmpty() then begin
                        PrecheckPassenger.Reset();
                        PrecheckPassenger.SetRange("Return No.", ReturnNo);
                        PrecheckPassenger.SetRange(PNR, CopyStr(PrecheckPNR, 1, 10));
                        if not PrecheckPassenger.IsEmpty() then
                            ExcelValidation.AddIssue(RowNo, ImportColumns.Get(18), PrecheckPNR, 0, 'Existing Passenger Records', PrecheckLinkText, 'Passenger records already exist for this reference and PNR.', 'Resolve the existing passenger records in BC before importing.');
                    end;
                end;
            end;
        end;
        if ExcelValidation.HasErrors() then begin
            ExcelValidation.ShowErrors(ExcelBuffer, 'Own Sales Return', FileName, SheetName);
            ExcelBuffer.CloseBook();
            exit;
        end;

        // Phase 2: original import logic. Do not skip a late passenger validation failure.
        for RowNo := 2 to LastRow do begin

            if IsBlankRow(ExcelBuffer, RowNo) then
                BlankCount += 1
            else begin

                // Column 4: Invoice No.
                InvoiceNo := CopyStr(
                    Cell(ExcelBuffer, RowNo, 4),
                    1,
                    MaxStrLen(InvoiceNo));

                // Column 5: Return No.
                ReturnNo := CopyStr(
                    Cell(ExcelBuffer, RowNo, 5),
                    1,
                    MaxStrLen(ReturnNo));

                if ReturnNo = '' then
                    Error(
                        'Return No. is blank at Excel row %1.',
                        RowNo);

                // Duplicate prevention by Return No.
                ExistingSalesReturn.Reset();
                ExistingSalesReturn.SetRange(
                    "Return No.", ReturnNo);

                if ExistingSalesReturn.FindFirst() then
                    DuplicateCount += 1
                else begin

                    // Passenger columns: 18, 19, 20
                    Names := SplitValues(
                        Cell(ExcelBuffer, RowNo, 18));

                    Ids := SplitValues(
                        Cell(ExcelBuffer, RowNo, 19));

                    Types := SplitValues(
                        Cell(ExcelBuffer, RowNo, 20));

                    // Validate before inserting main record.
                    if not TryCheckPassengerRow(Cell(ExcelBuffer, RowNo, 23), Names, Ids, Types, RowNo, ReturnNo, CopyStr(Cell(ExcelBuffer, RowNo, 17), 1, 10)) then
                        Error('Excel row %1: %2', RowNo, GetLastErrorText());

                    SalesReturn.Init();

                    // Column 1: Serial No. ignored.
                    // Generated by Sales Return OnInsert.

                    // Column 2: Entry Date
                    CellText := Cell(ExcelBuffer, RowNo, 2);

                    if CellText <> '' then
                        SalesReturn."Entry Date" :=
                            ParseDateTimeText(
                                CellText, RowNo, 2);

                    // Column 3: Bill No.
                    SalesReturn."Bill No." :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 3),
                            1,
                            MaxStrLen(SalesReturn."Bill No."));

                    // Column 4: Invoice No.
                    SalesReturn."Invoice No." := InvoiceNo;

                    // Column 5: Return No.
                    SalesReturn."Return No." := ReturnNo;

                    // Column 6: Agency ID
                    SalesReturn."Agency ID" :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 6),
                            1,
                            MaxStrLen(SalesReturn."Agency ID"));

                    // Column 7: A/C Name
                    SalesReturn."A/C Name" :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 7),
                            1,
                            MaxStrLen(SalesReturn."A/C Name"));

                    // Column 8: Country
                    SalesReturn.Country :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 8),
                            1,
                            MaxStrLen(SalesReturn.Country));

                    // Column 9: State
                    SalesReturn.State :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 9),
                            1,
                            MaxStrLen(SalesReturn.State));

                    // Column 10: City
                    SalesReturn.City :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 10),
                            1,
                            MaxStrLen(SalesReturn.City));

                    // Column 11: Sector
                    SalesReturn.Sector :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 11),
                            1,
                            MaxStrLen(SalesReturn.Sector));

                    // Column 12: Type
                    SalesReturn.Type :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 12),
                            1,
                            MaxStrLen(SalesReturn.Type));

                    // Column 13: Travel Date
                    CellText := Cell(ExcelBuffer, RowNo, 13);

                    if CellText <> '' then
                        SalesReturn."Travel Date" :=
                            ParseDateTimeText(
                                CellText, RowNo, 13);

                    // Column 14: Time
                    CellText := Cell(ExcelBuffer, RowNo, 14);

                    if CellText <> '' then
                        SalesReturn.Time :=
                            ParseTimeText(
                                CellText, RowNo, 14);

                    // Column 15: Airline
                    SalesReturn.Airline :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 15),
                            1,
                            MaxStrLen(SalesReturn.Airline));

                    // Column 16: Airline Code
                    SalesReturn."Airline Code" :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 16),
                            1,
                            MaxStrLen(SalesReturn."Airline Code"));

                    // Column 17: PNR
                    SalesReturn.PNR :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 17),
                            1,
                            MaxStrLen(SalesReturn.PNR));

                    // Column 18: View Passenger
                    SalesReturn."Passenger Name" :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 18),
                            1,
                            MaxStrLen(SalesReturn."Passenger Name"));

                    // Column 19: Passenger ID
                    // Column 20: Passenger Type
                    // Saved separately in passenger table.

                    // Column 21: Reference
                    SalesReturn.Reference :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 21),
                            1,
                            MaxStrLen(SalesReturn.Reference));

                    // Column 22: Narration
                    SalesReturn.Narration :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 22),
                            1,
                            MaxStrLen(SalesReturn.Narration));

                    // Column 23: PAX
                    SalesReturn.PAX :=
                        ParseInteger(
                            Cell(ExcelBuffer, RowNo, 23),
                            RowNo, 23);

                    // Columns 24-29 are legacy Excel fields. They are
                    // intentionally ignored: actual financial data comes
                    // from the matching Posted Sales Invoice on Insert(true).

                    // Column 30: Sold Value
                    SalesReturn."Sold Value" :=
                        ParseDecimal(
                            Cell(ExcelBuffer, RowNo, 30),
                            RowNo, 30);

                    // Column 31: XXLN Charges
                    SalesReturn."XXLN Charges" :=
                        ParseDecimal(
                            Cell(ExcelBuffer, RowNo, 31),
                            RowNo, 31);

                    // Column 32: Refund Amount
                    SalesReturn."Refund Amount" :=
                        ParseDecimal(
                            Cell(ExcelBuffer, RowNo, 32),
                            RowNo, 32);

                    // Column 33: Sale Type
                    CellText := Cell(ExcelBuffer, RowNo, 33);

                    if CellText <> '' then
                        if not Evaluate(
                            SalesReturn."Sale Type",
                            CellText)
                        then
                            Error(
                                'Invalid Sale Type "%1" at Excel row %2. Use Own or ThirdParty.',
                                CellText, RowNo);

                    // Column 34: Supplier
                    SalesReturn.Supplier :=
                        CopyStr(
                            Cell(ExcelBuffer, RowNo, 34),
                            1,
                            MaxStrLen(SalesReturn.Supplier));

                    // Insert Sales Return main record.
                    SalesReturn.Insert(true);

                    // Insert passenger records line by line.
                    InsertPassengers(
                        Passenger,
                        SalesReturn."Return No.",
                        SalesReturn.PNR,
                        Names,
                        Ids,
                        Types,
                        RowNo);

                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Sales Return Excel Import Completed.\' +
            'Imported: %1\' +
            'Duplicate Return No.: %2\' +
            'Blank rows skipped: %3',
            ImportedCount,
            DuplicateCount,
            BlankCount);
    end;

    local procedure CheckHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    var
        Headers: List of [Text];
        Expected: Text;
        Actual: Text;
        ColNo: Integer;
        HeaderColumns: Dictionary of [Text, Integer];
        ActualColNo: Integer;
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
        Headers.Add('Reference');
        Headers.Add('Narration');
        Headers.Add('PAX');
        Headers.Add('Base Fare');
        Headers.Add('Other Charges');
        Headers.Add('Taxable Value');
        Headers.Add('CGST');
        Headers.Add('SGST');
        Headers.Add('IGST');
        Headers.Add('Sold Value');
        Headers.Add('XXLN Charges');
        Headers.Add('Refund Amount');
        Headers.Add('Sale Type');
        Headers.Add('Supplier');

        Clear(ImportColumns);
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", 1);
        if ExcelBuffer.FindSet() then
            repeat
                Actual := UpperCase(DelChr(ExcelBuffer."Cell Value as Text", '<>', ' '));
                if Actual = 'PASSENGER NAME' then
                    Actual := 'VIEW PASSENGER';
                if Actual <> '' then begin
                    if HeaderColumns.ContainsKey(Actual) then
                        Error('Duplicate Excel header "%1" at column %2.', Actual, ExcelBuffer."Column No.");
                    HeaderColumns.Add(Actual, ExcelBuffer."Column No.");
                end;
            until ExcelBuffer.Next() = 0;
        ExcelBuffer.Reset();

        ColNo := 0;
        foreach Expected in Headers do begin
            ColNo += 1;
            if HeaderColumns.Get(UpperCase(Expected), ActualColNo) then
                ImportColumns.Add(ColNo, ActualColNo)
            else
                // Serial No. is generated; older templates may omit Other Charges.
                if not (ColNo in [1, 25]) then
                    Error('Required Excel header "%1" is missing from row 1.', Expected);
        end;
    end;

    local procedure IsBlankRow(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer): Boolean
    var
        ColNo: Integer;
    begin
        for ColNo := 2 to 34 do
            if Cell(ExcelBuffer, RowNo, ColNo) <> '' then
                exit(false);

        exit(true);
    end;

    local procedure Cell(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColNo: Integer): Text
    var
        ActualColNo: Integer;
    begin
        if not ImportColumns.Get(ColNo, ActualColNo) then
            exit('');

        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ActualColNo);

        if ExcelBuffer.FindFirst() then
            exit(
                DelChr(
                    ExcelBuffer."Cell Value as Text",
                    '<>',
                    ' '));

        exit('');
    end;

    local procedure SplitValues(
        InputText: Text): List of [Text]
    var
        Result: List of [Text];
        Parts: List of [Text];
        Part: Text;
    begin
        if InputText = '' then
            exit(Result);

        Parts := InputText.Split(',');

        foreach Part in Parts do
            Result.Add(
                DelChr(Part, '<>', ' '));

        exit(Result);
    end;

    [TryFunction]
    local procedure TryCheckPassengerRow(PaxText: Text; Names: List of [Text]; Ids: List of [Text]; Types: List of [Text]; RowNo: Integer; LinkNo: Code[50]; PNRValue: Text[10])
    var
        PaxValue: Integer;
        PaxValidation: Codeunit "AIRIQ Pax Validation";
        ExistingPassenger: Record "Sales Return Passenger Name";
    begin
        if not Evaluate(PaxValue, PaxText) then
            Error('Invalid or blank PAX.');
        CheckPassengers(Names, Ids, Types, RowNo);
        PaxValidation.CheckExactCount(PaxValue, Names.Count());
        ExistingPassenger.SetRange("Return No.", LinkNo);
        ExistingPassenger.SetRange(PNR, PNRValue);
        if not ExistingPassenger.IsEmpty() then
            Error('Passenger records already exist for this reference and PNR. Resolve existing records before importing.');
    end;

    local procedure CheckPassengers(
        Names: List of [Text];
        Ids: List of [Text];
        Types: List of [Text];
        RowNo: Integer)
    var
        NameText: Text;
        IdText: Text;
        TypeText: Text;
        PassengerId: BigInteger;
        I: Integer;
    begin
        if (Names.Count() <> Ids.Count()) or
           (Names.Count() <> Types.Count())
        then
            Error(
                'Passenger count mismatch at Excel row %1: Names=%2, IDs=%3, Types=%4.',
                RowNo,
                Names.Count(),
                Ids.Count(),
                Types.Count());

        for I := 1 to Names.Count() do begin
            Names.Get(I, NameText);
            Ids.Get(I, IdText);
            Types.Get(I, TypeText);

            if (NameText = '') or
               (IdText = '') or
               (TypeText = '')
            then
                Error(
                    'Blank passenger Name, ID or Type at Excel row %1, passenger %2.',
                    RowNo, I);

            if StrLen(NameText) > 100 then
                Error(
                    'Passenger name too long at Excel row %1, passenger %2.',
                    RowNo, I);

            if StrLen(TypeText) > 50 then
                Error(
                    'Passenger Type too long at Excel row %1, passenger %2.',
                    RowNo, I);

            if not Evaluate(PassengerId, IdText) then
                Error(
                    'Invalid numeric Passenger ID "%1" at Excel row %2, passenger %3.',
                    IdText, RowNo, I);

            if PassengerId <= 0 then
                Error('Passenger ID must be greater than 0 at Excel row %1, passenger %2.', RowNo, I);
        end;
    end;

    local procedure InsertPassengers(
        var Passenger: Record "Sales Return Passenger Name";
        ReturnNo: Code[50];
        PNRValue: Text[10];
        Names: List of [Text];
        Ids: List of [Text];
        Types: List of [Text];
        RowNo: Integer)
    var
        ExistingPassenger: Record "Sales Return Passenger Name";
        NameText: Text;
        IdText: Text;
        TypeText: Text;
        NextSLNo: Integer;
        I: Integer;
    begin
        if Names.Count() = 0 then
            exit;

        // Lock before determining the next SL No.
        Passenger.LockTable();

        // Global SL No. across all Return Nos.
        ExistingPassenger.Reset();
        ExistingPassenger.SetCurrentKey("SL No.");

        if ExistingPassenger.FindLast() then
            NextSLNo := ExistingPassenger."SL No." + 1
        else
            NextSLNo := 1;

        for I := 1 to Names.Count() do begin
            Names.Get(I, NameText);
            Ids.Get(I, IdText);
            Types.Get(I, TypeText);

            Passenger.Init();

            Passenger."Return No." := ReturnNo;
            Passenger.PNR := PNRValue;
            Passenger."SL No." := NextSLNo;

            Passenger."Passenger Name" :=
                CopyStr(
                    NameText,
                    1,
                    MaxStrLen(Passenger."Passenger Name"));

            if not Evaluate(Passenger.ID, IdText) then
                Error(
                    'Invalid Passenger ID at Excel row %1, passenger %2.',
                    RowNo, I);

            Passenger.Type :=
                CopyStr(
                    TypeText,
                    1,
                    MaxStrLen(Passenger.Type));

            Passenger.Insert(true);

            NextSLNo += 1;
        end;
    end;

    local procedure ParseDateTimeText(
        InputText: Text;
        RowNo: Integer;
        ColNo: Integer): DateTime
    var
        DatePart: Text;
        TimePart: Text;
        DatePieces: List of [Text];
        DayText: Text;
        MonthText: Text;
        YearText: Text;
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        SpacePos: Integer;
        ParsedDate: Date;
        ParsedTime: Time;
    begin
        // Expected TEXT: dd-MM-yyyy HH:mm
        // Example: 29-10-2026 19:08

        SpacePos := StrPos(InputText, ' ');

        if SpacePos = 0 then
            Error(
                'Invalid DateTime "%1" at Excel row %2, column %3. Expected dd-MM-yyyy HH:mm.',
                InputText, RowNo, ColNo);

        DatePart :=
            CopyStr(InputText, 1, SpacePos - 1);

        TimePart :=
            CopyStr(InputText, SpacePos + 1);

        DatePieces := DatePart.Split('-');

        if DatePieces.Count() <> 3 then
            Error(
                'Invalid date "%1" at Excel row %2, column %3.',
                DatePart, RowNo, ColNo);

        DatePieces.Get(1, DayText);
        DatePieces.Get(2, MonthText);
        DatePieces.Get(3, YearText);

        if (StrLen(DayText) <> 2) or
           (StrLen(MonthText) <> 2) or
           (StrLen(YearText) <> 4)
        then
            Error(
                'Invalid date "%1" at Excel row %2, column %3. Expected dd-MM-yyyy.',
                DatePart, RowNo, ColNo);

        if not Evaluate(DayNo, DayText) then
            Error(
                'Invalid day at Excel row %1, column %2.',
                RowNo, ColNo);

        if not Evaluate(MonthNo, MonthText) then
            Error(
                'Invalid month at Excel row %1, column %2.',
                RowNo, ColNo);

        if not Evaluate(YearNo, YearText) then
            Error(
                'Invalid year at Excel row %1, column %2.',
                RowNo, ColNo);

        if not TryMakeDate(
            DayNo, MonthNo, YearNo, ParsedDate)
        then
            Error(
                'Invalid date "%1" at Excel row %2, column %3.',
                DatePart, RowNo, ColNo);

        ParsedTime :=
            ParseTimeText(TimePart, RowNo, ColNo);

        exit(CreateDateTime(ParsedDate, ParsedTime));
    end;

    [TryFunction]
    local procedure TryMakeDate(
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        var ParsedDate: Date)
    begin
        ParsedDate :=
            DMY2Date(DayNo, MonthNo, YearNo);
    end;

    local procedure ParseTimeText(
        InputText: Text;
        RowNo: Integer;
        ColNo: Integer): Time
    var
        ParsedTime: Time;
    begin
        // Example: 19:15
        if Evaluate(ParsedTime, InputText) then
            exit(ParsedTime);

        Error(
            'Invalid time "%1" at Excel row %2, column %3. Expected HH:mm.',
            InputText, RowNo, ColNo);
    end;

    local procedure ParseDecimal(
        InputText: Text;
        RowNo: Integer;
        ColNo: Integer): Decimal
    var
        Value: Decimal;
    begin
        if InputText = '' then
            exit(0);

        if Evaluate(Value, InputText, 9) then
            exit(Value);

        if Evaluate(Value, InputText) then
            exit(Value);

        Error(
            'Invalid decimal "%1" at Excel row %2, column %3.',
            InputText, RowNo, ColNo);
    end;

    local procedure ParseInteger(
        InputText: Text;
        RowNo: Integer;
        ColNo: Integer): Integer
    var
        Value: Integer;
    begin
        if InputText = '' then
            exit(0);

        if Evaluate(Value, InputText) then
            exit(Value);

        Error(
            'Invalid integer "%1" at Excel row %2, column %3.',
            InputText, RowNo, ColNo);
    end;
}
