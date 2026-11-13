
codeunit 50472 "AIRIQ Bank Payment Import"
{
    procedure ImportExcel(
        TemplateName: Code[10];
        BatchName: Code[10])
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        ExistingLine: Record "Gen. Journal Line";
        FileName: Text;
        SheetName: Text;
        FileStream: InStream;
        RowNo: Integer;
        LastRow: Integer;
        NextLineNo: Integer;
        ImportedCount: Integer;
        DuplicateCount: Integer;
        SkippedCount: Integer;
        DocumentNo: Code[20];
        PostingDate: Date;
        ChequeDate: Date;
        CellText: Text;
        AmountValue: Decimal;
    begin
        if TemplateName = '' then
            Error('Journal Template Name is required.');

        if BatchName = '' then
            Error('Journal Batch Name is required.');

        if not UploadIntoStream(
            'Select Bank Payment Voucher Excel',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            FileStream)
        then
            exit;

        SheetName :=
            ExcelBuffer.SelectSheetsNameStream(FileStream);

        if SheetName = '' then
            exit;

        ExcelBuffer.OpenBookStream(FileStream, SheetName);
        ExcelBuffer.ReadSheet();
        ExcelBuffer.CloseBook();

        ValidateHeaders(ExcelBuffer);

        ExcelBuffer.Reset();

        if ExcelBuffer.FindLast() then
            LastRow := ExcelBuffer."Row No."
        else
            Error('Excel file is empty.');

        ExistingLine.Reset();
        ExistingLine.SetRange(
            "Journal Template Name", TemplateName);
        ExistingLine.SetRange(
            "Journal Batch Name", BatchName);

        if ExistingLine.FindLast() then
            NextLineNo := ExistingLine."Line No."
        else
            NextLineNo := 0;

        ImportedCount := 0;
        DuplicateCount := 0;
        SkippedCount := 0;

        for RowNo := 2 to LastRow do begin

            DocumentNo := CopyStr(
                GetCellValue(ExcelBuffer, RowNo, 4),
                1, 20);

            if DocumentNo = '' then
                SkippedCount += 1
            else begin

                ExistingLine.Reset();
                ExistingLine.SetRange(
                    "Journal Template Name", TemplateName);
                ExistingLine.SetRange(
                    "Journal Batch Name", BatchName);
                ExistingLine.SetRange(
                    "Document No.", DocumentNo);

                if not ExistingLine.IsEmpty() then
                    DuplicateCount += 1
                else begin

                    NextLineNo += 10000;

                    Clear(GenJournalLine);
                    GenJournalLine.Init();

                    GenJournalLine.Validate(
                        "Journal Template Name", TemplateName);

                    GenJournalLine.Validate(
                        "Journal Batch Name", BatchName);

                    GenJournalLine."Line No." := NextLineNo;

                    // Posting Date - Column 2
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 2);

                    if CellText <> '' then begin
                        PostingDate := ParseExcelDate(CellText);
                        GenJournalLine.Validate(
                            "Posting Date", PostingDate);
                    end;

                    // Document Type - Column 3
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 3);

                    case UpperCase(CellText) of
                        'PAYMENT':
                            GenJournalLine.Validate(
                                "Document Type",
                                GenJournalLine."Document Type"::Payment);
                        'REFUND':
                            GenJournalLine.Validate(
                                "Document Type",
                                GenJournalLine."Document Type"::Refund);
                        'INVOICE':
                            GenJournalLine.Validate(
                                "Document Type",
                                GenJournalLine."Document Type"::Invoice);
                        'CREDIT MEMO':
                            GenJournalLine.Validate(
                                "Document Type",
                                GenJournalLine."Document Type"::"Credit Memo");
                        else
                            if CellText <> '' then
                                Error(
                                    'Invalid Document Type %1 at row %2.',
                                    CellText, RowNo);
                    end;

                    // Document No. - Column 4
                    GenJournalLine.Validate(
                        "Document No.", DocumentNo);

                    // Account Type - Column 5
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 5);

                    case UpperCase(CellText) of
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::Vendor);
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::Customer);
                        'G/L ACCOUNT':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"G/L Account");
                        'BANK ACCOUNT':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"Bank Account");
                        else
                            Error(
                                'Invalid Account Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Account No. - Column 6
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 6);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Account No.",
                            CopyStr(CellText, 1, 20));

                    // Location Code - Column 21
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 21);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Location Code",
                            CopyStr(CellText, 1, 10));

                    // Description - Column 23
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 23);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            Description,
                            CopyStr(CellText, 1, 100));

                    // Currency Code - Column 28
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 28);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Currency Code",
                            CopyStr(CellText, 1, 10));

                    // Bal. Account Type - Column 37
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 37);

                    case UpperCase(CellText) of
                        'BANK ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"Bank Account");
                        'G/L ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"G/L Account");
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Vendor);
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Customer);
                        else
                            if CellText <> '' then
                                Error(
                                    'Invalid Bal. Account Type %1 at row %2.',
                                    CellText, RowNo);
                    end;

                    // Bal. Account No. - Column 38
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 38);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Bal. Account No.",
                            CopyStr(CellText, 1, 20));

                    // Amount - Column 35
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 35);

                    if CellText <> '' then begin
                        if not Evaluate(AmountValue, CellText) then
                            Error(
                                'Invalid Amount %1 at row %2.',
                                CellText, RowNo);

                        GenJournalLine.Validate(
                            Amount, AmountValue);
                    end;

                    // Bank Payment Type - Column 43
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 43);

                    case UpperCase(CellText) of
                        'MANUAL CHECK':
                            GenJournalLine.Validate(
                                "Bank Payment Type",
                                GenJournalLine."Bank Payment Type"::"Manual Check");
                        'COMPUTER CHECK':
                            GenJournalLine.Validate(
                                "Bank Payment Type",
                                GenJournalLine."Bank Payment Type"::"Computer Check");
                        else
                            if CellText <> '' then
                                Error(
                                    'Invalid Bank Payment Type %1 at row %2.',
                                    CellText, RowNo);
                    end;

                    // Cheque No. - Column 44
                    // Cheque No.1 (Column 49) ignored
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 44);

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Cheque No.",
                            CopyStr(CellText, 1, 10));

                    // Cheque Date - Column 45
                    CellText :=
                        GetCellValue(ExcelBuffer, RowNo, 45);

                    if CellText <> '' then begin
                        ChequeDate := ParseExcelDate(CellText);

                        GenJournalLine.Validate(
                            "Cheque Date", ChequeDate);
                    end;

                    // Standard BC validation will calculate
                    // Amount (LCY) and account display names.

                    GenJournalLine.Insert(true);
                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Bank Payment Voucher Import Completed!\Imported: %1\Duplicates Skipped: %2\Empty Rows Skipped: %3',
            ImportedCount,
            DuplicateCount,
            SkippedCount);
    end;

    local procedure GetCellValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Text
    begin
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ColumnNo);

        if ExcelBuffer.FindFirst() then
            exit(DelChr(
                ExcelBuffer."Cell Value as Text", '<>', ' '));

        exit('');
    end;

    local procedure ParseExcelDate(DateText: Text): Date
    var
        ParsedDate: Date;
        ParsedDateTime: DateTime;
        NumericDate: Decimal;
        ExcelBaseDate: Date;
    begin
        if Evaluate(ParsedDate, DateText) then
            exit(ParsedDate);

        if Evaluate(ParsedDateTime, DateText) then
            exit(DT2Date(ParsedDateTime));

        if Evaluate(NumericDate, DateText) then begin
            ExcelBaseDate := DMY2Date(30, 12, 1899);
            exit(ExcelBaseDate + Round(NumericDate, 1, '<'));
        end;

        Error('Invalid Excel Date: %1', DateText);
    end;

    local procedure ValidateHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    begin
        CheckHeader(ExcelBuffer, 1, 'Batch Name');
        CheckHeader(ExcelBuffer, 2, 'Posting Date');
        CheckHeader(ExcelBuffer, 3, 'Document Type');
        CheckHeader(ExcelBuffer, 4, 'Document No.');
        CheckHeader(ExcelBuffer, 5, 'Account Type');
        CheckHeader(ExcelBuffer, 6, 'Account No.');
        CheckHeader(ExcelBuffer, 21, 'Location Code');
        CheckHeader(ExcelBuffer, 23, 'Description');
        CheckHeader(ExcelBuffer, 35, 'Amount');
        CheckHeader(ExcelBuffer, 37, 'Bal. Account Type');
        CheckHeader(ExcelBuffer, 38, 'Bal. Account No.');
        CheckHeader(ExcelBuffer, 43, 'Bank Payment Type');
        CheckHeader(ExcelBuffer, 44, 'Cheque No.');
        CheckHeader(ExcelBuffer, 45, 'Cheque Date');
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
           UpperCase(ExpectedHeader) then
            Error(
                'Invalid Excel format at column %1. Expected: %2. Found: %3.',
                ColumnNo,
                ExpectedHeader,
                ActualHeader);
    end;
}
