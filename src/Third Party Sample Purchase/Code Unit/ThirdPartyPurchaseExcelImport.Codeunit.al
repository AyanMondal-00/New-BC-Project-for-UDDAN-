codeunit 50663 "TP Purchase Excel Import"
{
    procedure ImportFromExcel()
    var
        Buffer: Record "Excel Buffer" temporary;
        Purchase: Record "Third Party Sample Purchase";
        Stream: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LastRow: Integer;
        Imported: Integer;
        Skipped: Integer;
        Failed: Integer;
        Details: Text;
        Existing: Record "Third Party Sample Purchase";
        RowPNR: Text[10];
    begin
        // The list action can carry a pending page write. Close that transaction
        // before UploadIntoStream and the modal worksheet picker. Each accepted
        // row is then inserted in its own conditional codeunit transaction.
        Commit();
        if not UploadIntoStream('Select Third Party Sample Purchase Excel File', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, Stream) then
            exit;
        SheetName := Buffer.SelectSheetsNameStream(Stream);
        Stream.ResetPosition();
        Buffer.OpenBookStream(Stream, SheetName);
        Buffer.ReadSheet();
        Buffer.Reset();
        if not Buffer.FindLast() then Error('The selected Excel sheet is empty.');
        LastRow := Buffer."Row No.";
        if LastRow < 2 then Error('No data rows found. Row 1 must contain headers.');
        CheckHeaders(Buffer);

        for RowNo := 2 to LastRow do begin
            if IsBlankRow(Buffer, RowNo) then
                Skipped += 1
            else begin
                RowPNR := CopyStr(UpperCase(DelChr(Cell(Buffer, RowNo, 10), '<>', ' ')), 1, MaxStrLen(RowPNR));
                Existing.Reset();
                Existing.SetRange(PNR, RowPNR);
                if (RowPNR <> '') and (not Existing.IsEmpty()) then
                    Skipped += 1
                else begin
                    Clear(Purchase);
                    ClearLastError();
                    if not ParseRow(Buffer, RowNo, Purchase) then begin
                        Failed += 1;
                        Details += StrSubstNo('\Row %1: %2', RowNo, GetLastErrorText());
                    end else begin
                        ClearLastError();
                        if Codeunit.Run(Codeunit::"TP Purchase Import Row", Purchase) then
                            Imported += 1
                        else begin
                            Existing.Reset();
                            Existing.SetRange(PNR, Purchase.PNR);
                            if not Existing.IsEmpty() then
                                Skipped += 1
                            else begin
                                Failed += 1;
                                Details += StrSubstNo('\Row %1: %2', RowNo, GetLastErrorText());
                            end;
                        end;
                    end;
                end;
            end;
        end;
        Message('Third Party Sample Purchase import complete.\Imported: %1\Skipped blank rows: %2\Failed: %3%4', Imported, Skipped, Failed, Details);
    end;

    [TryFunction]
    local procedure ParseRow(var Buffer: Record "Excel Buffer" temporary; RowNo: Integer; var Purchase: Record "Third Party Sample Purchase")
    var
        ImportedSerial: Integer;
        SuppliedTotal: Decimal;
        HasTotal: Boolean;
        Item: Record Item;
        PNRText: Text;
    begin
        Purchase.Init();
        if Cell(Buffer, RowNo, 1) <> '' then
            if not Evaluate(ImportedSerial, Cell(Buffer, RowNo, 1)) then
                Error('Serial No. must be an integer.');
        // Source serial is read for validation, then independently allocated on insert.
        Purchase.Validate("Purchase Date", DateTimeCell(Cell(Buffer, RowNo, 2)));
        Purchase.Validate("Entry Date", DateTimeCell(Cell(Buffer, RowNo, 3)));
        Purchase.Airline := CopyStr(Cell(Buffer, RowNo, 4), 1, MaxStrLen(Purchase.Airline));
        Purchase."Supplier ID" := CopyStr(Cell(Buffer, RowNo, 5), 1, MaxStrLen(Purchase."Supplier ID"));
        Purchase."Select" := BooleanCell(Cell(Buffer, RowNo, 6));
        if BooleanCell(Cell(Buffer, RowNo, 7)) or BooleanCell(Cell(Buffer, RowNo, 8)) then
            Error('Imported invoice status is Yes but no BC invoice reference is available.');
        Purchase."Item Created" := BooleanCell(Cell(Buffer, RowNo, 9));
        PNRText := Cell(Buffer, RowNo, 10);
        if StrLen(PNRText) > MaxStrLen(Purchase.PNR) then Error('PNR exceeds 10 characters.');
        Purchase.Validate(PNR, PNRText);
        Purchase.Validate("Total Pax", IntegerCell(Cell(Buffer, RowNo, 11)));
        Purchase.Validate("Travel Date", DateTimeCell(Cell(Buffer, RowNo, 12)));
        Purchase.Sector := CopyStr(Cell(Buffer, RowNo, 13), 1, MaxStrLen(Purchase.Sector));
        Purchase.Type := CopyStr(Cell(Buffer, RowNo, 14), 1, MaxStrLen(Purchase.Type));
        Purchase.Validate(Rate, DecimalCell(Cell(Buffer, RowNo, 15)));
        HasTotal := Cell(Buffer, RowNo, 16) <> '';
        if HasTotal then begin
            SuppliedTotal := DecimalCell(Cell(Buffer, RowNo, 16));
            if SuppliedTotal <> Purchase."Total Amount" then
                Error('Total Amount %1 does not equal Total Pax × Rate (%2).', SuppliedTotal, Purchase."Total Amount");
        end;
        if Purchase."Item Created" then
            if not Item.Get(Purchase.PNR) then begin
                Item.SetRange(Description, Purchase.PNR);
                if Item.IsEmpty() then
                    Error('Item Created is Yes, but PNR item %1 does not exist.', Purchase.PNR);
            end;
        // OnInsert validates the source inside the per-row codeunit transaction.
        // Calling it here would LockTable before Codeunit.Run and leave a write
        // transaction active in this interactive import procedure.
    end;

    local procedure CheckHeaders(var Buffer: Record "Excel Buffer" temporary)
    var
        Headers: List of [Text];
        Header: Text;
        Col: Integer;
    begin
        Headers.Add('Serial No.'); Headers.Add('Purchase Date'); Headers.Add('Entry Date');
        Headers.Add('Airline'); Headers.Add('Supplier ID'); Headers.Add('Select');
        Headers.Add('Invoice Created'); Headers.Add('Invoice Posted'); Headers.Add('Item Created');
        Headers.Add('PNR'); Headers.Add('Total Pax'); Headers.Add('Travel Date');
        Headers.Add('Sector'); Headers.Add('Type'); Headers.Add('Rate'); Headers.Add('Total Amount');
        for Col := 1 to 16 do begin
            Header := Headers.Get(Col);
            if UpperCase(Cell(Buffer, 1, Col)) <> UpperCase(Header) then
                Error('Column %1 must be "%2" (found "%3").', Col, Header, Cell(Buffer, 1, Col));
        end;
    end;

    local procedure IsBlankRow(var Buffer: Record "Excel Buffer" temporary; RowNo: Integer): Boolean
    var Col: Integer;
    begin
        for Col := 1 to 16 do
            if Cell(Buffer, RowNo, Col) <> '' then exit(false);
        exit(true);
    end;

    local procedure Cell(var Buffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    begin
        if Buffer.Get(RowNo, ColNo) then
            exit(DelChr(Buffer."Cell Value as Text", '<>', ' '));
        exit('');
    end;

    local procedure IntegerCell(Value: Text): Integer
    var Result: Integer;
    begin
        if not Evaluate(Result, Value) then Error('Invalid integer "%1".', Value);
        exit(Result);
    end;

    local procedure DecimalCell(Value: Text): Decimal
    var Result: Decimal;
    begin
        if not Evaluate(Result, Value) then Error('Invalid decimal "%1".', Value);
        exit(Result);
    end;

    local procedure BooleanCell(Value: Text): Boolean
    begin
        case UpperCase(Value) of
            '', 'NO', 'FALSE', '0': exit(false);
            'YES', 'TRUE', '1': exit(true);
            else Error('Invalid status "%1". Use Yes or No.', Value);
        end;
    end;

    local procedure DateTimeCell(Value: Text): DateTime
    var
        Parsed: DateTime;
        DatePart: Text;
        TimePart: Text;
        Parts: List of [Text];
        ClockParts: List of [Text];
        DayNo: Integer;
        MonthNo: Integer;
        YearNo: Integer;
        HourNo: Integer;
        MinuteNo: Integer;
        SecondNo: Integer;
        Serial: Decimal;
        WholeDays: Integer;
        Position: Integer;
        ParsedDate: Date;
    begin
        if Value = '' then exit(0DT);
        // Parse explicit day.month.year text before locale-dependent Evaluate.
        Position := StrPos(Value, ' ');
        if Position > 0 then begin
            DatePart := CopyStr(Value, 1, Position - 1);
            TimePart := CopyStr(Value, Position + 1);
            if StrPos(DatePart, '.') > 0 then begin
                Parts := DatePart.Split('.');
                ClockParts := TimePart.Split(':');
                if (Parts.Count <> 3) or (ClockParts.Count < 2) or (ClockParts.Count > 3) then
                    Error('Invalid date/time "%1".', Value);
                DayNo := IntegerCell(Parts.Get(1)); MonthNo := IntegerCell(Parts.Get(2)); YearNo := IntegerCell(Parts.Get(3));
                HourNo := IntegerCell(ClockParts.Get(1)); MinuteNo := IntegerCell(ClockParts.Get(2));
                if ClockParts.Count = 3 then SecondNo := IntegerCell(ClockParts.Get(3));
                if (HourNo > 23) or (MinuteNo > 59) or (SecondNo > 59) or (HourNo < 0) or (MinuteNo < 0) or (SecondNo < 0) then
                    Error('Invalid time "%1".', TimePart);
                ParsedDate := DMY2Date(DayNo, MonthNo, YearNo);
                exit(CreateDateTime(ParsedDate, 0T) + HourNo * 3600000 + MinuteNo * 60000 + SecondNo * 1000);
            end;
        end;
        if Evaluate(Serial, Value) then begin
            if Serial < 1 then Error('Invalid Excel date serial "%1".', Value);
            WholeDays := Round(Serial, 1, '<');
            ParsedDate := DMY2Date(30, 12, 1899) + WholeDays;
            exit(CreateDateTime(ParsedDate, 0T) + Round((Serial - WholeDays) * 86400000, 1, '='));
        end;
        if Evaluate(Parsed, Value) then exit(Parsed);
        Error('Cannot read date/time "%1".', Value);
    end;
}
