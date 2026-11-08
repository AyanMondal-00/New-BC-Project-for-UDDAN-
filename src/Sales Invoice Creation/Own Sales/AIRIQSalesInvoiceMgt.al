codeunit 50427 "AIRIQ Sales Invoice Mgt"
{
    // Compatibility entry point: process exactly the supplied set, never infer checkbox mode.
    // Caller must finish any write transaction before entering this batch boundary.
    procedure CreateOwnSalesInvoices(var NormalSales: Record "Normal Sales")
    begin
        CreateOwnSalesInvoicesForMode(NormalSales, 'Supplied record set');
    end;

    procedure CreateOwnSalesInvoicesForMode(var NormalSales: Record "Normal Sales"; SelectionMode: Text)
    var
        Selection: Record "Normal Sales";
        Snapshot: Record "Normal Sales" temporary;
        SalesToProcess: Record "Normal Sales";
        CreateSalesInvoice: Codeunit "AIRIQ Create Sales Invoice";
        CreatedCount: Integer;
        SkippedCount: Integer;
        FailedCount: Integer;
        SelectedCount: Integer;
        ErrorText: Text;
        FailedDetails: TextBuilder;
        Summary: TextBuilder;
    begin
        // Copy preserves filters AND marks. Never Get/Reset/modify this selection cursor.
        Selection.Copy(NormalSales);
        if Selection.FindSet() then
            repeat
                Snapshot := Selection;
                if Snapshot.Insert() then
                    SelectedCount += 1;
            until Selection.Next() = 0;

        if SelectedCount = 0 then begin
            Message('No records found for selection mode: %1.', SelectionMode);
            exit;
        end;
        if not Confirm('Selection mode: %1\Selected records: %2\Create invoices? Already-created invoices will be skipped.', false,
             SelectionMode, SelectedCount) then
            exit;

        // Only temporary writes above. Each Boolean Run owns one atomic invoice transaction.
        if Snapshot.FindSet() then
            repeat
                Clear(CreateSalesInvoice);
                Clear(SalesToProcess);
                SalesToProcess."Serial No." := Snapshot."Serial No.";
                // Pass snapshot AQ for diagnostics; worker locks and reads the actual row.
                SalesToProcess."Ref No./AQ Number" := Snapshot."Ref No./AQ Number";
                ClearLastError();
                if CreateSalesInvoice.Run(SalesToProcess) then begin
                    if CreateSalesInvoice.WasAlreadyCreated() then
                        SkippedCount += 1
                    else
                        CreatedCount += 1;
                end else begin
                    ErrorText := GetLastErrorText();
                    FailedCount += 1;
                    FailedDetails.AppendLine(StrSubstNo('Serial No. %1 - AQ No. %2 (PNR: %3): %4',
                        Snapshot."Serial No.", Snapshot."Ref No./AQ Number", Snapshot.PNR, ErrorText));
                    ClearLastError();
                end;
            until Snapshot.Next() = 0;

        Summary.AppendLine(StrSubstNo('Selection mode: %1', SelectionMode));
        Summary.AppendLine(StrSubstNo('Selected records: %1', SelectedCount));
        Summary.AppendLine(StrSubstNo('Successfully created invoices: %1', CreatedCount));
        Summary.AppendLine(StrSubstNo('Already-created invoices skipped: %1', SkippedCount));
        Summary.AppendLine(StrSubstNo('Failed records: %1', FailedCount));
        Summary.Append(FailedDetails.ToText());
        Message(Summary.ToText());
    end;
}
