codeunit 50427 "AIRIQ Sales Invoice Mgt"
{
    procedure CreateOwnSalesInvoices(var NormalSales: Record "Normal Sales")
    var
        SelectedSales: Record "Normal Sales";
        SalesToProcess: Record "Normal Sales";
        CreateSalesInvoice: Codeunit "AIRIQ Create Sales Invoice";
        CreatedCount: Integer;
        FailedCount: Integer;
        FailedRecordsLogged: Integer;
        FailedDetails: TextBuilder;
        SummaryMsg: TextBuilder;
        CurrentSerialNo: Integer;
    begin
        // Prefer records selected using the Select checkbox.
        SelectedSales.Reset();
        SelectedSales.SetRange("Select", true);

        if not SelectedSales.IsEmpty() then
            SalesToProcess.Copy(SelectedSales)
        else begin
            // Otherwise use the record filters passed from the page.
            SalesToProcess.Copy(NormalSales);

            if SalesToProcess.IsEmpty() then
                Error('Please select at least one Sales record.');
        end;

        if SalesToProcess.FindSet() then
            repeat
                CurrentSerialNo := SalesToProcess."Serial No.";

                // Re-read the actual record before processing.
                if NormalSales.Get(CurrentSerialNo) then begin
                    if NormalSales."Sales Invoice Created" then begin
                        FailedCount += 1;

                        if FailedRecordsLogged < 10 then begin
                            FailedRecordsLogged += 1;
                            FailedDetails.AppendLine(
                                StrSubstNo(
                                    '- AQ No. %1 (PNR: %2): Invoice already created.',
                                    NormalSales."Ref No./AQ Number",
                                    NormalSales.PNR));
                        end;
                    end else begin
                        ClearLastError();

                        if CreateSalesInvoice.Run(NormalSales) then
                            CreatedCount += 1
                        else begin
                            FailedCount += 1;

                            if FailedRecordsLogged < 10 then begin
                                FailedRecordsLogged += 1;
                                FailedDetails.AppendLine(
                                    StrSubstNo(
                                        '- AQ No. %1 (PNR: %2): %3',
                                        NormalSales."Ref No./AQ Number",
                                        NormalSales.PNR,
                                        GetLastErrorText()));
                            end;

                            ClearLastError();
                        end;
                    end;
                end;
            until SalesToProcess.Next() = 0;

        if FailedCount = 0 then
            Message('%1 Sales Invoice(s) created successfully.', CreatedCount)
        else begin
            SummaryMsg.AppendLine(
                StrSubstNo(
                    '%1 Sales Invoice(s) created successfully.',
                    CreatedCount));
            SummaryMsg.AppendLine(
                StrSubstNo(
                    '%1 record(s) failed.',
                    FailedCount));
            SummaryMsg.AppendLine('');
            SummaryMsg.Append(FailedDetails.ToText());

            if FailedCount > FailedRecordsLogged then
                SummaryMsg.AppendLine(
                    StrSubstNo(
                        '... and %1 more failure(s).',
                        FailedCount - FailedRecordsLogged));

            Message(SummaryMsg.ToText());
        end;
    end;
}