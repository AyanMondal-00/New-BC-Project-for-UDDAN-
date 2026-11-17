
codeunit 50542 "AIRIQ Cost Revision Tracking"
{
    procedure GetEnabled(): Boolean
    var
        Setup: Record "AIRIQ Cost Rev User Setup";
    begin
        if Setup.Get(CopyStr(UserId(), 1, MaxStrLen(Setup."User ID"))) then
            exit(Setup."Cost Revision Enable");

        exit(false);
    end;

    procedure SetEnabled(NewEnabled: Boolean)
    var
        Setup: Record "AIRIQ Cost Rev User Setup";
        CurrentUser: Code[100];
    begin
        CurrentUser := CopyStr(UserId(), 1, MaxStrLen(Setup."User ID"));

        if Setup.Get(CurrentUser) then begin
            Setup."Cost Revision Enable" := NewEnabled;
            Setup.Modify(true);
        end else begin
            Setup.Init();
            Setup."User ID" := CurrentUser;
            Setup."Cost Revision Enable" := NewEnabled;
            Setup.Insert(true);
        end;
    end;

    procedure SaveDedicatedRevision(
        var Original: Record "Sample Purchase";
        var Edited: Record "Sample Purchase")
    var
        CurrentPurchase: Record "Sample Purchase";
        History: Record "AIRIQ Cost Revision History";
    begin
        if not GetEnabled() then
            Error('Cost Revision Enable must be ON to save a dedicated cost revision.');

        CurrentPurchase.LockTable();
        CurrentPurchase.Get(Original."Serial No.");

        if CurrentPurchase.SystemModifiedAt <> Original.SystemModifiedAt then
            Error(
                'Purchase %1 was modified by another session. Reopen Edit Cost Revision and try again.',
                Original."Serial No.");

        if CurrentPurchase.PNR <> Edited.PNR then
            Error('PNR cannot be changed in the cost revision window.');

        if (Edited."Total Pax" <= 0) or
           (Edited."Total Amount" <= 0) or
           (Edited.Rate <= 0) or
           (Edited."Base Fare" < 0) then
            Error(
                'Enter a positive Pax, Total Amount and Rate, and a nonnegative Base Fare.');

        CurrentPurchase.Validate("Total Pax", Edited."Total Pax");
        CurrentPurchase.Validate("Base Fare", Edited."Base Fare");
        CurrentPurchase.Validate("Total Amount", Edited."Total Amount");
        CurrentPurchase.Validate(Rate, Edited.Rate);

        if not FinancialChanged(Original, CurrentPurchase) then begin
            Message('No financial values changed. Nothing to save.');
            exit;
        end;

        CurrentPurchase.Modify(true);

        History.SetRange(
            "Purchase Serial No.",
            Original."Serial No.");

        if History.IsEmpty() then
            InsertOpening(Original);

        InsertRevision(
            CurrentPurchase,
            Original."Base Fare",
            Original."Other Charges",
            Original.Rate,
            Original."Total Amount",
            Original."Total Pax",
            'Dedicated Edit');

        Message(
            'Cost revision saved once for PNR %1.',
            CurrentPurchase.PNR);
    end;

    procedure RecordInitialOpening(PurchaseSerialNo: Code[20])
    var
        Purchase: Record "Sample Purchase";
    begin
        if not GetEnabled() then
            Error('Cost Revision Enable must be ON.');

        Purchase.Get(PurchaseSerialNo);
        ValidateComplete(Purchase);
        InsertOpening(Purchase);

        Message(
            'Opening recorded for PNR %1 (if not already present).',
            Purchase.PNR);
    end;

    procedure RecordExcelRevision(
        var BeforePurchase: Record "Sample Purchase";
        var AfterPurchase: Record "Sample Purchase")
    var
        History: Record "AIRIQ Cost Revision History";
    begin
        if not GetEnabled() then
            exit;

        if not FinancialChanged(BeforePurchase, AfterPurchase) then
            exit;

        ValidateComplete(AfterPurchase);

        History.SetRange(
            "Purchase Serial No.",
            AfterPurchase."Serial No.");

        if History.IsEmpty() then begin
            ValidateComplete(BeforePurchase);
            InsertOpening(BeforePurchase);
        end;

        InsertRevision(
            AfterPurchase,
            BeforePurchase."Base Fare",
            BeforePurchase."Other Charges",
            BeforePurchase.Rate,
            BeforePurchase."Total Amount",
            BeforePurchase."Total Pax",
            'Cost Revision Excel');
    end;

    local procedure FinancialChanged(
        OldPurchase: Record "Sample Purchase";
        NewPurchase: Record "Sample Purchase"): Boolean
    begin
        exit(
            (OldPurchase."Base Fare" <> NewPurchase."Base Fare") or
            (OldPurchase."Other Charges" <> NewPurchase."Other Charges") or
            (OldPurchase.Rate <> NewPurchase.Rate) or
            (OldPurchase."Total Amount" <> NewPurchase."Total Amount") or
            (OldPurchase."Total Pax" <> NewPurchase."Total Pax"));
    end;

    local procedure ValidateComplete(Purchase: Record "Sample Purchase")
    begin
        Purchase.TestField(PNR);
        Purchase.TestField("Serial No.");

        if Purchase."Total Pax" <= 0 then
            Error(
                'Total Pax must be greater than zero for PNR %1.',
                Purchase.PNR);

        if Purchase."Total Amount" <= 0 then
            Error(
                'Total Amount must be greater than zero for PNR %1.',
                Purchase.PNR);

        if Purchase.Rate <= 0 then
            Error(
                'Rate must be greater than zero for PNR %1.',
                Purchase.PNR);

        if Purchase."Base Fare" < 0 then
            Error(
                'Base Fare cannot be negative for PNR %1.',
                Purchase.PNR);
    end;

    local procedure InsertOpening(Purchase: Record "Sample Purchase")
    var
        History: Record "AIRIQ Cost Revision History";
    begin
        History.LockTable();

        History.SetRange(
            "Purchase Serial No.",
            Purchase."Serial No.");

        if not History.IsEmpty() then
            exit;

        History.Init();
        FillCommon(History, Purchase, 0);

        History."Transaction Type" :=
            History."Transaction Type"::Opening;

        History."Revision Source" := 'Initial Tracking';

        InsertWithNoSeries(History);
    end;

    local procedure InsertRevision(
        Purchase: Record "Sample Purchase";
        OldBaseFare: Decimal;
        OldCharges: Decimal;
        OldRate: Decimal;
        OldTotal: Decimal;
        OldPax: Integer;
        SourceName: Text[50])
    var
        History: Record "AIRIQ Cost Revision History";
        RevisionNumber: Integer;
    begin
        History.LockTable();

        History.SetCurrentKey(
            "Purchase Serial No.",
            "Revision No.");

        History.SetRange(
            "Purchase Serial No.",
            Purchase."Serial No.");

        if History.FindLast() then
            RevisionNumber := History."Revision No." + 1
        else
            Error(
                'Opening history missing for PNR %1.',
                Purchase.PNR);

        History.Init();
        FillCommon(History, Purchase, RevisionNumber);

        History."Previous Base Fare" := OldBaseFare;
        History."Previous Other Charges" := OldCharges;
        History."Previous Rate" := OldRate;
        History."Previous Total Amount" := OldTotal;
        History."Previous Total Pax" := OldPax;

        History."Fare Difference" :=
            Purchase."Base Fare" - OldBaseFare;

        if History."Fare Difference" > 0 then
            History."Transaction Type" :=
                History."Transaction Type"::Increase
        else
            if History."Fare Difference" < 0 then
                History."Transaction Type" :=
                    History."Transaction Type"::Decrease
            else
                History."Transaction Type" :=
                    History."Transaction Type"::Adjustment;

        History."Revision Source" := SourceName;

        InsertWithNoSeries(History);
    end;

    local procedure FillCommon(
        var History: Record "AIRIQ Cost Revision History";
        Purchase: Record "Sample Purchase";
        RevisionNumber: Integer)
    begin
        History."Revision Date & Time" := CurrentDateTime();
        History.PNR := Purchase.PNR;

        // New airline snapshot for every revision.
        History.AirLine := Purchase.Airline;

        History."Revision No." := RevisionNumber;
        History."Total Pax" := Purchase."Total Pax";
        History."Revised Base Fare" := Purchase."Base Fare";
        History."Revised Other Charges" := Purchase."Other Charges";
        History."Revised Rate" := Purchase.Rate;
        History."Revised Total Amount" := Purchase."Total Amount";

        History."Changed By" :=
            CopyStr(
                UserId(),
                1,
                MaxStrLen(History."Changed By"));

        History."Purchase Serial No." :=
            Purchase."Serial No.";
    end;

    local procedure InsertWithNoSeries(
        var History: Record "AIRIQ Cost Revision History")
    var
        NoSeries: Codeunit "No. Series";
    begin
        History."Cost Revision No." :=
            NoSeries.GetNextNo('CR');

        History.Insert(true);
    end;
}
