
codeunit 50493 "API Sales Excel Export Mgt."
{
    procedure ExportToExcel(
        var SelectedSales: Record "API Sales Format")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Sales: Record "API Sales Format";
        Passenger: Record "API Sales Passenger Name";
        PassengerNames: Text;
        PassengerIDs: Text;
        PassengerTypes: Text;
        RowCount: Integer;
        FileName: Text;
    begin
        Sales.Copy(SelectedSales);

        if Sales.IsEmpty() then begin
            Message('No API Sales records found to export.');
            exit;
        end;

        ExcelBuffer.DeleteAll();
        AddHeaders(ExcelBuffer);

        if Sales.FindSet() then
            repeat
                Clear(PassengerNames);
                Clear(PassengerIDs);
                Clear(PassengerTypes);

                Passenger.Reset();

                Passenger.SetCurrentKey(
                    "Ref No./AQ Number",
                    PNR,
                    "SL No.");

                Passenger.SetRange(
                    "Ref No./AQ Number",
                    Sales."Ref No./AQ Number");

                Passenger.SetRange(
                    PNR,
                    Sales.PNR);

                if Passenger.FindSet() then
                    repeat
                        AppendValue(
                            PassengerNames,
                            Passenger."Passenger Name");

                        AppendValue(
                            PassengerIDs,
                            Format(Passenger.ID, 0, 9));

                        AppendValue(
                            PassengerTypes,
                            Passenger.Type);
                    until Passenger.Next() = 0;

                ExcelBuffer.NewRow();

                // 1 - Serial No.
                AddText(
                    ExcelBuffer,
                    Sales."Serial No.");

                // 2 - Date
                AddDateTime(
                    ExcelBuffer,
                    Sales."Date");

                // 3 - Invoice Number
                AddText(
                    ExcelBuffer,
                    Sales."Invoice Number");

                // 4 - Agency ID
                AddText(
                    ExcelBuffer,
                    Sales."Agency ID");

                // 5 - Agency Name
                AddText(
                    ExcelBuffer,
                    Sales."Agency Name");

                // 6 - Ref No./AQ Number
                AddText(
                    ExcelBuffer,
                    Format(
                        Sales."Ref No./AQ Number",
                        0, 9));

                // 7 - Select
                AddText(
                    ExcelBuffer,
                    FormatBoolean(Sales."Select"));

                // 8 - Sales Invoice Created
                AddText(
                    ExcelBuffer,
                    FormatBoolean(
                        Sales."Sales Invoice Created"));

                // 9 - PNR
                AddText(
                    ExcelBuffer,
                    Sales.PNR);

                // 10 - View Passenger
                AddText(
                    ExcelBuffer,
                    PassengerNames);

                // 11 - Passenger ID
                AddText(
                    ExcelBuffer,
                    PassengerIDs);

                // 12 - Passenger Type
                AddText(
                    ExcelBuffer,
                    PassengerTypes);

                // 13 - Pax
                ExcelBuffer.AddColumn(
                    Sales.Pax,
                    false,
                    '',
                    false,
                    false,
                    false,
                    '0',
                    ExcelBuffer."Cell Type"::Number);

                // 14 - Travel Date
                AddDateTime(
                    ExcelBuffer,
                    Sales."Travel Date");

                // 15 - Sector
                AddText(
                    ExcelBuffer,
                    Sales.Sector);

                // 16 - Type
                AddText(
                    ExcelBuffer,
                    Sales.Type);

                // 17 - Rate
                AddNumber(
                    ExcelBuffer,
                    Sales.Rate);

                // 18 - Total Amount
                AddNumber(
                    ExcelBuffer,
                    Sales."Total Amount");

                RowCount += 1;

            until Sales.Next() = 0;

        ExcelBuffer.CreateNewBook('API Sales');

        ExcelBuffer.WriteSheet(
            'API Sales Export',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        FileName := 'API_Sales_Export.xlsx';

        ExcelBuffer.SetFriendlyFilename(FileName);
        ExcelBuffer.OpenExcel();

        Message(
            '%1 API Sales record(s) prepared for Excel export.',
            RowCount);
    end;

    // ==========================================
    // EXCEL HEADERS - 18 COLUMNS
    // ==========================================

    local procedure AddHeaders(
        var ExcelBuffer: Record "Excel Buffer" temporary)
    begin
        ExcelBuffer.NewRow();

        AddHeader(ExcelBuffer, 'Serial No.');
        AddHeader(ExcelBuffer, 'Date');
        AddHeader(ExcelBuffer, 'Invoice Number');
        AddHeader(ExcelBuffer, 'Agency ID');
        AddHeader(ExcelBuffer, 'Agency Name');
        AddHeader(ExcelBuffer, 'Ref No./AQ Number');
        AddHeader(ExcelBuffer, 'Select');
        AddHeader(ExcelBuffer, 'Sales Invoice Created');
        AddHeader(ExcelBuffer, 'PNR');
        AddHeader(ExcelBuffer, 'View Passenger');
        AddHeader(ExcelBuffer, 'Passenger ID');
        AddHeader(ExcelBuffer, 'Passenger Type');
        AddHeader(ExcelBuffer, 'Pax');
        AddHeader(ExcelBuffer, 'Travel Date');
        AddHeader(ExcelBuffer, 'Sector');
        AddHeader(ExcelBuffer, 'Type');
        AddHeader(ExcelBuffer, 'Rate');
        AddHeader(ExcelBuffer, 'Total Amount');
    end;

    // ==========================================
    // ADD HEADER
    // ==========================================

    local procedure AddHeader(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        Value: Text)
    begin
        ExcelBuffer.AddColumn(
            Value,
            false,
            '',
            true,
            false,
            false,
            '',
            ExcelBuffer."Cell Type"::Text);
    end;

    // ==========================================
    // ADD TEXT
    // ==========================================

    local procedure AddText(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        Value: Text)
    begin
        ExcelBuffer.AddColumn(
            Value,
            false,
            '',
            false,
            false,
            false,
            '',
            ExcelBuffer."Cell Type"::Text);
    end;

    // ==========================================
    // ADD NUMBER
    // ==========================================

    local procedure AddNumber(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        Value: Decimal)
    begin
        ExcelBuffer.AddColumn(
            Value,
            false,
            '',
            false,
            false,
            false,
            '0.00',
            ExcelBuffer."Cell Type"::Number);
    end;

    // ==========================================
    // ADD DATETIME
    // ==========================================

    local procedure AddDateTime(
        var ExcelBuffer: Record "Excel Buffer" temporary;
        Value: DateTime)
    begin
        if Value = 0DT then begin
            AddText(ExcelBuffer, '');
            exit;
        end;

        AddText(
            ExcelBuffer,
            Format(
                Value,
                0,
                '<Day,2>-<Month,2>-<Year4> <Hours24,2>:<Minutes,2>'));
    end;

    // ==========================================
    // COMMA SEPARATED PASSENGER VALUES
    // ==========================================

    local procedure AppendValue(
        var ResultText: Text;
        NewValue: Text)
    begin
        if ResultText <> '' then
            ResultText += ',';

        ResultText += NewValue;
    end;

    // ==========================================
    // BOOLEAN TO YES / NO
    // ==========================================

    local procedure FormatBoolean(
        Value: Boolean): Text
    begin
        if Value then
            exit('Yes');

        exit('No');
    end;
}
