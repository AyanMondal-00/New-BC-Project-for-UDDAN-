codeunit 50332 "Purchase Return Excel Import"
{
    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        PurchaseReturn: Record "Purchase Return";
        InStream: InStream;
        FileName: Text;
        SheetName: Text;
        LastRow: Integer;
        RowNo: Integer;
        CellValue: Text;
    begin
        if not UploadIntoStream(
            'Select Excel File',
            '',
            'Excel Files (*.xlsx)|*.xlsx',
            FileName,
            InStream)
        then
            exit;

        ExcelBuffer.OpenBookStream(InStream, SheetName);
        ExcelBuffer.ReadSheet();

        ExcelBuffer.Reset();
        if ExcelBuffer.FindLast() then
            LastRow := ExcelBuffer."Row No.";

        for RowNo := 2 to LastRow do begin

            // Skip completely blank rows
            if (GetCellText(ExcelBuffer, RowNo, 1) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 4) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 5) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 11) <> '')
            then begin

                PurchaseReturn.Init();

                // Column 1: Serial No. - generated automatically by OnInsert

                // Column 2: Entry Date
                CellValue := GetCellText(ExcelBuffer, RowNo, 2);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Entry Date", CellValue);

                // Column 3: Purchase Date
                CellValue := GetCellText(ExcelBuffer, RowNo, 3);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Purchase Date", CellValue);

                // Column 4: Voucher Number
                PurchaseReturn."Voucher Number" :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 4), 1, 50);

                // Column 5: Airline
                PurchaseReturn.Airline :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 5), 1, 100);

                // Column 6: Airline ID
                PurchaseReturn."Airline ID" :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 6), 1, 20);

                // Column 7: Airline Code
                PurchaseReturn."Airline Code" :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 7), 1, 20);

                // Column 8: Country
                PurchaseReturn.Country :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 8), 1, 50);

                // Column 9: Type
                PurchaseReturn.Type :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 9), 1, 50);

                // Column 10: Sector
                PurchaseReturn.Sector :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 10), 1, 200);

                // Column 11: PNR
                PurchaseReturn.PNR :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 11), 1, 10);

                // Column 12: Reference
                PurchaseReturn.Reference :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 12), 1, 100);

                // Column 13: Narration
                PurchaseReturn.Narration :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 13), 1, 250);

                // Column 14: Pax
                CellValue := GetCellText(ExcelBuffer, RowNo, 14);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn.Pax, CellValue);

                // Column 15: Base Fare
                CellValue := GetCellText(ExcelBuffer, RowNo, 15);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Base Fare", CellValue);

                // Column 16: Others
                CellValue := GetCellText(ExcelBuffer, RowNo, 16);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn.Others, CellValue);

                // Column 17: Rate
                CellValue := GetCellText(ExcelBuffer, RowNo, 17);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn.Rate, CellValue);

                // Column 18: Discount
                CellValue := GetCellText(ExcelBuffer, RowNo, 18);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn.Discount, CellValue);

                // Column 19: XXLН Charges
                CellValue := GetCellText(ExcelBuffer, RowNo, 19);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."XXLN Charges", CellValue);

                // Column 20: Amount
                CellValue := GetCellText(ExcelBuffer, RowNo, 20);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn.Amount, CellValue);

                // Column 21: Travel Date
                CellValue := GetCellText(ExcelBuffer, RowNo, 21);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Travel Date", CellValue);

                // Column 22: Departure Time
                CellValue := GetCellText(ExcelBuffer, RowNo, 22);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Departure Time", CellValue);

                // Column 23: Arrival Time
                CellValue := GetCellText(ExcelBuffer, RowNo, 23);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Arrival Time", CellValue);

                // Column 24: Flight No.
                PurchaseReturn."Flight No." :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 24), 1, 30);

                // Column 25: Name List
                PurchaseReturn."Name List" :=
                    CopyStr(GetCellText(ExcelBuffer, RowNo, 25), 1, 100);

                // Column 26: Cost Revision
                CellValue := GetCellText(ExcelBuffer, RowNo, 26);
                if CellValue <> '' then
                    Evaluate(PurchaseReturn."Cost Revision", CellValue);

                PurchaseReturn.Insert(true);
            end;
        end;

        Message('Purchase Return Excel Import Completed.');
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