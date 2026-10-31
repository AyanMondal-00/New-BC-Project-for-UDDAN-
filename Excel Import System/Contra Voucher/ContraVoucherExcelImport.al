
namespace AIRIQ.ContraVoucher;

using System.IO;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 50478 "AIRIQ Contra Voucher Import"
{
    procedure ImportExcel(
        TemplateName: Code[10];
        BatchName: Code[10])
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        ExistingLine: Record "Gen. Journal Line";
        JournalBatch: Record "Gen. Journal Batch";
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
        CellText: Text;
        AmountValue: Decimal;
        ExcelBatch: Text;
    begin
        if TemplateName = '' then
            Error('Journal Template Name is required.');

        if BatchName = '' then
            Error('Journal Batch Name is required.');

        JournalBatch.Get(TemplateName, BatchName);

        if not UploadIntoStream(
            'Select Contra Voucher Excel',
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

        CheckRequiredHeaders(ExcelBuffer);

        ExcelBuffer.Reset();

        if ExcelBuffer.FindLast() then
            LastRow := ExcelBuffer."Row No."
        else
            Error('Excel file is empty.');

        if LastRow < 2 then
            Error('No data rows found in Excel.');

        ExistingLine.Reset();
        ExistingLine.SetRange(
            "Journal Template Name", TemplateName);
        ExistingLine.SetRange(
            "Journal Batch Name", BatchName);
        ExistingLine.SetCurrentKey(
            "Journal Template Name",
            "Journal Batch Name",
            "Line No.");

        if ExistingLine.FindLast() then
            NextLineNo := ExistingLine."Line No."
        else
            NextLineNo := 0;

        ImportedCount := 0;
        DuplicateCount := 0;
        SkippedCount := 0;

        for RowNo := 2 to LastRow do begin
            DocumentNo := CopyStr(
                GetValue(ExcelBuffer, RowNo, 'Document No.'),
                1, 20);

            if DocumentNo = '' then
                SkippedCount += 1
            else begin
                // Validate Excel Batch
                ExcelBatch := GetValue(
                    ExcelBuffer, RowNo, 'Batch Name');

                if (ExcelBatch <> '') and
                   (UpperCase(ExcelBatch) <> UpperCase(BatchName)) then
                    Error(
                        'Excel Batch %1 does not match selected Batch %2 at row %3.',
                        ExcelBatch, BatchName, RowNo);

                // Duplicate Check
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

                    // Posting Date
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Posting Date');

                    if CellText = '' then
                        Error(
                            'Posting Date is required at row %1.',
                            RowNo);

                    GenJournalLine.Validate(
                        "Posting Date",
                        ParseExcelDate(CellText));

                    // Document Type (Blank allowed)
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Document Type'));

                    case CellText of
                        '':
                            GenJournalLine.Validate(
                                "Document Type",
                                GenJournalLine."Document Type"::" ");
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
                            Error(
                                'Invalid Document Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Document No.
                    GenJournalLine.Validate(
                        "Document No.", DocumentNo);

                    // Account Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Account Type'));

                    case CellText of
                        'G/L ACCOUNT':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"G/L Account");
                        'BANK ACCOUNT':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"Bank Account");
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::Customer);
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::Vendor);
                        'FIXED ASSET':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"Fixed Asset");
                        else
                            Error(
                                'Invalid Account Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Account No.
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Account No.');

                    if CellText = '' then
                        Error(
                            'Account No. is required at row %1.',
                            RowNo);

                    GenJournalLine.Validate(
                        "Account No.",
                        CopyStr(CellText, 1, 20));

                    // Location Code
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Location Code');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Location Code",
                            CopyStr(CellText, 1, 10));

                    // Description
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Description');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            Description,
                            CopyStr(CellText, 1, 100));

                    // Currency Code
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Currency Code');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Currency Code",
                            CopyStr(CellText, 1, 10));

                    // Bal. Account Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Bal. Account Type'));

                    case CellText of
                        'BANK ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"Bank Account");
                        'G/L ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"G/L Account");
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Customer);
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Vendor);
                        'FIXED ASSET':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"Fixed Asset");
                        '':
                            ;
                        else
                            Error(
                                'Invalid Bal. Account Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Bal. Account No.
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Bal. Account No.');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Bal. Account No.",
                            CopyStr(CellText, 1, 20));

                    // Amount (preserve sign)
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Amount');

                    if CellText = '' then
                        Error(
                            'Amount is required at row %1.',
                            RowNo);

                    if not Evaluate(AmountValue, CellText) then
                        Error(
                            'Invalid Amount %1 at row %2.',
                            CellText, RowNo);

                    GenJournalLine.Validate(
                        Amount, AmountValue);

                    // Cheque No.
                    // Cheque No.1 intentionally ignored
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Cheque No.');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Cheque No.",
                            CopyStr(CellText, 1, 10));

                    // Cheque Date
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Cheque Date');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Cheque Date",
                            ParseExcelDate(CellText));

                    GenJournalLine.Insert(true);
                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Contra Voucher Import Completed!\Imported: %1\Duplicates Skipped: %2\Empty Rows Skipped: %3',
            ImportedCount,
            DuplicateCount,
            SkippedCount);
    end;

    local procedure GetValue(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        HeaderName: Text): Text
    var
        ColumnNo: Integer;
    begin
        ColumnNo := FindColumn(ExcelBuffer, HeaderName);

        if ColumnNo = 0 then
            exit('');

        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ColumnNo);

        if ExcelBuffer.FindFirst() then
            exit(
                DelChr(
                    ExcelBuffer."Cell Value as Text",
                    '<>', ' '));

        exit('');
    end;

    local procedure FindColumn(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        HeaderName: Text): Integer
    begin
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", 1);

        if ExcelBuffer.FindSet() then
            repeat
                if UpperCase(
                    DelChr(
                        ExcelBuffer."Cell Value as Text",
                        '<>', ' '))
                    = UpperCase(HeaderName) then
                    exit(ExcelBuffer."Column No.");
            until ExcelBuffer.Next() = 0;

        exit(0);
    end;

    local procedure CheckRequiredHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    begin
        RequireHeader(ExcelBuffer, 'Batch Name');
        RequireHeader(ExcelBuffer, 'Posting Date');
        RequireHeader(ExcelBuffer, 'Document Type');
        RequireHeader(ExcelBuffer, 'Document No.');
        RequireHeader(ExcelBuffer, 'Account Type');
        RequireHeader(ExcelBuffer, 'Account No.');
        RequireHeader(ExcelBuffer, 'Location Code');
        RequireHeader(ExcelBuffer, 'Description');
        RequireHeader(ExcelBuffer, 'Amount');
        RequireHeader(ExcelBuffer, 'Bal. Account Type');
        RequireHeader(ExcelBuffer, 'Bal. Account No.');
        RequireHeader(ExcelBuffer, 'Cheque No.');
        RequireHeader(ExcelBuffer, 'Cheque Date');
    end;

    local procedure RequireHeader(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        HeaderName: Text)
    begin
        if FindColumn(ExcelBuffer, HeaderName) = 0 then
            Error(
                'Required Excel header not found: %1',
                HeaderName);
    end;

    local procedure ParseExcelDate(DateText: Text): Date
    var
        ParsedDate: Date;
        ParsedDateTime: DateTime;
        NumericDate: Decimal;
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        DatePart: Text;
    begin
        DatePart := CopyStr(DateText, 1, 10);

        if (StrLen(DatePart) = 10) and
           (CopyStr(DatePart, 3, 1) = '-') and
           (CopyStr(DatePart, 6, 1) = '-') then begin
            if Evaluate(DayNo, CopyStr(DatePart, 1, 2)) and
               Evaluate(MonthNo, CopyStr(DatePart, 4, 2)) and
               Evaluate(YearNo, CopyStr(DatePart, 7, 4)) then
                exit(DMY2Date(DayNo, MonthNo, YearNo));
        end;

        if Evaluate(ParsedDate, DateText) then
            exit(ParsedDate);

        if Evaluate(ParsedDateTime, DateText) then
            exit(DT2Date(ParsedDateTime));

        if Evaluate(NumericDate, DateText) then
            exit(
                DMY2Date(30, 12, 1899) +
                Round(NumericDate, 1, '<'));

        Error('Invalid Excel Date: %1', DateText);
    end;
}
