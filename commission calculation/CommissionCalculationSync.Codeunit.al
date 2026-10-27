
codeunit 50452 "Commission Calculation Sync"
{

    procedure SyncPostedPurchaseInvoices(
        StartDate: Date;
        EndDate: Date)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchInvHeader: Record "Purch. Inv. Header";
        CommissionRec: Record "Commission Calculation";
        ImportedCount: Integer;
        VendorRec: Record Vendor;
        SkippedCount: Integer;
    begin
        if (StartDate = 0D) or (EndDate = 0D) then
            Error('Please select both Start Date and End Date.');

        if StartDate > EndDate then
            Error('Start Date cannot be later than End Date.');

        // Filter invoice lines ONLY by Travel Date.
        PurchInvLine.Reset();
        PurchInvLine.SetRange(
            "Sample Travel Date",
            CreateDateTime(StartDate, 000000T),
            CreateDateTime(EndDate, 235959T));
        PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
        PurchInvLine.SetFilter("No.", '<>%1', '');

        if PurchInvLine.FindSet() then
            repeat
                CommissionRec.Reset();
                CommissionRec.SetRange(
                    PNR, UpperCase(PurchInvLine."No."));

                if CommissionRec.IsEmpty() then begin
                    if PurchInvHeader.Get(PurchInvLine."Document No.") then begin
                        CommissionRec.Init();
                        CommissionRec."Serial No." := 0;
                        CommissionRec.PNR :=
                            UpperCase(PurchInvLine."No.");
                        CommissionRec.Airline :=
                            PurchInvHeader."Buy-from Vendor Name";

                        if VendorRec.Get(PurchInvHeader."Buy-from Vendor No.") then
                            CommissionRec."Commission Percentage" :=
                                VendorRec."Vendor Commision";

                        CommissionRec.Purchase :=
                            PurchInvLine."Line Amount";
                        CommissionRec."Travel Date" :=
                            PurchInvLine."Sample Travel Date";

                        CommissionRec.Insert(true);
                        ImportedCount += 1;
                    end;
                end else
                    SkippedCount += 1;

            until PurchInvLine.Next() = 0;

        Message(
            'Commission sync completed.\New records created: %1.\Duplicate PNR lines skipped: %2.',
            ImportedCount,
            SkippedCount);
    end;

    procedure UpdatePurchaseReturn(
     PNRNo: Code[20];
     CreditMemoAmount: Decimal)
    var
        CommissionRec: Record "Commission Calculation";
    begin
        if PNRNo = '' then
            exit;

        CommissionRec.SetRange(PNR, UpperCase(PNRNo));

        if CommissionRec.FindFirst() then begin
            CommissionRec."Purchase Return" += CreditMemoAmount;
            CommissionRec.Modify(true);
        end;
    end;

}
