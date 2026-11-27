report 50391 "AIRIQ Credit Note Invoice"
{
    Caption = 'AIRIQ Credit Note Invoice';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'RDL File for Sales format/AIRIQ_CreditNote.rdl';

    dataset
    {
        dataitem(Header; "Sales Cr.Memo Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";

            column(CreditNoteNo; CreditNoteNo) { }
            column(RefNo; RefNo) { }
            column(CreditNoteDate; CreditNoteDate) { }
            column(PlaceOfSupply; PlaceOfSupply) { }
            column(AgainstInvoiceNo; AgainstInvoiceNo) { }
            column(InvoiceDate; InvoiceDate) { }
            column(HeaderPNR; HeaderPNR) { }
            column(Reason; Reason) { }
            column(SellerName; SellerName) { }
            column(SellerAddress1; SellerAddress1) { }
            column(SellerAddress2; SellerAddress2) { }
            column(SellerAddress3; SellerAddress3) { }
            column(SellerGSTIN; SellerGSTIN) { }
            column(CustomerName; CustomerName) { }
            column(CustomerAddress1; CustomerAddress1) { }
            column(CustomerAddress2; CustomerAddress2) { }
            column(CustomerAddress3; CustomerAddress3) { }
            column(CustomerGSTIN; CustomerGSTIN) { }
            column(ValueExclGST; ValueExclGST) { }
            column(CGSTReversed; CGSTReversed) { }
            column(SGSTReversed; SGSTReversed) { }
            column(CreditNoteValue; CreditNoteValue) { }
            column(TotalCancelCharges; TotalCancelCharges) { }
            column(CGSTOnCharges; CGSTOnCharges) { }
            column(SGSTOnCharges; SGSTOnCharges) { }
            column(NetRefund; NetRefund) { }
            column(NetRefundInWords; NetRefundInWords) { }
            column(Narration; Narration) { }
            column(BankName; BankName) { }
            column(BankAccountNo; BankAccountNo) { }
            column(BankIFSC; BankIFSC) { }
            column(Website; Website) { }
            column(ContactEmail; ContactEmail) { }
            column(PassengerTotal; PassengerCount) { }

            dataitem(PassengerLine; "Sales Cr.Memo Line")
            {
                DataItemLinkReference = Header;
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(SlNo; LineSLNo) { }
                column(PassengerSequence; PassengerSequence) { }
                column(PassengerName; LinePassengerName) { }
                column(LinePNR; LinePNR) { }
                column(TravelDate; LineTravelDate) { }
                column(SAC; LineSAC) { }
                column(Qty; LineQty) { }
                column(TktValue; LineTktValue) { }
                column(CancelCharge; LineCancelCharge) { }
                column(LineGST; LineGST) { }
                column(RefundAmount; LineRefundAmount) { }

                trigger OnPreDataItem()
                begin
                    // Passenger table must contain passenger Item lines only.
                    // The cancellation G/L line must never print as a passenger.
                    SetRange(Type, Type::Item);
                end;

                trigger OnAfterGetRecord()
                begin
                    // AIRIQ Passenger SL is intentionally not used.
                    // Passenger sequence is derived from the created line order.
                    PassengerSequence += 1;
                    LineSLNo := PassengerSequence;

                    LinePassengerName :=
                        CopyStr(
                            "Passenger Name",
                            1,
                            MaxStrLen(LinePassengerName));

                    LinePNR := Description;

                    if "Travel Date" <> 0DT then
                        LineTravelDate :=
                            Format(
                                DT2Date("Travel Date"),
                                0,
                                '<Day,2> <Month Text,3> <Year4>')
                    else
                        LineTravelDate := '';

                    // Item GST classification is intentionally blank on the
                    // Credit Memo, so print SAC from the original posted invoice.
                    LineSAC :=
                        GetOriginalPassengerSAC(
                            Header,
                            PassengerLine);

                    LineQty := Quantity;

                    // Sold Value is stored per passenger on the posted memo line.
                    LineTktValue := "AIRIQ Sold Value";
                    if LineTktValue = 0 then
                        LineTktValue := Abs("Unit Price");

                    // Cancellation charge and its GST come from the actual
                    // posted cancellation G/L line / GST ledger, allocated per PAX.
                    LineCancelCharge := CancellationChargePerPax;
                    LineGST := CancellationGSTPerPax;

                    // First-pass mapping: prefer the explicit staging refund
                    // carried into the posted memo line. If blank, derive it from
                    // the actual posted ticket/cancellation values.
                    LineRefundAmount := "AIRIQ Refund Amount";
                    if LineRefundAmount = 0 then
                        LineRefundAmount :=
                            LineTktValue -
                            LineCancelCharge -
                            LineGST;
                end;
            }

            dataitem(GSTSummary; Integer)
            {
                DataItemTableView =
                    sorting(Number)
                    where(Number = filter(1 .. 2));

                column(TaxComponent; TaxComponent) { }
                column(TaxRate; TaxRate) { }
                column(ReversedOnTickets; ReversedOnTickets) { }
                column(OnCancelChg; OnCancelChg) { }
                column(NetGST; NetGST) { }

                trigger OnAfterGetRecord()
                begin
                    case Number of
                        1:
                            begin
                                TaxComponent := 'CGST';
                                TaxRate := FormatGSTPercent(CGSTOnChargesRate, 9);
                                ReversedOnTickets := CGSTReversed;
                                OnCancelChg := CGSTOnCharges;
                                NetGST := CGSTOnCharges - CGSTReversed;
                            end;

                        2:
                            begin
                                TaxComponent := 'SGST';
                                TaxRate := FormatGSTPercent(SGSTOnChargesRate, 9);
                                ReversedOnTickets := SGSTReversed;
                                OnCancelChg := SGSTOnCharges;
                                NetGST := SGSTOnCharges - SGSTReversed;
                            end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                OriginalInvoice: Record "Sales Invoice Header";
            begin
                if Count() <> 1 then
                    Error(
                        'Select exactly one posted Sales Credit Memo using the No. filter.');

                ClearReportValues();
                PassengerSequence := 0;

                // ------------------------------------------------------------
                // CREDIT NOTE HEADER
                // ------------------------------------------------------------
                CreditNoteNo := "No.";
                RefNo := "AIRIQ Return No.";

                CreditNoteDate :=
                    Format(
                        "Posting Date",
                        0,
                        '<Day,2> <Month Text,3> <Year4>');

                AgainstInvoiceNo := "AIRIQ Original Invoice";

                if AgainstInvoiceNo = '' then
                    Error(
                        'Credit Memo %1 has no AIRIQ Original Invoice reference.',
                        "No.");

                if not OriginalInvoice.Get(AgainstInvoiceNo) then
                    Error(
                        'Original Posted Sales Invoice %1 linked to Credit Memo %2 was not found.',
                        AgainstInvoiceNo,
                        "No.");

                InvoiceDate :=
                    Format(
                        OriginalInvoice."Posting Date",
                        0,
                        '<Day,2> <Month Text,3> <Year4>');

                // ------------------------------------------------------------
                // COMPANY / CUSTOMER / BANK DETAILS
                // ------------------------------------------------------------
                PreparePartyAndBankDetails(Header);

                // ------------------------------------------------------------
                // PASSENGER + TICKET TOTALS FROM POSTED CREDIT MEMO
                // ------------------------------------------------------------
                PreparePassengerTotals(Header, OriginalInvoice);

                // ------------------------------------------------------------
                // ORIGINAL TICKET GST SUMMARY FROM POSTED SALES INVOICE
                // ------------------------------------------------------------
                PrepareOriginalTicketGST(
                    Header,
                    OriginalInvoice,
                    CGSTReversed,
                    SGSTReversed,
                    IGSTReversed);

                // ------------------------------------------------------------
                // CANCELLATION GST FROM ACTUAL POSTED CREDIT MEMO GST LEDGER
                // ------------------------------------------------------------
                PrepareCancellationGST(Header);

                if PassengerCount > 0 then begin
                    CancellationChargePerPax :=
                        Round(
                            TotalCancelCharges / PassengerCount,
                            0.01);

                    CancellationGSTPerPax :=
                        Round(
                            (CGSTOnCharges +
                             SGSTOnCharges +
                             IGSTOnCharges) /
                            PassengerCount,
                            0.01);
                end;

                // Client format: Ticket value less original ticket GST.
                ValueExclGST :=
                    CreditNoteValue -
                    CGSTReversed -
                    SGSTReversed -
                    IGSTReversed;

                // Accounting/result total based on the actual posted ticket value,
                // cancellation line and cancellation GST.
                NetRefund :=
                    CreditNoteValue -
                    TotalCancelCharges -
                    CGSTOnCharges -
                    SGSTOnCharges -
                    IGSTOnCharges;

                NetRefundInWords := RupeeWords(NetRefund);

                // ------------------------------------------------------------
                // PLACE OF SUPPLY / REASON / NARRATION
                // ------------------------------------------------------------
                PrepareOriginalInvoiceContext(
                    OriginalInvoice,
                    PlaceOfSupply);

                if "AIRIQ Reference" <> '' then
                    Reason := "AIRIQ Reference"
                else
                    Reason :=
                        StrSubstNo(
                            'Ticket cancellation (%1 of %2 pax)',
                            PassengerCount,
                            OriginalPNRQty);

                Narration := "AIRIQ Narration";

                if Narration = '' then
                    Narration :=
                        StrSubstNo(
                            'Being credit note issued against Invoice No. %1 dated %2 for cancellation of %3 passenger(s) on PNR %4; cancellation charges with GST deducted.',
                            AgainstInvoiceNo,
                            InvoiceDate,
                            PassengerCount,
                            HeaderPNR);
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";

        CreditNoteNo: Text[50];
        RefNo: Text[50];
        CreditNoteDate: Text[50];
        PlaceOfSupply: Text[100];
        AgainstInvoiceNo: Text[50];
        InvoiceDate: Text[50];
        HeaderPNR: Text[50];
        Reason: Text[250];

        SellerName: Text[100];
        SellerAddress1: Text[100];
        SellerAddress2: Text[100];
        SellerAddress3: Text[100];
        SellerGSTIN: Text[50];

        CustomerName: Text[100];
        CustomerAddress1: Text[100];
        CustomerAddress2: Text[100];
        CustomerAddress3: Text[100];
        CustomerGSTIN: Text[50];

        ValueExclGST: Decimal;
        CGSTReversed: Decimal;
        SGSTReversed: Decimal;
        IGSTReversed: Decimal;
        CreditNoteValue: Decimal;
        TotalCancelCharges: Decimal;
        CGSTOnCharges: Decimal;
        SGSTOnCharges: Decimal;
        IGSTOnCharges: Decimal;
        CGSTOnChargesRate: Decimal;
        SGSTOnChargesRate: Decimal;
        IGSTOnChargesRate: Decimal;
        NetRefund: Decimal;

        NetRefundInWords: Text[250];
        Narration: Text[500];

        BankName: Text[100];
        BankAccountNo: Text[50];
        BankIFSC: Text[50];
        Website: Text[100];
        ContactEmail: Text[100];

        PassengerCount: Integer;
        PassengerSequence: Integer;
        OriginalPNRQty: Decimal;
        CancellationChargePerPax: Decimal;
        CancellationGSTPerPax: Decimal;

        LineSLNo: Integer;
        LinePassengerName: Text[100];
        LinePNR: Text[50];
        LineTravelDate: Text[50];
        LineSAC: Text[50];
        LineQty: Decimal;
        LineTktValue: Decimal;
        LineCancelCharge: Decimal;
        LineGST: Decimal;
        LineRefundAmount: Decimal;

        TaxComponent: Text[50];
        TaxRate: Text[50];
        ReversedOnTickets: Decimal;
        OnCancelChg: Decimal;
        NetGST: Decimal;

    local procedure ClearReportValues()
    begin
        Clear(PlaceOfSupply);
        Clear(HeaderPNR);
        Clear(Reason);
        Clear(PassengerCount);
        Clear(OriginalPNRQty);

        Clear(ValueExclGST);
        Clear(CGSTReversed);
        Clear(SGSTReversed);
        Clear(IGSTReversed);
        Clear(CreditNoteValue);
        Clear(TotalCancelCharges);
        Clear(CGSTOnCharges);
        Clear(SGSTOnCharges);
        Clear(IGSTOnCharges);
        Clear(CGSTOnChargesRate);
        Clear(SGSTOnChargesRate);
        Clear(IGSTOnChargesRate);
        Clear(NetRefund);
        Clear(CancellationChargePerPax);
        Clear(CancellationGSTPerPax);

        Clear(NetRefundInWords);
        Clear(Narration);

        Clear(BankName);
        Clear(BankAccountNo);
        Clear(BankIFSC);
    end;

    local procedure PreparePartyAndBankDetails(Header: Record "Sales Cr.Memo Header")
    var
        CustomerRec: Record Customer;
    begin
        SellerName := CompanyInfo.Name;
        SellerAddress1 := CompanyInfo.Address;
        SellerAddress2 := CompanyInfo."Address 2";
        SellerAddress3 :=
            DelChr(
                CompanyInfo.City + ' ' + CompanyInfo."Post Code",
                '<>',
                ' ');

        SellerGSTIN := CompanyInfo."GST Registration No.";

        CustomerName := Header."Bill-to Name";
        CustomerAddress1 := Header."Bill-to Address";
        CustomerAddress2 := Header."Bill-to Address 2";
        CustomerAddress3 :=
            DelChr(
                Header."Bill-to City" + ' ' + Header."Bill-to Post Code",
                '<>',
                ' ');

        CustomerGSTIN := '';
        if CustomerRec.Get(Header."Bill-to Customer No.") then
            CustomerGSTIN := CustomerRec."GST Registration No.";

        BankName := CompanyInfo."Bank Name";
        BankAccountNo := CompanyInfo."Bank Account No.";

        BankIFSC := '—';
        if StrLen(CompanyInfo."Bank Branch No.") = 11 then
            BankIFSC := CompanyInfo."Bank Branch No.";

        Website := CompanyInfo."Home Page";
        ContactEmail := CompanyInfo."E-Mail";
    end;

    local procedure PreparePassengerTotals(
        Header: Record "Sales Cr.Memo Header";
        OriginalInvoice: Record "Sales Invoice Header")
    var
        MemoLine: Record "Sales Cr.Memo Line";
        OriginalLine: Record "Sales Invoice Line";
        TicketValue: Decimal;
    begin
        MemoLine.Reset();
        MemoLine.SetRange("Document No.", Header."No.");
        MemoLine.SetRange(Type, MemoLine.Type::Item);

        PassengerCount := MemoLine.Count();

        if PassengerCount = 0 then
            Error(
                'Credit Memo %1 has no passenger Item lines.',
                Header."No.");

        if MemoLine.FindSet() then
            repeat
                if HeaderPNR = '' then
                    HeaderPNR := MemoLine.Description;

                TicketValue := MemoLine."AIRIQ Sold Value";
                if TicketValue = 0 then
                    TicketValue := Abs(MemoLine."Unit Price");

                CreditNoteValue +=
                    TicketValue * Abs(MemoLine.Quantity);

            until MemoLine.Next() = 0;

        // Original invoiced PAX for the PNR, used only for the Reason text.
        OriginalLine.Reset();
        OriginalLine.SetRange("Document No.", OriginalInvoice."No.");
        OriginalLine.SetRange(Type, OriginalLine.Type::Item);
        OriginalLine.SetRange(Description, HeaderPNR);

        if OriginalLine.FindSet() then
            repeat
                OriginalPNRQty += Abs(OriginalLine.Quantity);
            until OriginalLine.Next() = 0;

        if OriginalPNRQty = 0 then
            OriginalPNRQty := PassengerCount;

        // Cancellation charge is the actual posted G/L line amount.
        MemoLine.Reset();
        MemoLine.SetRange("Document No.", Header."No.");
        MemoLine.SetRange(Type, MemoLine.Type::"G/L Account");

        if MemoLine.FindSet() then
            repeat
                TotalCancelCharges += Abs(MemoLine.Amount);
            until MemoLine.Next() = 0;
    end;

    local procedure PrepareOriginalTicketGST(
        CreditHeader: Record "Sales Cr.Memo Header";
        OriginalInvoice: Record "Sales Invoice Header";
        var CGSTAmount: Decimal;
        var SGSTAmount: Decimal;
        var IGSTAmount: Decimal)
    var
        CreditLine: Record "Sales Cr.Memo Line";
        OriginalLine: Record "Sales Invoice Line";
        LineCGST: Decimal;
        LineSGST: Decimal;
        LineIGST: Decimal;
    begin
        CreditLine.Reset();
        CreditLine.SetRange("Document No.", CreditHeader."No.");
        CreditLine.SetRange(Type, CreditLine.Type::Item);

        if CreditLine.FindSet() then
            repeat
                Clear(LineCGST);
                Clear(LineSGST);
                Clear(LineIGST);

                if FindOriginalPassengerLine(
                    OriginalInvoice,
                    CreditLine,
                    OriginalLine)
                then
                    GetOriginalInvoiceLineGST(
                        OriginalInvoice,
                        OriginalLine."Line No.",
                        LineCGST,
                        LineSGST,
                        LineIGST)
                else begin
                    // Safe fallback to the source GST values carried from
                    // Sales Return when an exact historical passenger line
                    // cannot be identified.
                    LineCGST := Abs(CreditLine."AIRIQ Source CGST");
                    LineSGST := Abs(CreditLine."AIRIQ Source SGST");
                    LineIGST := Abs(CreditLine."AIRIQ Source IGST");
                end;

                CGSTAmount += LineCGST;
                SGSTAmount += LineSGST;
                IGSTAmount += LineIGST;

            until CreditLine.Next() = 0;
    end;

    local procedure FindOriginalPassengerLine(
        OriginalInvoice: Record "Sales Invoice Header";
        CreditLine: Record "Sales Cr.Memo Line";
        var OriginalLine: Record "Sales Invoice Line"): Boolean
    begin
        OriginalLine.Reset();
        OriginalLine.SetRange("Document No.", OriginalInvoice."No.");
        OriginalLine.SetRange(Type, OriginalLine.Type::Item);
        OriginalLine.SetRange(Description, CreditLine.Description);

        if CreditLine."Passenger Name" <> '' then begin
            OriginalLine.SetRange(
                "Passenger Name",
                CreditLine."Passenger Name");

            if OriginalLine.FindFirst() then
                exit(true);

            OriginalLine.SetRange("Passenger Name");
        end;

        // Do not guess a random original line when multiple PNR lines exist.
        if OriginalLine.Count() = 1 then begin
            OriginalLine.FindFirst();
            exit(true);
        end;

        exit(false);
    end;

    local procedure GetOriginalPassengerSAC(
        CreditHeader: Record "Sales Cr.Memo Header";
        CreditLine: Record "Sales Cr.Memo Line"): Text[50]
    var
        OriginalInvoice: Record "Sales Invoice Header";
        OriginalLine: Record "Sales Invoice Line";
    begin
        if CreditHeader."AIRIQ Original Invoice" = '' then
            exit('');

        if not OriginalInvoice.Get(CreditHeader."AIRIQ Original Invoice") then
            exit('');

        if FindOriginalPassengerLine(
            OriginalInvoice,
            CreditLine,
            OriginalLine)
        then
            exit(OriginalLine."HSN/SAC Code");

        // PNR-level fallback for display-only SAC.
        OriginalLine.Reset();
        OriginalLine.SetRange("Document No.", OriginalInvoice."No.");
        OriginalLine.SetRange(Type, OriginalLine.Type::Item);
        OriginalLine.SetRange(Description, CreditLine.Description);

        if OriginalLine.FindFirst() then
            exit(OriginalLine."HSN/SAC Code");

        exit('');
    end;

    local procedure GetOriginalInvoiceLineGST(
        OriginalInvoice: Record "Sales Invoice Header";
        LineNo: Integer;
        var CGSTAmount: Decimal;
        var SGSTAmount: Decimal;
        var IGSTAmount: Decimal)
    var
        TaxEntry: Record "Detailed GST Ledger Entry";
    begin
        SetOriginalInvoiceGSTFilters(TaxEntry, OriginalInvoice);
        TaxEntry.SetRange("Document Line No.", LineNo);

        if TaxEntry.FindSet() then
            repeat
                if IsOriginalInvoiceGST(TaxEntry, OriginalInvoice) then
                    case UpperCase(TaxEntry."GST Component Code") of
                        'CGST':
                            CGSTAmount += Abs(TaxEntry."GST Amount");
                        'SGST':
                            SGSTAmount += Abs(TaxEntry."GST Amount");
                        'IGST':
                            IGSTAmount += Abs(TaxEntry."GST Amount");
                    end;
            until TaxEntry.Next() = 0;
    end;

    local procedure PrepareCancellationGST(Header: Record "Sales Cr.Memo Header")
    var
        TaxEntry: Record "Detailed GST Ledger Entry";
        MemoLine: Record "Sales Cr.Memo Line";
    begin
        SetCreditMemoGSTFilters(TaxEntry, Header);

        if TaxEntry.FindSet() then
            repeat
                if (TaxEntry."Document Line No." <> 0) and
                   MemoLine.Get(
                        Header."No.",
                        TaxEntry."Document Line No.")
                then
                    if MemoLine.Type = MemoLine.Type::"G/L Account" then
                        case UpperCase(TaxEntry."GST Component Code") of
                            'CGST':
                                begin
                                    CGSTOnCharges += Abs(TaxEntry."GST Amount");
                                    if TaxEntry."GST %" <> 0 then
                                        CGSTOnChargesRate := TaxEntry."GST %";
                                end;

                            'SGST':
                                begin
                                    SGSTOnCharges += Abs(TaxEntry."GST Amount");
                                    if TaxEntry."GST %" <> 0 then
                                        SGSTOnChargesRate := TaxEntry."GST %";
                                end;

                            'IGST':
                                begin
                                    IGSTOnCharges += Abs(TaxEntry."GST Amount");
                                    if TaxEntry."GST %" <> 0 then
                                        IGSTOnChargesRate := TaxEntry."GST %";
                                end;
                        end;

            until TaxEntry.Next() = 0;
    end;

    local procedure SetOriginalInvoiceGSTFilters(
        var TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Invoice Header")
    begin
        TaxEntry.Reset();
        TaxEntry.SetRange("Document No.", Header."No.");
        TaxEntry.SetRange(
            "Transaction Type",
            TaxEntry."Transaction Type"::Sales);
        TaxEntry.SetRange(
            "Document Type",
            TaxEntry."Document Type"::Invoice);
        TaxEntry.SetRange(
            "Entry Type",
            TaxEntry."Entry Type"::"Initial Entry");
    end;

    local procedure SetCreditMemoGSTFilters(
        var TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Cr.Memo Header")
    begin
        TaxEntry.Reset();
        TaxEntry.SetRange("Document No.", Header."No.");
        TaxEntry.SetRange(
            "Transaction Type",
            TaxEntry."Transaction Type"::Sales);
        TaxEntry.SetRange(
            "Document Type",
            TaxEntry."Document Type"::"Credit Memo");
        TaxEntry.SetRange(
            "Entry Type",
            TaxEntry."Entry Type"::"Initial Entry");
    end;

    local procedure IsOriginalInvoiceGST(
        TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Invoice Header"): Boolean
    begin
        if TaxEntry."Reversal Entry" then
            exit(false);

        if TaxEntry."Source Type" <>
           TaxEntry."Source Type"::Customer
        then
            exit(false);

        if (TaxEntry."Source No." <>
            Header."Bill-to Customer No.") and
           (TaxEntry."Source No." <>
            Header."Sell-to Customer No.")
        then
            exit(false);

        exit(true);
    end;

    local procedure PrepareOriginalInvoiceContext(
        OriginalInvoice: Record "Sales Invoice Header";
        var SupplyText: Text[100])
    var
        TaxEntry: Record "Detailed GST Ledger Entry";
        StateRec: Record State;
        SupplyCode: Code[10];
        CurrentSupplyCode: Code[10];
    begin
        SupplyCode := '';

        SetOriginalInvoiceGSTFilters(TaxEntry, OriginalInvoice);

        if TaxEntry.FindSet() then
            repeat
                if IsOriginalInvoiceGST(TaxEntry, OriginalInvoice) then begin
                    CurrentSupplyCode :=
                        GetGSTSupplyCode(
                            TaxEntry,
                            OriginalInvoice);

                    if CurrentSupplyCode <> '' then begin
                        if (SupplyCode <> '') and
                           (SupplyCode <> CurrentSupplyCode)
                        then
                            Error(
                                'Original Invoice %1 has multiple GST places of supply.',
                                OriginalInvoice."No.");

                        SupplyCode := CurrentSupplyCode;
                    end;
                end;
            until TaxEntry.Next() = 0;

        if SupplyCode = '' then
            SupplyCode := OriginalInvoice.State;

        SupplyText := SupplyCode;

        if StateRec.Get(SupplyCode) then
            SupplyText :=
                StateRec.Description +
                ' (' + StateRec.Code + ')';
    end;

    local procedure GetGSTSupplyCode(
        TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Invoice Header"): Code[10]
    begin
        case TaxEntry."GST Place of Supply" of
            TaxEntry."GST Place of Supply"::"Bill-to Address":
                exit(Header."GST Bill-to State Code");

            TaxEntry."GST Place of Supply"::"Ship-to Address":
                exit(Header."GST Ship-to State Code");

            TaxEntry."GST Place of Supply"::"Location Address":
                exit(Header."Location State Code");
        end;

        exit('');
    end;

    local procedure FormatGSTPercent(
        ActualPercent: Decimal;
        DefaultPercent: Decimal): Text[50]
    begin
        if ActualPercent = 0 then
            ActualPercent := DefaultPercent;

        exit(Format(ActualPercent) + '%');
    end;

    local procedure RupeeWords(Value: Decimal): Text
    var
        Paise: Integer;
        Whole: Decimal;
        Prefix: Text;
    begin
        Prefix := 'Indian Rupees ';

        if Value < 0 then begin
            Prefix += 'Minus ';
            Value := -Value;
        end;

        Value := Round(Value, 0.01);
        Whole := Round(Value, 1, '<');

        Paise :=
            Round((Value - Whole) * 100, 1);

        Prefix += IndianNumber(Whole);

        if Paise <> 0 then
            Prefix +=
                ' And ' +
                IndianNumber(Paise) +
                ' Paise';

        exit(Prefix + ' Only');
    end;

    local procedure IndianNumber(Value: Decimal): Text
    var
        Part: Decimal;
        Result: Text;
    begin
        if Value >= 10000000 then begin
            Part := Round(Value / 10000000, 1, '<');
            Result := IndianNumber(Part) + ' Crore';
            Value := Value - Part * 10000000;
        end;

        if Value >= 100000 then begin
            Part := Round(Value / 100000, 1, '<');
            Result := JoinWords(Result, IndianNumber(Part) + ' Lakh');
            Value := Value - Part * 100000;
        end;

        if Value >= 1000 then begin
            Part := Round(Value / 1000, 1, '<');
            Result := JoinWords(Result, IndianNumber(Part) + ' Thousand');
            Value := Value - Part * 1000;
        end;

        if Value >= 100 then begin
            Part := Round(Value / 100, 1, '<');
            Result := JoinWords(Result, IndianNumber(Part) + ' Hundred');
            Value := Value - Part * 100;
        end;

        if Value >= 20 then begin
            Part := Round(Value / 10, 1, '<');
            Result :=
                JoinWords(
                    Result,
                    SelectStr(
                        Part - 1,
                        'Twenty,Thirty,Forty,Fifty,Sixty,Seventy,Eighty,Ninety'));
            Value := Value - Part * 10;
        end;

        if Value > 0 then
            Result :=
                JoinWords(
                    Result,
                    SelectStr(
                        Value,
                        'One,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Eleven,Twelve,Thirteen,Fourteen,Fifteen,Sixteen,Seventeen,Eighteen,Nineteen'));

        if Result = '' then
            Result := 'Zero';

        exit(Result);
    end;

    local procedure JoinWords(
        LeftText: Text;
        RightText: Text): Text
    begin
        if LeftText = '' then
            exit(RightText);

        exit(LeftText + ' ' + RightText);
    end;
}
