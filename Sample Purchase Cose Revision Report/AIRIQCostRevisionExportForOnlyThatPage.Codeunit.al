
codeunit 50543 "AIRIQ Cost Revision Export"
{
    procedure ExportStatement(
        var FilteredHistory: Record "AIRIQ Cost Revision History")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        History: Record "AIRIQ Cost Revision History";
    begin
        History.Copy(FilteredHistory);
        History.SetCurrentKey(PNR, "Revision No.");

        if History.IsEmpty() then begin
            Message(
                'No cost revision history is available for the current filter.');
            exit;
        end;

        ExcelBuffer.DeleteAll();
        AddHeaderRow(ExcelBuffer);

        if History.FindSet() then
            repeat
                ExcelBuffer.NewRow();

                AddText(ExcelBuffer, History."Cost Revision No.");
                AddDateTime(ExcelBuffer, History."Revision Date & Time");
                AddText(ExcelBuffer, History.PNR);

                // New AirLine column after PNR.
                AddText(ExcelBuffer, GetAirLine(History));

                AddInteger(ExcelBuffer, History."Revision No.");
                AddText(
                    ExcelBuffer,
                    Format(History."Transaction Type"));

                if History."Revision No." = 0 then
                    AddBlank(ExcelBuffer)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Base Fare");

                AddNumber(
                    ExcelBuffer,
                    History."Revised Base Fare");

                if History."Revision No." = 0 then
                    AddBlank(ExcelBuffer)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Fare Difference");

                AddInteger(ExcelBuffer, History."Total Pax");

                if History."Revision No." = 0 then
                    AddBlank(ExcelBuffer)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Other Charges");

                AddNumber(
                    ExcelBuffer,
                    History."Revised Other Charges");

                if History."Revision No." = 0 then
                    AddBlank(ExcelBuffer)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Rate");

                AddNumber(
                    ExcelBuffer,
                    History."Revised Rate");

                if History."Revision No." = 0 then
                    AddBlank(ExcelBuffer)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Total Amount");

                AddNumber(
                    ExcelBuffer,
                    History."Revised Total Amount");

                AddText(
                    ExcelBuffer,
                    History."Revision Source");

                AddText(
                    ExcelBuffer,
                    History."Changed By");

                AddText(
                    ExcelBuffer,
                    History."Purchase Serial No.");

            until History.Next() = 0;

        ExcelBuffer.CreateNewBook('PNR Cost Revision');

        ExcelBuffer.WriteSheet(
            'Cost Revision Statement',
            CompanyName(),
            UserId());

        ExcelBuffer.CloseBook();

        ExcelBuffer.SetFriendlyFilename(
            'AIRIQ_PNR_Cost_Revision_Statement.xlsx');

        ExcelBuffer.OpenExcel();
    end;

    local procedure GetAirLine(
        History: Record "AIRIQ Cost Revision History"): Text[100]
    var
        Purchase: Record "Sample Purchase";
    begin
        if History.AirLine <> '' then
            exit(History.AirLine);

        // Fallback for history created before AirLine field existed.
        if Purchase.Get(History."Purchase Serial No.") then
            exit(Purchase.Airline);

        exit('');
    end;

    local procedure AddHeaderRow(
        var Buffer: Record "Excel Buffer" temporary)
    begin
        Buffer.NewRow();

        AddHeader(Buffer, 'Cost Revision No.');
        AddHeader(Buffer, 'Revision Date & Time');
        AddHeader(Buffer, 'PNR');
        AddHeader(Buffer, 'AirLine');
        AddHeader(Buffer, 'Revision No.');
        AddHeader(Buffer, 'Transaction Type');
        AddHeader(Buffer, 'Previous Base Fare');
        AddHeader(Buffer, 'Revised Base Fare');
        AddHeader(Buffer, 'Fare Difference (+/-)');
        AddHeader(Buffer, 'Total Pax');
        AddHeader(Buffer, 'Previous Other Charges');
        AddHeader(Buffer, 'Revised Other Charges');
        AddHeader(Buffer, 'Previous Rate');
        AddHeader(Buffer, 'Revised Rate');
        AddHeader(Buffer, 'Previous Total Amount');
        AddHeader(Buffer, 'Revised Total Amount');
        AddHeader(Buffer, 'Revision Source');
        AddHeader(Buffer, 'Changed By');
        AddHeader(Buffer, 'Purchase Serial No.');
    end;

    local procedure AddHeader(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Text)
    begin
        Buffer.AddColumn(
            Value, false, '', true, false, false, '',
            Buffer."Cell Type"::Text);
    end;

    local procedure AddBlank(
        var Buffer: Record "Excel Buffer" temporary)
    begin
        AddText(Buffer, '');
    end;

    local procedure AddText(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Text)
    begin
        Buffer.AddColumn(
            Value, false, '', false, false, false, '',
            Buffer."Cell Type"::Text);
    end;

    local procedure AddInteger(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Integer)
    begin
        Buffer.AddColumn(
            Value, false, '', false, false, false, '0',
            Buffer."Cell Type"::Number);
    end;

    local procedure AddNumber(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Decimal)
    begin
        Buffer.AddColumn(
            Value, false, '', false, false, false,
            '#,##0.00;[Red](#,##0.00)',
            Buffer."Cell Type"::Number);
    end;

    local procedure AddDateTime(
        var Buffer: Record "Excel Buffer" temporary;
        Value: DateTime)
    begin
        if Value = 0DT then
            AddText(Buffer, '')
        else
            AddText(
                Buffer,
                Format(
                    Value, 0,
                    '<Day,2>-<Month,2>-<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>'));
    end;
}
