codeunit 50333 "Sales Return Excel Import"
{
    procedure ImportFromExcel()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        SalesReturn: Record "Sales Return";
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

            // Skip blank rows
            if (GetCellText(ExcelBuffer, RowNo, 3) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 4) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 5) <> '') or
               (GetCellText(ExcelBuffer, RowNo, 7) <> '') then begin

                SalesReturn.Init();

                // Serial No. - Generate automatically
                SalesReturn.Reset();
                if SalesReturn.FindLast() then
                    SalesReturn."Serial No." := SalesReturn."Serial No." + 1
                else
                    SalesReturn."Serial No." := 1;

                // Column 2: Entry Date
                CellValue := GetCellText(ExcelBuffer, RowNo, 2);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Entry Date", CellValue);

                // Column 3: Bill No.
                SalesReturn."Bill No." :=
                    GetCellText(ExcelBuffer, RowNo, 3);

                // Column 4: Invoice No.
                SalesReturn."Invoice No." :=
                    GetCellText(ExcelBuffer, RowNo, 4);

                // Column 5: Return No.
                SalesReturn."Return No." :=
                    GetCellText(ExcelBuffer, RowNo, 5);

                // Column 6: Agency ID
                SalesReturn."Agency ID" :=
                    GetCellText(ExcelBuffer, RowNo, 6);

                // Column 7: A/C Name
                SalesReturn."A/C Name" :=
                    GetCellText(ExcelBuffer, RowNo, 7);

                // Column 8: Country
                SalesReturn.Country :=
                    GetCellText(ExcelBuffer, RowNo, 8);

                // Column 9: State
                SalesReturn.State :=
                    GetCellText(ExcelBuffer, RowNo, 9);

                // Column 10: City
                SalesReturn.City :=
                    GetCellText(ExcelBuffer, RowNo, 10);

                // Column 11: Sector
                SalesReturn.Sector :=
                    GetCellText(ExcelBuffer, RowNo, 11);

                // Column 12: Type
                SalesReturn.Type :=
                    GetCellText(ExcelBuffer, RowNo, 12);

                // Column 13: Travel Date
                CellValue := GetCellText(ExcelBuffer, RowNo, 13);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Travel Date", CellValue);

                // Column 14: Time
                CellValue := GetCellText(ExcelBuffer, RowNo, 14);
                if CellValue <> '' then
                    Evaluate(SalesReturn.Time, CellValue);

                // Column 15: Airline
                SalesReturn.Airline :=
                    GetCellText(ExcelBuffer, RowNo, 15);

                // Column 16: Airline Code
                SalesReturn."Airline Code" :=
                    GetCellText(ExcelBuffer, RowNo, 16);

                // Column 17: PNR
                SalesReturn.PNR :=
                    GetCellText(ExcelBuffer, RowNo, 17);

                // Column 18: Reference
                SalesReturn.Reference :=
                    GetCellText(ExcelBuffer, RowNo, 18);

                // Column 19: Narration
                SalesReturn.Narration :=
                    GetCellText(ExcelBuffer, RowNo, 19);

                // Column 20: PAX
                CellValue := GetCellText(ExcelBuffer, RowNo, 20);
                if CellValue <> '' then
                    Evaluate(SalesReturn.PAX, CellValue);

                // Column 21: Base Fare
                CellValue := GetCellText(ExcelBuffer, RowNo, 21);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Base Fare", CellValue);

                // Column 22: Taxable Value
                CellValue := GetCellText(ExcelBuffer, RowNo, 22);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Taxable Value", CellValue);

                // Column 23: CGST
                CellValue := GetCellText(ExcelBuffer, RowNo, 23);
                if CellValue <> '' then
                    Evaluate(SalesReturn.CGST, CellValue);

                // Column 24: SGST
                CellValue := GetCellText(ExcelBuffer, RowNo, 24);
                if CellValue <> '' then
                    Evaluate(SalesReturn.SGST, CellValue);

                // Column 25: IGST
                CellValue := GetCellText(ExcelBuffer, RowNo, 25);
                if CellValue <> '' then
                    Evaluate(SalesReturn.IGST, CellValue);

                // Column 26: Sold Value
                CellValue := GetCellText(ExcelBuffer, RowNo, 26);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Sold Value", CellValue);

                // Column 27: XXLН Charges
                CellValue := GetCellText(ExcelBuffer, RowNo, 27);
                if CellValue <> '' then
                    Evaluate(SalesReturn."XXLN Charges", CellValue);

                // Column 28: Refund Amount
                CellValue := GetCellText(ExcelBuffer, RowNo, 28);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Refund Amount", CellValue);

                // Column 29: Sale Type
                CellValue := GetCellText(ExcelBuffer, RowNo, 29);
                if CellValue <> '' then
                    Evaluate(SalesReturn."Sale Type", CellValue);

                // Column 30: Supplier
                SalesReturn.Supplier :=
                    GetCellText(ExcelBuffer, RowNo, 30);

                SalesReturn.Insert(true);
            end;
        end;

        Message('Sales Return Excel Import Completed.');
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