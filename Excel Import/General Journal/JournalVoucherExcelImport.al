
namespace AIRIQ.JournalVoucher;

using System.IO;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 50476 "AIRIQ Journal Voucher Import"
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
            'Select Journal Voucher Excel',
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

                // Batch Validation
                ExcelBatch := GetValue(
                    ExcelBuffer, RowNo, 'Batch Name');

                if (ExcelBatch <> '') and
                   (UpperCase(ExcelBatch) <> UpperCase(BatchName))
                then
                    Error(
                        'Excel Batch %1 does not match selected Batch %2 at row %3.',
                        ExcelBatch, BatchName, RowNo);

                // Duplicate Document No. Check
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

                    // Column 2 - Posting Date
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Posting Date');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Posting Date",
                            ParseExcelDate(CellText));

                    // Column 3 - Document Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Document Type'));

                    case CellText of
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
                        '':
                            ;
                        else
                            Error(
                                'Invalid Document Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Column 4 - Document No.
                    GenJournalLine.Validate(
                        "Document No.", DocumentNo);

                    // Column 5 - Party Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Party Type'));

                    case CellText of
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Party Type",
                                GenJournalLine."Party Type"::Vendor);
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Party Type",
                                GenJournalLine."Party Type"::Customer);
                        '':
                            ;
                        else
                            Error(
                                'Invalid Party Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Column 6 - Party Code
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Party Code');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Party Code",
                            CopyStr(CellText, 1, 20));

                    // Column 7 - Account Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Account Type'));

                    case CellText of
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
                        'FIXED ASSET':
                            GenJournalLine.Validate(
                                "Account Type",
                                GenJournalLine."Account Type"::"Fixed Asset");
                        else
                            Error(
                                'Invalid Account Type %1 at row %2.',
                                CellText, RowNo);
                    end;

                    // Column 8 - Account No.
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Account No.');

                    if CellText = '' then
                        Error(
                            'Account No. is required at row %1.',
                            RowNo);

                    GenJournalLine.Validate(
                        "Account No.",
                        CopyStr(CellText, 1, 20));

                    // Column 18 - Location Code
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Location Code');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Location Code",
                            CopyStr(CellText, 1, 10));

                    // Column 20 - Description
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Description');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            Description,
                            CopyStr(CellText, 1, 100));

                    // Column 21 - Currency Code
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Currency Code');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Currency Code",
                            CopyStr(CellText, 1, 10));

                    // Column 29 - Amount
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

                    // Preserve positive or negative amount
                    GenJournalLine.Validate(
                        Amount, AmountValue);

                    // Column 31 - Bal. Account Type
                    CellText := UpperCase(
                        GetValue(ExcelBuffer, RowNo, 'Bal. Account Type'));

                    case CellText of
                        'G/L ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"G/L Account");
                        'BANK ACCOUNT':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::"Bank Account");
                        'VENDOR':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Vendor);
                        'CUSTOMER':
                            GenJournalLine.Validate(
                                "Bal. Account Type",
                                GenJournalLine."Bal. Account Type"::Customer);
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

                    // Column 32 - Bal. Account No.
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Bal. Account No.');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Bal. Account No.",
                            CopyStr(CellText, 1, 20));

                    // Column 33 - Cheque No.
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Cheque No.');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Cheque No.",
                            CopyStr(CellText, 1, 10));

                    // Column 34 - Cheque Date
                    CellText := GetValue(
                        ExcelBuffer, RowNo, 'Cheque Date');

                    if CellText <> '' then
                        GenJournalLine.Validate(
                            "Cheque Date",
                            ParseExcelDate(CellText));

                    // Save Journal Line
                    GenJournalLine.Insert(true);

                    ImportedCount += 1;
                end;
            end;
        end;

        Message(
            'Journal Voucher Import Completed!\Imported: %1\Duplicates Skipped: %2\Empty Rows Skipped: %3',
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
        ColumnNo := FindColumn(
            ExcelBuffer, HeaderName);

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
                    = UpperCase(HeaderName)
                then
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
        RequireHeader(ExcelBuffer, 'Party Type');
        RequireHeader(ExcelBuffer, 'Party Code');
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

        // DD-MM-YYYY
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

        // Excel Serial Date
        if Evaluate(NumericDate, DateText) then
            exit(
                DMY2Date(30, 12, 1899) +
                Round(NumericDate, 1, '<'));

        Error('Invalid Excel Date: %1', DateText);
    end;
}
