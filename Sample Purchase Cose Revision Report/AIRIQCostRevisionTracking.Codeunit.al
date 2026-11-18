codeunit 50542 "AIRIQ Cost Revision Tracking"
{
    // History is recorded ONLY after successful purchase invoice create/update.
    procedure GetEnabled(): Boolean
    var Setup: Record "AIRIQ Cost Rev User Setup";
    begin
        if Setup.Get(CopyStr(UserId(), 1, MaxStrLen(Setup."User ID"))) then
            exit(Setup."Cost Revision Enable");
        exit(false);
    end;

    procedure SetEnabled(NewEnabled: Boolean)
    var Setup: Record "AIRIQ Cost Rev User Setup";
        UserKey: Code[100];
    begin
        UserKey := CopyStr(UserId(), 1, MaxStrLen(Setup."User ID"));
        if Setup.Get(UserKey) then begin
            Setup."Cost Revision Enable" := NewEnabled;
            Setup.Modify(true);
        end else begin
            Setup.Init();
            Setup."User ID" := UserKey;
            Setup."Cost Revision Enable" := NewEnabled;
            Setup.Insert(true);
        end;
    end;

    procedure RecordInvoiceOpening(Purchase: Record "Sample Purchase")
    var History: Record "AIRIQ Cost Revision History";
    begin
        ValidateComplete(Purchase);
        History.LockTable();
        History.SetRange("Purchase Serial No.", Purchase."Serial No.");
        if not History.IsEmpty() then
            exit;
        History.Init();
        FillCommon(History, Purchase, 0);
        History."Transaction Type" := History."Transaction Type"::Opening;
        History."Revision Source" := 'Purchase Invoice Created';
        InsertWithNoSeries(History);
    end;

    procedure RecordInvoiceUpdate(OldPurchase: Record "Sample Purchase"; NewPurchase: Record "Sample Purchase")
    var History: Record "AIRIQ Cost Revision History";
        RevisionNumber: Integer;
        OldBaseFare: Decimal;
        OldCharges: Decimal;
        OldRate: Decimal;
        OldTotal: Decimal;
        OldPax: Integer;
    begin
        ValidateComplete(NewPurchase);
        History.LockTable();
        History.SetCurrentKey("Purchase Serial No.", "Revision No.");
        History.SetRange("Purchase Serial No.", NewPurchase."Serial No.");
        if History.FindLast() then begin
            RevisionNumber := History."Revision No." + 1;
            // Last successfully invoiced values are the baseline, not staged values.
            OldBaseFare := History."Revised Base Fare";
            OldCharges := History."Revised Other Charges";
            OldRate := History."Revised Rate";
            OldTotal := History."Revised Total Amount";
            OldPax := History."Total Pax";
        end else begin
            // For an old pre-upgrade draft invoice, reconstruct opening from its line.
            RecordInvoiceOpening(OldPurchase);
            RevisionNumber := 1;
            OldBaseFare := OldPurchase."Base Fare";
            OldCharges := OldPurchase."Other Charges";
            OldRate := OldPurchase.Rate;
            OldTotal := OldPurchase."Total Amount";
            OldPax := OldPurchase."Total Pax";
        end;
        if (OldBaseFare = NewPurchase."Base Fare") and
           (OldCharges = NewPurchase."Other Charges") and
           (OldRate = NewPurchase.Rate) and
           (OldTotal = NewPurchase."Total Amount") and
           (OldPax = NewPurchase."Total Pax") then
            exit;
        History.Init();
        FillCommon(History, NewPurchase, RevisionNumber);
        History."Previous Base Fare" := OldBaseFare;
        History."Previous Other Charges" := OldCharges;
        History."Previous Rate" := OldRate;
        History."Previous Total Amount" := OldTotal;
        History."Previous Total Pax" := OldPax;
        History."Fare Difference" := NewPurchase."Base Fare" - OldBaseFare;
        if History."Fare Difference" > 0 then
            History."Transaction Type" := History."Transaction Type"::Increase
        else if History."Fare Difference" < 0 then
            History."Transaction Type" := History."Transaction Type"::Decrease
        else
            History."Transaction Type" := History."Transaction Type"::Adjustment;
        History."Revision Source" := 'Purchase Invoice Updated';
        InsertWithNoSeries(History);
    end;

    local procedure ValidateComplete(Purchase: Record "Sample Purchase")
    begin
        Purchase.TestField(PNR);
        Purchase.TestField("Serial No.");
        if Purchase."Total Pax" <= 0 then
            Error('Total Pax must be positive for PNR %1.', Purchase.PNR);
        if Purchase."Total Amount" <= 0 then
            Error('Total Amount must be positive for PNR %1.', Purchase.PNR);
        if Purchase.Rate < 0 then
            Error('Rate cannot be negative for PNR %1.', Purchase.PNR);
        if Purchase."Base Fare" < 0 then
            Error('Base Fare cannot be negative for PNR %1.', Purchase.PNR);
    end;

    local procedure FillCommon(var History: Record "AIRIQ Cost Revision History";
                              Purchase: Record "Sample Purchase"; RevisionNumber: Integer)
    begin
        History."Revision Date & Time" := CurrentDateTime();
        History.PNR := Purchase.PNR;
        History.AirLine := Purchase.Airline;
        History."Revision No." := RevisionNumber;
        History."Total Pax" := Purchase."Total Pax";
        History."Revised Base Fare" := Purchase."Base Fare";
        History."Revised Other Charges" := Purchase."Other Charges";
        History."Revised Rate" := Purchase.Rate;
        History."Revised Total Amount" := Purchase."Total Amount";
        History."Changed By" := CopyStr(UserId(), 1, MaxStrLen(History."Changed By"));
        History."Purchase Serial No." := Purchase."Serial No.";
    end;

    local procedure InsertWithNoSeries(var History: Record "AIRIQ Cost Revision History")
    var NoSeries: Codeunit "No. Series";
    begin
        History."Cost Revision No." := NoSeries.GetNextNo('CR');
        History.Insert(true);
    end;
}
