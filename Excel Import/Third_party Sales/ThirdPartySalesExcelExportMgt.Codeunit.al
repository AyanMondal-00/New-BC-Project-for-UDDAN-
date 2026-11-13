
codeunit 50494 "Third Party Sales Excel Export"
{
    procedure ExportToExcel(
        var SelectedSales:
            Record "Third-Party Supplier Sales")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Sales: Record "Third-Party Supplier Sales";
        Passenger: Record "Third Party Passenger Name";
        PassengerNames: Text;
        PassengerIDs: Text;
        PassengerTypes: Text;
        RowCount: Integer;
        FileName: Text;
    begin
        Sales.Copy(SelectedSales);

        if Sales.IsEmpty() then begin
            Message(
                'No Third-Party Sales records found to export.');
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

                // =================================
                // COLUMN 1 - SERIAL NO.
                // =================================

                AddText(
                    ExcelBuffer,
                    Sales."Serial No.");

                // COLUMN 2 - DATE
                AddDateTime(
                    ExcelBuffer,
                    Sales."Date");

                // COLUMN 3 - INVOICE NUMBER
                AddText(
                    ExcelBuffer,
                    Sales."Invoice Number");

                // COLUMN 4 - AGENCY ID
                AddText(
                    ExcelBuffer,
                    Sales."Agency ID");

                // COLUMN 5 - AGENCY NAME
                AddText(
                    ExcelBuffer,
                    Sales."Agency Name");

                // COLUMN 6 - REF NO./AQ NUMBER
                AddText(
                    ExcelBuffer,
                    Format(
                        Sales."Ref No./AQ Number",
                        0, 9));

                // COLUMN 7 - SELECT
                AddText(
                    ExcelBuffer,
                    FormatBoolean(Sales."Select"));

                // COLUMN 8 - SALES INVOICE CREATED
                AddText(
                    ExcelBuffer,
                    FormatBoolean(
                        Sales."Sales Invoice Created"));

                // COLUMN 9 - PNR
                AddText(
                    ExcelBuffer,
                    Sales.PNR);

                // COLUMN 10 - VIEW PASSENGER
                AddText(
                    ExcelBuffer,
                    PassengerNames);

                // COLUMN 11 - PASSENGER ID
                AddText(
                    ExcelBuffer,
                    PassengerIDs);

                // COLUMN 12 - PASSENGER TYPE
                AddText(
                    ExcelBuffer,
                    PassengerTypes);

                // COLUMN 13 - PAX
                ExcelBuffer.AddColumn(
                    Sales.Pax,
                    false,
                    '',
                    false,
                    false,
                    false,
                    '0',
                    ExcelBuffer."Cell Type"::Number);

                // COLUMN 14 - TRAVEL DATE
                AddDateTime(
                    ExcelBuffer,
                    Sales."Travel Date");

                // COLUMN 15 - SECTOR
                AddText(
                    ExcelBuffer,
                    Sales.Sector);

                // COLUMN 16 - TYPE
                AddText(
                    ExcelBuffer,
                    Sales.Type);

                // COLUMN 17 - RATE
                AddNumber(
                    ExcelBuffer,
                    Sales.Rate);

                // COLUMN 18 - TOTAL AMOUNT
                AddNumber(
                    ExcelBuffer,
                    Sales."Total Amount");

                RowCount += 1;

            until Sales.Next() = 0;

        ExcelBuffer.CreateNewBook('Third Party Sales');

        ExcelBuffer.WriteSheet(
            'Third Party Sales Export',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        FileName := 'Third_Party_Sales_Export.xlsx';

        ExcelBuffer.SetFriendlyFilename(FileName);

        ExcelBuffer.OpenExcel();

        Message(
            '%1 Third-Party Sales record(s) prepared for Excel export.',
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
    // ADD DECIMAL NUMBER
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
