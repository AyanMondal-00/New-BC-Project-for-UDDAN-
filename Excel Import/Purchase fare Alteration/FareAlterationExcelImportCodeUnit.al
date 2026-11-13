
codeunit 50342 "Fare Alteration Import"
{
    procedure ImportFareAlteration()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UploadInStream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        PNRColumnNo: Integer;
        RateColumnNo: Integer;
        BaseFareColumnNo: Integer;
        OtherChargesColumnNo: Integer;
        TotalAmountColumnNo: Integer;
        LastRowNo: Integer;
        UpdatedCount: Integer;
        SkippedCount: Integer;
        SamplePurchase: Record "Sample Purchase";
        PNRValue: Text;
    begin
        if not UploadIntoStream(
            'Select Fare Alteration Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            UploadInStream)
        then
            exit;

        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();

        TempExcelBuffer.OpenBookStream(UploadInStream, '');
        SheetName := TempExcelBuffer.SelectSheetsNameStream(UploadInStream);
        TempExcelBuffer.OpenBookStream(UploadInStream, SheetName);
        TempExcelBuffer.ReadSheet();

        // Find the required columns from the header row.
        PNRColumnNo := FindHeaderColumn(TempExcelBuffer, 'PNR');
        RateColumnNo := FindHeaderColumn(TempExcelBuffer, 'Rate');
        BaseFareColumnNo := FindHeaderColumn(TempExcelBuffer, 'Base Fare');
        OtherChargesColumnNo := FindHeaderColumn(TempExcelBuffer, 'Other Charges');
        TotalAmountColumnNo := FindHeaderColumn(TempExcelBuffer, 'Total Amount');

        if (PNRColumnNo = 0) or
           (RateColumnNo = 0) or
           (BaseFareColumnNo = 0) or
           (OtherChargesColumnNo = 0) or
           (TotalAmountColumnNo = 0)
        then
            Error(
                'Required Excel headers are missing. Required headers: PNR, Rate, Base Fare, Other Charges, Total Amount.');

        LastRowNo := GetLastRowNo(TempExcelBuffer);

        for RowNo := 2 to LastRowNo do begin
            PNRValue := UpperCase(
                GetCellValue(TempExcelBuffer, RowNo, PNRColumnNo));

            if PNRValue <> '' then begin
                SamplePurchase.Reset();
                SamplePurchase.SetRange(PNR, PNRValue);

                if SamplePurchase.FindFirst() then begin
                    SamplePurchase.Validate(
                        Rate,
                        GetDecimalValue(
                            TempExcelBuffer, RowNo, RateColumnNo));

                    SamplePurchase.Validate(
                        "Base Fare",
                        GetDecimalValue(
                            TempExcelBuffer, RowNo, BaseFareColumnNo));

                    SamplePurchase.Validate(
                        "Other Charges",
                        GetDecimalValue(
                            TempExcelBuffer, RowNo, OtherChargesColumnNo));

                    SamplePurchase.Validate(
                        "Total Amount",
                        GetDecimalValue(
                            TempExcelBuffer, RowNo, TotalAmountColumnNo));

                    SamplePurchase.Modify(true);
                    UpdatedCount += 1;
                end else
                    SkippedCount += 1;
            end;
        end;

        Message(
            'Fare alteration import completed.\Updated records: %1\Skipped records (PNR not found): %2',
            UpdatedCount,
            SkippedCount);
    end;

    local procedure FindHeaderColumn(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        HeaderText: Text): Integer
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.Copy(TempExcelBuffer, true);
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", 1);

        if ExcelBuffer.FindSet() then
            repeat
                if UpperCase(DelChr(ExcelBuffer."Cell Value as Text", '<>', ' ')) =
                   UpperCase(DelChr(HeaderText, '<>', ' '))
                then
                    exit(ExcelBuffer."Column No.");
            until ExcelBuffer.Next() = 0;

        exit(0);
    end;

    local procedure GetCellValue(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Text
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.Copy(TempExcelBuffer, true);
        ExcelBuffer.Reset();
        ExcelBuffer.SetRange("Row No.", RowNo);
        ExcelBuffer.SetRange("Column No.", ColumnNo);

        if ExcelBuffer.FindFirst() then
            exit(ExcelBuffer."Cell Value as Text");

        exit('');
    end;

    local procedure GetDecimalValue(
        var TempExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer;
        ColumnNo: Integer): Decimal
    var
        CellValue: Text;
        DecimalValue: Decimal;
    begin
        CellValue := GetCellValue(TempExcelBuffer, RowNo, ColumnNo);

        if CellValue = '' then
            exit(0);

        if not Evaluate(DecimalValue, CellValue) then
            Error(
                'Invalid decimal value "%1" at Excel row %2, column %3.',
                CellValue, RowNo, ColumnNo);

        exit(DecimalValue);
    end;

    local procedure GetLastRowNo(
        var TempExcelBuffer: Record "Excel Buffer" temporary): Integer
    begin
        TempExcelBuffer.Reset();
        TempExcelBuffer.SetCurrentKey("Row No.");

        if TempExcelBuffer.FindLast() then
            exit(TempExcelBuffer."Row No.");

        exit(0);
    end;
}
