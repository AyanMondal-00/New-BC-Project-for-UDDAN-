
codeunit 50543 "AIRIQ Cost Revision Export"
{
    procedure ExportStatement(
        var FilteredHistory: Record "AIRIQ Cost Revision History")
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        History: Record "AIRIQ Cost Revision History";
        IsOpening: Boolean;
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
                IsOpening := History."Revision No." = 0;

                ExcelBuffer.NewRow();

                AddText(
                    ExcelBuffer,
                    History."Cost Revision No.",
                    IsOpening);

                AddDateTime(
                    ExcelBuffer,
                    History."Revision Date & Time",
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    History.PNR,
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    GetAirLine(History),
                    IsOpening);

                AddInteger(
                    ExcelBuffer,
                    History."Revision No.",
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    Format(History."Transaction Type"),
                    IsOpening);

                if IsOpening then
                    AddBlank(ExcelBuffer, true)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Base Fare",
                        false);

                AddNumber(
                    ExcelBuffer,
                    History."Revised Base Fare",
                    IsOpening);

                if IsOpening then
                    AddOpeningNumber(
                        ExcelBuffer,
                        History."Fare Difference")
                else
                    AddFareDifference(
                        ExcelBuffer,
                        History."Fare Difference");

                AddInteger(
                    ExcelBuffer,
                    History."Total Pax",
                    IsOpening);

                if IsOpening then
                    AddBlank(ExcelBuffer, true)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Other Charges",
                        false);

                AddNumber(
                    ExcelBuffer,
                    History."Revised Other Charges",
                    IsOpening);

                if IsOpening then
                    AddBlank(ExcelBuffer, true)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Rate",
                        false);

                AddNumber(
                    ExcelBuffer,
                    History."Revised Rate",
                    IsOpening);

                if IsOpening then
                    AddBlank(ExcelBuffer, true)
                else
                    AddNumber(
                        ExcelBuffer,
                        History."Previous Total Amount",
                        false);

                AddNumber(
                    ExcelBuffer,
                    History."Revised Total Amount",
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    History."Revision Source",
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    History."Changed By",
                    IsOpening);

                AddText(
                    ExcelBuffer,
                    History."Purchase Serial No.",
                    IsOpening);

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
            Value,
            false,
            '',
            true,
            false,
            false,
            '',
            Buffer."Cell Type"::Text);
    end;

    local procedure AddBlank(
        var Buffer: Record "Excel Buffer" temporary;
        IsOpening: Boolean)
    begin
        AddText(Buffer, '', IsOpening);
    end;





    local procedure AddText(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Text;
        IsOpening: Boolean)
    var
        ExcelFormat: Text[30];
    begin
        ExcelFormat := '';

        if IsOpening then
            ExcelFormat := '[Blue]@';

        Buffer.AddColumn(
            Value, false, '', IsOpening, false, false,
            ExcelFormat, Buffer."Cell Type"::Text);
    end;

    local procedure AddInteger(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Integer;
        IsOpening: Boolean)
    var
        ExcelFormat: Text[30];
    begin
        if IsOpening then
            ExcelFormat := '[Blue]0'
        else
            ExcelFormat := '0';

        Buffer.AddColumn(
            Value, false, '', IsOpening, false, false,
            ExcelFormat, Buffer."Cell Type"::Number);
    end;

    local procedure AddNumber(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Decimal;
        IsOpening: Boolean)
    var
        ExcelFormat: Text[30];
    begin
        if IsOpening then
            ExcelFormat := '[Blue]#,##0.00'
        else
            ExcelFormat := '#,##0.00';

        Buffer.AddColumn(
            Value, false, '', IsOpening, false, false,
            ExcelFormat, Buffer."Cell Type"::Number);
    end;

    local procedure AddOpeningNumber(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Decimal)
    begin
        Buffer.AddColumn(
            Value, false, '', true, false, false,
            '[Blue]#,##0.00',
            Buffer."Cell Type"::Number);
    end;

    local procedure AddFareDifference(
        var Buffer: Record "Excel Buffer" temporary;
        Value: Decimal)
    begin
        Buffer.AddColumn(
            Value, false, '', false, false, false,
            '[Green]+0.00;[Red]-0.00',
            Buffer."Cell Type"::Number);
    end;


    local procedure AddDateTime(
        var Buffer: Record "Excel Buffer" temporary;
        Value: DateTime;
        IsOpening: Boolean)
    begin
        if Value = 0DT then
            AddText(Buffer, '', IsOpening)
        else
            AddText(
                Buffer,
                Format(
                    Value,
                    0,
                    '<Day,2>-<Month,2>-<Year4> <Hours24,2>:<Minutes,2>:<Seconds,2>'),
                IsOpening);
    end;
}
