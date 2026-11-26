
codeunit 50430 "Own Sales Excel Import Mgt."
{
    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        NormalSales: Record "Normal Sales";
        ExistingNormalSales: Record "Normal Sales";
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRowNo: Integer;
        ImportedCount: Integer;
        ExcelValidation: Codeunit "AIRIQ Excel Validation Mgt.";
        PrecheckPassenger: Record "Own Sales Passenger Name";
        PrecheckPNR: Text;
        PrecheckLinkText: Text;
        PrecheckLinkValid: Boolean;
        SkippedCount: Integer;
        DuplicateCount: Integer;
        PNRValue: Text;
        RefNoValue: BigInteger;
        PassengerNamesValue: Text;
        PassengerIDsValue: Text;
        PassengerTypesValue: Text;
    begin
        if not UploadIntoStream(
            'Select Own Sales Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            UploadInStream)
        then
            exit;

        SheetName := TempExcelBuffer.SelectSheetsNameStream(
            UploadInStream);

        if SheetName = '' then
            exit;

        UploadInStream.ResetPosition();

        TempExcelBuffer.OpenBookStream(
            UploadInStream, SheetName);

        TempExcelBuffer.ReadSheet();

        // Phase 1A: collect all header errors without writing business records.
        ExcelValidation.Initialize();
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 1, 'Serial No.', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 2, 'Date', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 3, 'Invoice Number', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 4, 'Agency ID', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 5, 'Agency Name', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 6, 'Ref No./AQ Number', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 7, 'Select', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 8, 'Sales Invoice Created', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 9, 'PNR', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 10, 'View Passenger', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 11, 'Passenger ID', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 12, 'Passenger Type', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 13, 'Pax', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 14, 'Travel Date', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 15, 'Sector', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 16, 'Type', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 17, 'Base Fare', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 18, 'Other Charges', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 19, 'Taxable Basis', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 20, 'CGST', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 21, 'SGST', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 22, 'IGST', false);
        ExcelValidation.CheckHeaderPosition(TempExcelBuffer, 23, 'Total Amount', false);
        if ExcelValidation.HasErrors() then begin
            ExcelValidation.ShowErrors(TempExcelBuffer, 'Own Sales', FileName, SheetName);
            TempExcelBuffer.CloseBook();
            exit;
        end;


        CheckHeaders(TempExcelBuffer);

        TempExcelBuffer.Reset();

        if not TempExcelBuffer.FindLast() then
            Error('The selected Excel file is empty.');

        LastRowNo := TempExcelBuffer."Row No.";

        if LastRowNo < 2 then
            Error(
                'No data rows found. Row 1 must contain the column headers.');

        // Phase 1B: scan the complete data sheet before allocating serial numbers or inserting records.
        // Existing blank/instruction-row handling is preserved. Duplicate rows are validated too;
        // the original duplicate skip logic below still decides which valid rows are inserted.
        for RowNo := 2 to LastRowNo do begin
            PrecheckPNR := GetCellValue(TempExcelBuffer, RowNo, 9);
            PrecheckLinkText := GetCellValue(TempExcelBuffer, RowNo, 6);
            if PrecheckPNR <> '' then begin
                ExcelValidation.CheckPassengerRow(RowNo, PrecheckPNR, GetCellValue(TempExcelBuffer, RowNo, 13), GetCellValue(TempExcelBuffer, RowNo, 10), GetCellValue(TempExcelBuffer, RowNo, 11), GetCellValue(TempExcelBuffer, RowNo, 12), 13, 10, 11, 12);
                PrecheckLinkValid := Evaluate(RefNoValue, PrecheckLinkText);
                if PrecheckLinkValid then
                    PrecheckLinkValid := RefNoValue <> 0;
                if not PrecheckLinkValid then
                    ExcelValidation.AddIssue(RowNo, 6, PrecheckPNR, 0, 'Ref No./AQ Number', PrecheckLinkText, 'Reference number is invalid, blank or zero.', 'Enter a valid non-zero reference number.');
                if PrecheckLinkValid then begin
                    ExistingNormalSales.Reset();
                    ExistingNormalSales.SetRange("Ref No./AQ Number", RefNoValue);
                    if ExistingNormalSales.IsEmpty() then begin
                        PrecheckPassenger.Reset();
                        PrecheckPassenger.SetRange("Ref No./AQ Number", RefNoValue);
                        PrecheckPassenger.SetRange(PNR, CopyStr(PrecheckPNR, 1, 10));
                        if not PrecheckPassenger.IsEmpty() then
                            ExcelValidation.AddIssue(RowNo, 10, PrecheckPNR, 0, 'Existing Passenger Records', PrecheckLinkText, 'Passenger records already exist for this reference and PNR.', 'Resolve the existing passenger records in BC before importing.');
                    end;
                end;
            end;
        end;
        if ExcelValidation.HasErrors() then begin
            ExcelValidation.ShowErrors(TempExcelBuffer, 'Own Sales', FileName, SheetName);
            TempExcelBuffer.CloseBook();
            exit;
        end;

        // Phase 2: original import logic. Do not skip a late passenger validation failure.
        for RowNo := 2 to LastRowNo do begin

            PNRValue := GetCellValue(
                TempExcelBuffer, RowNo, 9);

            if PNRValue <> '' then begin

                if not Evaluate(
                    RefNoValue,
                    GetCellValue(TempExcelBuffer, RowNo, 6))
                then
                    Error(
                        'Invalid Ref No./AQ Number at Excel row %1.',
                        RowNo);

                if RefNoValue = 0 then
                    Error(
                        'Ref No./AQ Number is blank or zero at Excel row %1.',
                        RowNo);

                // Duplicate prevention by AQ Number
                ExistingNormalSales.Reset();
                ExistingNormalSales.SetRange(
                    "Ref No./AQ Number", RefNoValue);

                if not ExistingNormalSales.IsEmpty() then
                    DuplicateCount += 1
                else begin

                    // Passenger Name, ID and Type
                    PassengerNamesValue :=
                        GetCellValue(
                            TempExcelBuffer, RowNo, 10);

                    PassengerIDsValue :=
                        GetCellValue(
                            TempExcelBuffer, RowNo, 11);

                    PassengerTypesValue :=
                        GetCellValue(
                            TempExcelBuffer, RowNo, 12);

                    // Validate all passenger values first
                    if not TryCheckPassengerRow(GetCellValue(TempExcelBuffer, RowNo, 13), PassengerNamesValue, PassengerIDsValue, PassengerTypesValue, RowNo, RefNoValue, CopyStr(PNRValue, 1, 10)) then
                        Error('Excel row %1: %2', RowNo, GetLastErrorText());

                    Clear(NormalSales);
                    NormalSales.Init();

                    // Serial No. generated by table OnInsert

                    // Column 2: Date
                    NormalSales.Validate(
                        "Date",
                        GetDateTimeValue(
                            TempExcelBuffer, RowNo, 2));

                    // Column 3: Invoice Number
                    NormalSales.Validate(
                        "Invoice Number",
                        CopyStr(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 3),
                            1, 50));

                    // Column 4: Agency ID
                    NormalSales.Validate(
                        "Agency ID",
                        CopyStr(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 4),
                            1, 30));

                    // Column 5: Agency Name
                    NormalSales.Validate(
                        "Agency Name",
                        CopyStr(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 5),
                            1, 100));

                    // Column 6: Ref No./AQ Number
                    NormalSales.Validate(
                        "Ref No./AQ Number",
                        RefNoValue);

                    // Column 7: Select
                    NormalSales.Validate(
                        "Select",
                        GetBooleanValue(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 7),
                            RowNo,
                            'Select'));

                    // Column 8: Sales Invoice Created
                    NormalSales.Validate(
                        "Sales Invoice Created",
                        GetBooleanValue(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 8),
                            RowNo,
                            'Sales Invoice Created'));

                    // Column 9: PNR
                    NormalSales.Validate(
                        PNR,
                        CopyStr(PNRValue, 1, 10));

                    // Columns 10-12:
                    // Passenger details stored separately

                    // Column 13: Pax
                    NormalSales.Validate(
                        Pax,
                        GetIntegerValue(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 13),
                            RowNo,
                            'Pax'));

                    // Column 14: Travel Date
                    NormalSales.Validate(
                        "Travel Date",
                        GetDateTimeValue(
                            TempExcelBuffer, RowNo, 14));

                    // Column 15: Sector
                    NormalSales.Validate(
                        Sector,
                        CopyStr(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 15),
                            1, 200));

                    // Column 16: Type
                    NormalSales.Validate(
                        Type,
                        CopyStr(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 16),
                            1, 50));

                    // Column 17: Base Fare
                    NormalSales.Validate(
                        "Base Fare",
                        GetDecimalValue(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 17),
                            RowNo,
                            'Base Fare'));

                    // Column 18: Other Charges
                    NormalSales.Validate(
                        "Other Charges",
                        GetDecimalValue(
                            GetCellValue(
                                TempExcelBuffer, RowNo, 18),
                            RowNo,
                            'Other Charges'));

                    // Excel financial fields are authoritative: never calculate.
                    NormalSales.Validate("Taxable Basis", GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 19), RowNo, 'Taxable Basis'));
                    NormalSales.Validate(CGST, GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 20), RowNo, 'CGST'));
                    NormalSales.Validate(SGST, GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 21), RowNo, 'SGST'));
                    NormalSales.Validate(IGST, GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 22), RowNo, 'IGST'));
                    NormalSales.Validate("Total Amount", GetDecimalValue(
                        GetCellValue(TempExcelBuffer, RowNo, 23), RowNo, 'Total Amount'));

                    // Insert main Normal Sales record
                    NormalSales.Insert(true);

                    // Insert passengers separately
                    if PassengerNamesValue <> '' then
                        ImportPassengerNames(
                            RefNoValue,
                            CopyStr(PNRValue, 1, 10),
                            PassengerNamesValue,
                            PassengerIDsValue,
                            PassengerTypesValue);

                    ImportedCount += 1;
                end;
            end else
                SkippedCount += 1;
        end;

        Message(
            'Own Sales Excel import completed.\' +
            'Imported: %1\' +
            'Duplicate AQ Number: %2\' +
            'Skipped (blank PNR): %3',
            ImportedCount,
            DuplicateCount,
            SkippedCount);
    end;

    local procedure CheckHeaders(
        var TempExcelBuffer: Record "Excel Buffer" temporary)
    var
        Headers: List of [Text];
        Expected: Text;
        Actual: Text;
        ColNo: Integer;
    begin
        Headers.Add('Serial No.');
        Headers.Add('Date');
        Headers.Add('Invoice Number');
        Headers.Add('Agency ID');
        Headers.Add('Agency Name');
        Headers.Add('Ref No./AQ Number');
        Headers.Add('Select');
        Headers.Add('Sales Invoice Created');
        Headers.Add('PNR');
        Headers.Add('View Passenger');
        Headers.Add('Passenger ID');
        Headers.Add('Passenger Type');
        Headers.Add('Pax');
        Headers.Add('Travel Date');
        Headers.Add('Sector');
        Headers.Add('Type');
        Headers.Add('Base Fare');
        Headers.Add('Other Charges');
        Headers.Add('Taxable Basis');
        Headers.Add('CGST');
        Headers.Add('SGST');
        Headers.Add('IGST');
        Headers.Add('Total Amount');

        ColNo := 0;

        foreach Expected in Headers do begin
            ColNo += 1;

            Actual := DelChr(
                GetCellValue(
                    TempExcelBuffer, 1, ColNo),
                '<>', ' ');

            if UpperCase(Actual) <> UpperCase(Expected) then
                Error(
                    'Excel header mismatch at column %1. Expected "%2", found "%3".',
                    ColNo, Expected, Actual);
        end;
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
        NormalizedValue :=
            UpperCase(DelChr(ValueText, '=', ' '));

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

        if Evaluate(DecimalValue, ValueText, 9) then
            exit(DecimalValue);

        if Evaluate(DecimalValue, ValueText) then
            exit(DecimalValue);

        Error(
            'Invalid %1 at Excel row %2: %3',
            FieldName,
            RowNo,
            ValueText);
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
            GetCellValue(
                TempExcelBuffer, RowNo, ColumnNo),
            '<>', ' ');

        if CellValue = '' then
            exit(0DT);

        if Evaluate(ParsedDateTime, CellValue) then
            exit(ParsedDateTime);

        if Evaluate(ParsedDateTime, CellValue, 9) then
            exit(ParsedDateTime);

        if Evaluate(ParsedDate, CellValue) then
            exit(CreateDateTime(ParsedDate, 000000T));

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
            Result.Add(
                DelChr(Part, '<>', ' '));

        exit(Result);
    end;

    [TryFunction]
    local procedure TryCheckPassengerRow(PaxText: Text; NamesText: Text; IDsText: Text; TypesText: Text; RowNo: Integer; LinkNo: BigInteger; PNRValue: Text[10])
    var
        PaxValue: Integer;
        PaxValidation: Codeunit "AIRIQ Pax Validation";
        ExistingPassenger: Record "Own Sales Passenger Name";
        Names: List of [Text];
    begin
        if not Evaluate(PaxValue, PaxText) then
            Error('Invalid or blank PAX.');
        CheckPassengers(NamesText, IDsText, TypesText, RowNo);
        Names := SplitValues(NamesText);
        PaxValidation.CheckExactCount(PaxValue, Names.Count());
        ExistingPassenger.SetRange("Ref No./AQ Number", LinkNo);
        ExistingPassenger.SetRange(PNR, PNRValue);
        if not ExistingPassenger.IsEmpty() then
            Error('Passenger records already exist for this reference and PNR. Resolve existing records before importing.');
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
           (Names.Count() <> Types.Count())
        then
            Error(
                'Passenger count mismatch at Excel row %1: Names=%2, IDs=%3, Types=%4.',
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
               (TypeValue = '')
            then
                Error(
                    'Blank Passenger Name, ID or Type at Excel row %1, passenger %2.',
                    RowNo, I);

            if StrLen(NameValue) > 100 then
                Error(
                    'Passenger Name too long at Excel row %1, passenger %2.',
                    RowNo, I);

            if StrLen(TypeValue) > 50 then
                Error(
                    'Passenger Type too long at Excel row %1, passenger %2.',
                    RowNo, I);

            if not Evaluate(NumericID, IDValue) then
                Error(
                    'Invalid Passenger ID "%1" at Excel row %2, passenger %3.',
                    IDValue, RowNo, I);

            if NumericID <= 0 then
                Error('Passenger ID must be greater than 0 at Excel row %1, passenger %2.', RowNo, I);
        end;
    end;

    local procedure ImportPassengerNames(
        RefNo: BigInteger;
        PNRCode: Text[10];
        NamesText: Text;
        IDsText: Text;
        TypesText: Text)
    var
        Passenger: Record "Own Sales Passenger Name";
        ExistingPassenger: Record "Own Sales Passenger Name";
        Names: List of [Text];
        IDs: List of [Text];
        Types: List of [Text];
        NameValue: Text;
        IDValue: Text;
        TypeValue: Text;
        SLNo: Integer;
        I: Integer;
    begin
        Names := SplitValues(NamesText);
        IDs := SplitValues(IDsText);
        Types := SplitValues(TypesText);

        if Names.Count() = 0 then
            exit;

        Passenger.LockTable();

        ExistingPassenger.Reset();
        ExistingPassenger.SetCurrentKey("SL No.");

        if ExistingPassenger.FindLast() then
            SLNo := ExistingPassenger."SL No." + 1
        else
            SLNo := 1;

        for I := 1 to Names.Count() do begin
            Names.Get(I, NameValue);
            IDs.Get(I, IDValue);
            Types.Get(I, TypeValue);

            Passenger.Init();

            Passenger."Ref No./AQ Number" := RefNo;
            Passenger.PNR := PNRCode;
            Passenger."SL No." := SLNo;

            Passenger."Passenger Name" :=
                CopyStr(
                    NameValue,
                    1,
                    MaxStrLen(Passenger."Passenger Name"));

            if not Evaluate(Passenger.ID, IDValue) then
                Error(
                    'Invalid Passenger ID at AQ Number %1, passenger %2.',
                    RefNo, I);

            Passenger.Type :=
                CopyStr(
                    TypeValue,
                    1,
                    MaxStrLen(Passenger.Type));

            Passenger.Insert(true);

            SLNo += 1;
        end;
    end;
}
