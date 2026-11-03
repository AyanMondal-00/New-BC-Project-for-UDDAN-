codeunit 50700 "AIRIQ Return Credit Memo"
{
    Permissions = tabledata "Purchase Return" = rm,
                  tabledata "Purchase Header" = rim,
                  tabledata "Purchase Line" = rim;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Create(SerialNo: Integer; var Header: Record "Purchase Header")
    var
        Source: Record "Purchase Return";
        Vendor: Record Vendor;
        Item: Record Item;
        Line: Record "Purchase Line";
        Setup: Record "Purchases & Payables Setup";
        PostingSetup: Record "General Posting Setup";
        GSTGroup: Record "GST Group";
        Numbering: Codeunit "AIRIQ AQPR No. Mgt";
    begin
        // Serialize creation for the same source; read the row only after locking.
        Source.LockTable();
        if not Source.Get(SerialNo) then
            Error('Purchase Return %1 no longer exists.', SerialNo);
        CheckDuplicate(Source);
        Source.TestField(Airline);
        Source.TestField(PNR);
        Source.TestField("Purchase Date");
        if (Source.Pax <= 0) or (Source.Rate < 0) or (Source.Amount <= 0) then
            Error('Purchase Return %1 requires positive Pax and Amount, and a nonnegative Rate.', SerialNo);

        // AIRIQ uses exact airline-name matching; Airline ID is not Supplier ID.
        Vendor.SetRange(Name, Source.Airline);
        if Vendor.IsEmpty() then
            Error('No Vendor matches Airline "%1". Configure the Vendor name before creating the credit memo.', Source.Airline);
        if Vendor.Count() <> 1 then
            Error('More than one Vendor matches Airline "%1". Resolve the duplicate Vendor names.', Source.Airline);
        Vendor.FindFirst();
        Vendor.TestField("Vendor Posting Group");
        Vendor.TestField("Gen. Bus. Posting Group");
        Vendor.TestField(Blocked, Vendor.Blocked::" ");

        Item.SetRange(Description, Source.PNR);
        if Item.IsEmpty() then
            Error('No Item has Description (PNR) "%1". Run the existing AIRIQ item creation process first.', Source.PNR);
        if Item.Count() <> 1 then
            Error('More than one Item has Description (PNR) "%1". Resolve the ambiguous PNR.', Source.PNR);
        Item.FindFirst();
        Item.TestField(Blocked, false);
        Item.TestField("Gen. Prod. Posting Group");
        Item.TestField("GST Group Code");
        Item.TestField("HSN/SAC Code");
        if not GSTGroup.Get(Item."GST Group Code") then
            Error('GST Group %1 for Item %2 is missing. Correct GST setup.', Item."GST Group Code", Item."No.");
        if not PostingSetup.Get(Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
            Error('General Posting Setup is missing for business group %1 and product group %2.', Vendor."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        PostingSetup.TestField("Purch. Credit Memo Account");
        Setup.Get();
        Setup.TestField("Credit Memo Nos.");
        Setup.TestField("Posted Credit Memo Nos.");

        Clear(Header);
        Header.Init();
        Header."Document Type" := Header."Document Type"::"Credit Memo";
        Header.Insert(true);
        Header.Validate("Buy-from Vendor No.", Vendor."No.");
        Header.Validate("Document Date", DT2Date(Source."Purchase Date"));
        // Posting Date stays at the standard BC work date for manual review.
        Header."AIRIQ Return Serial No." := Source."Serial No.";
        Header."AIRIQ Voucher Number" := Source."Voucher Number";
        Header."AIRIQ Entry Date" := Source."Entry Date";
        Header."AIRIQ Purchase Date" := Source."Purchase Date";
        Header."AIRIQ Reference" := Source."Reference";
        Header."AIRIQ Narration" := Source."Narration";
        Header."AIRIQ Airline ID" := Source."Airline ID";
        Header.Validate("Vendor Cr. Memo No.", Numbering.NextNumber());
        Header.Modify(true);

        Line.Init();
        Line."Document Type" := Header."Document Type";
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Validate(Type, Line.Type::Item);
        Line.Validate("No.", Item."No.");
        Line.Validate("Location Code", 'SILIGURI');
        Line.Validate(Quantity, Source.Pax);
        // Existing invoice behavior: Quantity = Pax, Direct Unit Cost = Rate.
        // No return formula is defined in the source table/importer. Never guess one.
        Line.Validate("Direct Unit Cost", Source.Rate);
        Line.Validate("Line Discount %", 0);
        Line.Validate("Allow Invoice Disc.", false);
        if Line."Line Amount" <> Round(Source.Amount, GetAmountPrecision(Header)) then
            Error('Purchase Return %1 Amount (%2) differs from the standard Pax x Rate line amount (%3). No return formula is configured; resolve the source values before creating a credit memo.', SerialNo, Source.Amount, Line."Line Amount");
        Line."AIRIQ PNR" := Source."PNR";
        Line."Sample Sector" := Source."Sector";
        Line."AIRIQ Country" := Source."Country";
        Line."Sample Flight Type" := Source."Type";
        Line."AIRIQ Pax" := Source."Pax";
        Line."Sample Base Fare" := Source."Base Fare";
        Line."Sample Other Charges" := Source."Others";
        Line."AIRIQ Rate" := Source."Rate";
        Line."AIRIQ Discount" := Source."Discount";
        Line."AIRIQ XXLN Charges" := Source."XXLN Charges";
        Line."AIRIQ Return Amount" := Source."Amount";
        Line."Sample Travel Date" := Source."Travel Date";
        Line."AIRIQ Flight No." := Source."Flight No.";
        Line."AIRIQ Departure Time" := Source."Departure Time";
        Line."AIRIQ Arrival Time" := Source."Arrival Time";
        Line."AIRIQ Cost Revision" := Source."Cost Revision";
        Line."Sample Purchase Date" := Source."Purchase Date";
        Line."Sample Entry Date" := Source."Entry Date";
        Line."Sample Airline" := Source.Airline;
        Line.Insert(true);
        // Never validate Line Amount after setting Sample Other Charges: existing
        // invoice subscribers bypass financial checks for that field.
        Source."AIRIQ Credit Memo Created" := true;
        Source."AIRIQ Credit Memo No." := Header."No.";
        Source."AIRIQ Vendor Cr. Memo No." := Header."Vendor Cr. Memo No.";
        Source.Modify(true);
    end;

    local procedure GetAmountPrecision(Header: Record "Purchase Header"): Decimal
    var
        Currency: Record Currency;
    begin
        Currency.Initialize(Header."Currency Code");
        exit(Currency."Amount Rounding Precision");
    end;

    local procedure CheckDuplicate(Source: Record "Purchase Return")
    var
        Header: Record "Purchase Header";
        Posted: Record "Purch. Cr. Memo Hdr.";
    begin
        Posted.SetRange("AIRIQ Return Serial No.", Source."Serial No.");
        if Posted.FindFirst() then
            Error('Purchase Return %1 already has posted Purchase Credit Memo %2.', Source."Serial No.", Posted."No.");
        Header.SetRange("Document Type", Header."Document Type"::"Credit Memo");
        Header.SetRange("AIRIQ Return Serial No.", Source."Serial No.");
        if Header.FindFirst() then
            Error('Purchase Return %1 already has unposted Purchase Credit Memo %2.', Source."Serial No.", Header."No.");
        if Source."AIRIQ Vendor Cr. Memo No." <> '' then begin
            Posted.Reset();
            Posted.SetRange("Vendor Cr. Memo No.", Source."AIRIQ Vendor Cr. Memo No.");
            if Posted.FindFirst() then
                Error('Purchase Return %1 is linked to posted Purchase Credit Memo %2.', Source."Serial No.", Posted."No.");
            Header.SetRange("AIRIQ Return Serial No.");
            Header.SetRange("Vendor Cr. Memo No.", Source."AIRIQ Vendor Cr. Memo No.");
            if Header.FindFirst() then
                Error('Purchase Return %1 is linked to Purchase Credit Memo %2.', Source."Serial No.", Header."No.");
        end;
        if Source."AIRIQ Credit Memo Created" or (Source."AIRIQ Credit Memo No." <> '') or (Source."AIRIQ Posted Cr. Memo No." <> '') then
            Error('Purchase Return %1 was already used for Purchase Credit Memo %2 (posted: %3). The link is retained even if a draft was deleted; contact your administrator.', Source."Serial No.", Source."AIRIQ Credit Memo No.", Source."AIRIQ Posted Cr. Memo No.");
    end;
}


codeunit 50701 "AIRIQ AQPR No. Mgt" implements "No. Series - Single"
{
    Permissions = tabledata "No. Series" = rim,
                  tabledata "No. Series Line" = rim,
                  tabledata "AIRIQ AQPR Reservation" = ri;

    procedure NextNumber(): Code[20]
    var
        SeriesAPI: Codeunit "No. Series";
    begin
        EnsureSetup();
        exit(SeriesAPI.GetNextNo('AIRIQ-AQPR', WorkDate()));
    end;

    procedure EnsureSetup()
    var
        Series: Record "No. Series";
        Line: Record "No. Series Line";
    begin
        Series.LockTable();
        if not Series.Get('AIRIQ-AQPR') then begin
            Series.Init();
            Series.Code := 'AIRIQ-AQPR';
            Series.Description := 'AIRIQ Purchase Return Vendor Credit Memo';
            Series."Default Nos." := true;
            Series.Insert(true);
            Line.Init();
            Line."Series Code" := Series.Code;
            Line."Line No." := 10000;
            Line."Starting No." := 'AQPR000001';
            Line."Increment-by No." := 1;
            Line.Implementation := Line.Implementation::"AIRIQ AQPR";
            Line.Open := true;
            Line.Insert(true);
        end;
        // Existing setup is never repaired/overwritten silently.
        Line.SetRange("Series Code", Series.Code);
        if Line.Count() <> 1 then
            Error('No. Series AIRIQ-AQPR must have exactly one line. Existing configuration was left unchanged.');
        Line.FindFirst();
        CheckSetup(Line);
    end;

    procedure GetNextNo(var NoSeriesLine: Record "No. Series Line"; UsageDate: Date; HideErrorsAndWarnings: Boolean): Code[20]
    var
        LockedLine: Record "No. Series Line";
        Reservation: Record "AIRIQ AQPR Reservation";
        Candidate: Code[20];
    begin
        if NoSeriesLine.IsTemporary() then
            Error('AQPR numbering requires a persistent No. Series Line; batch/temporary numbering is not supported.');
        LockedLine.LockTable();
        LockedLine.Get(NoSeriesLine."Series Code", NoSeriesLine."Line No.");
        CheckSetup(LockedLine);
        Candidate := PeekNextNo(LockedLine, UsageDate);
        Reservation.LockTable();
        // Reservations survive deletion and posting of documents. Collisions in
        // pre-existing BC data are skipped, never assigned to another document.
        while Reservation.Get(Candidate) or DocumentExists(Candidate) do
            Candidate := IncrementNumber(Candidate);
        Reservation.Init();
        Reservation.Number := Candidate;
        Reservation.Insert(true);
        LockedLine."Last No. Used" := Candidate;
        LockedLine."Last Date Used" := UsageDate;
        LockedLine.Modify(true);
        NoSeriesLine := LockedLine;
        exit(Candidate);
    end;

    procedure PeekNextNo(NoSeriesLine: Record "No. Series Line"; UsageDate: Date): Code[20]
    var
        Reservation: Record "AIRIQ AQPR Reservation";
        Candidate: Code[20];
    begin
        CheckSetup(NoSeriesLine);
        if NoSeriesLine."Last No. Used" = '' then
            Candidate := 'AQPR000001'
        else
            Candidate := IncrementNumber(NoSeriesLine."Last No. Used");
        while Reservation.Get(Candidate) or DocumentExists(Candidate) do
            Candidate := IncrementNumber(Candidate);
        exit(Candidate);
    end;

    procedure GetLastNoUsed(NoSeriesLine: Record "No. Series Line"): Code[20]
    begin
        exit(NoSeriesLine."Last No. Used");
    end;

    procedure MayProduceGaps(): Boolean
    begin
        exit(false);
    end;

    local procedure CheckSetup(Line: Record "No. Series Line")
    begin
        Line.TestField("Series Code", 'AIRIQ-AQPR');
        Line.TestField("Starting No.", 'AQPR000001');
        Line.TestField("Increment-by No.", 1);
        Line.TestField("Ending No.", '');
        Line.TestField("Warning No.", '');
        Line.TestField("Starting Date", 0D);
        Line.TestField(Implementation, Line.Implementation::"AIRIQ AQPR");
        Line.TestField(Open, true);
    end;

    local procedure IncrementNumber(Current: Code[20]): Code[20]
    var
        Digits: Text;
        Index: Integer;
        Digit: Integer;
        Carry: Boolean;
    begin
        if CopyStr(Current, 1, 4) <> 'AQPR' then
            Error('Invalid AQPR last number %1. Existing No. Series configuration was left unchanged.', Current);
        Digits := CopyStr(Current, 5);
        if (StrLen(Digits) < 6) or (DelChr(Digits, '=', '0123456789') <> '') then
            Error('Invalid numeric suffix in AQPR number %1.', Current);
        Carry := true;
        Index := StrLen(Digits);
        while Carry and (Index > 0) do begin
            Evaluate(Digit, CopyStr(Digits, Index, 1));
            Digit += 1;
            Carry := Digit = 10;
            if Carry then
                Digit := 0;
            Digits := DelStr(Digits, Index, 1);
            Digits := InsStr(Digits, Format(Digit, 0, 9), Index);
            Index -= 1;
        end;
        if Carry then
            Digits := '1' + Digits;
        if StrLen(Digits) > 16 then
            Error('AQPR numbering has reached the technical Code[20] limit (16 numeric digits after AQPR). No credit memo was created.');
        exit(CopyStr('AQPR' + Digits, 1, 20));
    end;

    local procedure DocumentExists(Number: Code[20]): Boolean
    var
        Header: Record "Purchase Header";
        Posted: Record "Purch. Cr. Memo Hdr.";
    begin
        Header.SetRange("Vendor Cr. Memo No.", Number);
        if not Header.IsEmpty() then
            exit(true);
        Posted.SetRange("Vendor Cr. Memo No.", Number);
        exit(not Posted.IsEmpty());
    end;
}


enumextension 50700 "AIRIQ AQPR Implementation" extends "No. Series Implementation"
{
    value(50700; "AIRIQ AQPR")
    {
        Caption = 'AIRIQ AQPR (growing numeric suffix)';
        Implementation = "No. Series - Single" = "AIRIQ AQPR No. Mgt";
    }
}


table 50700 "AIRIQ AQPR Reservation"
{
    Caption = 'AIRIQ AQPR Reservation';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Number"; Code[20]) { DataClassification = CustomerContent; }
    }
    keys
    {
        key(PK; "Number") { Clustered = true; }
    }
}
