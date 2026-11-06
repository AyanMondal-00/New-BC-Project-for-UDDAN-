codeunit 50701 "AIRIQ AQPR No. Mgt" implements "No. Series - Single"
{
    Permissions = tabledata "No. Series" = rim,
                  tabledata "No. Series Line" = rim,
                  tabledata "AIRIQ AQPR Reservation" = ri,
                  tabledata "Purchase Header" = r,
                  tabledata "Purch. Cr. Memo Hdr." = r,
                  tabledata "Purchase Return" = r;

    procedure NextNumber(): Code[20]
    var
        NoSeries: Codeunit "No. Series";
    begin
        EnsureSetup();
        exit(NoSeries.GetNextNo('AIRIQ-AQPR', WorkDate()));
    end;

    procedure EnsureSetup()
    var
        Series: Record "No. Series";
        SeriesLine: Record "No. Series Line";
    begin
        Series.LockTable();
        if not Series.Get('AIRIQ-AQPR') then begin
            Series.Init();
            Series.Code := 'AIRIQ-AQPR';
            Series.Description := 'AIRIQ Purchase Return Vendor Credit Memo';
            Series."Default Nos." := true;
            Series.Insert(true);
        end;
        SeriesLine.LockTable();
        SeriesLine.SetRange("Series Code", Series.Code);
        if SeriesLine.IsEmpty() then begin
            SeriesLine.Init();
            SeriesLine."Series Code" := Series.Code;
            SeriesLine."Line No." := 10000;
            SeriesLine."Starting No." := 'AQPR000001';
            SeriesLine."Increment-by No." := 1;
            SeriesLine.Implementation := SeriesLine.Implementation::"AIRIQ AQPR";
            SeriesLine.Open := true;
            SeriesLine.Insert(true);
        end;
        if SeriesLine.FindSet() then
            repeat
                CheckSetup(SeriesLine);
            until SeriesLine.Next() = 0;
    end;

    procedure GetNextNo(var NoSeriesLine: Record "No. Series Line"; UsageDate: Date; HideErrorsAndWarnings: Boolean): Code[20]
    var
        Reservation: Record "AIRIQ AQPR Reservation";
        Candidate: Code[20];
    begin
        // The line lock and reservation insert serialize concurrent allocations.
        NoSeriesLine.LockTable();
        NoSeriesLine.Get(NoSeriesLine."Series Code", NoSeriesLine."Line No.");
        CheckSetup(NoSeriesLine);
        Reservation.LockTable();
        Candidate := PeekNextNo(NoSeriesLine, UsageDate);
        Reservation.Init();
        Reservation.Number := Candidate;
        Reservation.Insert(true);
        NoSeriesLine."Last No. Used" := Candidate;
        NoSeriesLine."Last Date Used" := UsageDate;
        NoSeriesLine.Modify(true);
        exit(Candidate);
    end;

    procedure PeekNextNo(NoSeriesLine: Record "No. Series Line"; UsageDate: Date): Code[20]
    var
        Candidate: Code[20];
    begin
        CheckSetup(NoSeriesLine);
        if NoSeriesLine."Last No. Used" = '' then
            Candidate := NoSeriesLine."Starting No."
        else
            Candidate := IncrementNumber(NoSeriesLine."Last No. Used");
        while DocumentExists(Candidate) do
            Candidate := IncrementNumber(Candidate);
        exit(Candidate);
    end;

    procedure GetLastNoUsed(NoSeriesLine: Record "No. Series Line"): Code[20]
    begin
        exit(NoSeriesLine."Last No. Used");
    end;

    procedure MayProduceGaps(): Boolean
    begin
        exit(true);
    end;

    procedure CheckSetup(NoSeriesLine: Record "No. Series Line")
    begin
        NoSeriesLine.TestField("Series Code", 'AIRIQ-AQPR');
        NoSeriesLine.TestField("Starting No.", 'AQPR000001');
        NoSeriesLine.TestField("Increment-by No.", 1);
        NoSeriesLine.TestField(Implementation, NoSeriesLine.Implementation::"AIRIQ AQPR");
        NoSeriesLine.TestField("Ending No.", '');
        NoSeriesLine.TestField("Warning No.", '');
    end;

    procedure IncrementNumber(Number: Code[20]): Code[20]
    var
        Suffix: BigInteger;
        Digits: Text;
    begin
        if (CopyStr(Number, 1, 4) <> 'AQPR') or
           not Evaluate(Suffix, CopyStr(Number, 5)) then
            Error('Invalid AIRIQ AQPR number %1.', Number);
        if Suffix < 0 then
            Error('Invalid AIRIQ AQPR number %1.', Number);
        Suffix += 1;
        Digits := Format(Suffix, 0, 9);
        while StrLen(Digits) < 6 do
            Digits := '0' + Digits;
        if StrLen(Digits) > 16 then
            Error('AIRIQ AQPR number capacity exceeded.');
        exit(CopyStr('AQPR' + Digits, 1, 20));
    end;

    procedure DocumentExists(Number: Code[20]): Boolean
    var
        Reservation: Record "AIRIQ AQPR Reservation";
        Header: Record "Purchase Header";
        Posted: Record "Purch. Cr. Memo Hdr.";
        Source: Record "Purchase Return";
    begin
        if Reservation.Get(Number) then
            exit(true);
        Header.SetRange("Vendor Cr. Memo No.", Number);
        if not Header.IsEmpty() then
            exit(true);
        Posted.SetRange("Vendor Cr. Memo No.", Number);
        if not Posted.IsEmpty() then
            exit(true);
        Source.SetRange("AIRIQ Vendor Cr. Memo No.", Number);
        exit(not Source.IsEmpty());
    end;
}
