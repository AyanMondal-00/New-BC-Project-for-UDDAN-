
codeunit 50492 "Own Sales Excel Export Mgt."
{
    procedure ExportToExcel(var SelectedSales: Record "Normal Sales")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        Sales: Record "Normal Sales";
        Passenger: Record "Own Sales Passenger Name";
        PassengerNames: Text;
        PassengerIDs: Text;
        PassengerTypes: Text;
        RowCount: Integer;
        FileName: Text;
    begin
        Sales.Copy(SelectedSales);

        if Sales.IsEmpty() then begin
            Message('No Own Sales records found to export.');
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
                    "Ref No./AQ Number", PNR, "SL No.");

                Passenger.SetRange(
                    "Ref No./AQ Number",
                    Sales."Ref No./AQ Number");

                Passenger.SetRange(PNR, Sales.PNR);

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

                AddText(ExcelBuffer, Sales."Serial No.");
                AddDateTime(ExcelBuffer, Sales."Date");
                AddText(ExcelBuffer, Sales."Invoice Number");
                AddText(ExcelBuffer, Sales."Agency ID");
                AddText(ExcelBuffer, Sales."Agency Name");

                AddText(
                    ExcelBuffer,
                    Format(Sales."Ref No./AQ Number", 0, 9));

                AddText(
                    ExcelBuffer,
                    FormatBoolean(Sales."Select"));

                if Sales."Sales Invoice Created" then
                    AddText(ExcelBuffer, 'Yes')
                else
                    AddText(ExcelBuffer, 'No');

                AddText(ExcelBuffer, Sales.PNR);

                // Passenger data from separate table
                AddText(ExcelBuffer, PassengerNames);
                AddText(ExcelBuffer, PassengerIDs);
                AddText(ExcelBuffer, PassengerTypes);


                ExcelBuffer.AddColumn(
                    Sales.Pax,
                    false,
                    '',
                    false,
                    false,
                    false,
                    '0',
                    ExcelBuffer."Cell Type"::Number);

                AddDateTime(ExcelBuffer, Sales."Travel Date");
                AddText(ExcelBuffer, Sales.Sector);
                AddText(ExcelBuffer, Sales.Type);
                AddNumber(ExcelBuffer, Sales."Base Fare");
                AddNumber(ExcelBuffer, Sales."Other Charges");
                AddNumber(ExcelBuffer, Sales."Taxable Basis");
                AddNumber(ExcelBuffer, Sales.CGST);
                AddNumber(ExcelBuffer, Sales.SGST);
                AddNumber(ExcelBuffer, Sales.IGST);
                AddNumber(ExcelBuffer, Sales."Total Amount");

                RowCount += 1;
            until Sales.Next() = 0;

        ExcelBuffer.CreateNewBook('Normal Sales');
        ExcelBuffer.WriteSheet(
            'Normal Sales Export',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        FileName := 'Normal_Sales_Export.xlsx';
        ExcelBuffer.SetFriendlyFilename(FileName);
        ExcelBuffer.OpenExcel();

        Message(
            '%1 Own Sales record(s) prepared for Excel export.',
            RowCount);
    end;

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
        AddHeader(ExcelBuffer, 'Base Fare');
        AddHeader(ExcelBuffer, 'Other Charges');
        AddHeader(ExcelBuffer, 'Taxable Basis');
        AddHeader(ExcelBuffer, 'CGST');
        AddHeader(ExcelBuffer, 'SGST');
        AddHeader(ExcelBuffer, 'IGST');
        AddHeader(ExcelBuffer, 'Total Amount');
    end;

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
            Format(Value, 0, '<Day,2>-<Month,2>-<Year4> <Hours24,2>:<Minutes,2>'));
    end;

    local procedure AppendValue(
        var ResultText: Text;
        NewValue: Text)
    begin
        if ResultText <> '' then
            ResultText += ',';

        ResultText += NewValue;
    end;

    local procedure FormatBoolean(Value: Boolean): Text
    begin
        if Value then
            exit('Yes');

        exit('No');
    end;
}
