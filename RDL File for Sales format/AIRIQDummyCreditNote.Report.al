
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

            dataitem(PassengerLine; "Sales Cr.Memo Line")
            {
                DataItemLinkReference = Header;
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(SlNo; LineSLNo) { }
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
                    SetFilter(Type, '<>%1', Type::" ");
                end;

                trigger OnAfterGetRecord()
                begin
                    LineSLNo := "AIRIQ Passenger SL";

                    if LineSLNo = 0 then
                        LineSLNo := "Line No." div 10000;

                    LinePassengerName :=
                        CopyStr(
                            "Passenger Name",
                            1,
                            MaxStrLen(LinePassengerName));

                    LinePNR := Description;

                    LineTravelDate :=
                        Format(
                            DT2Date("Travel Date"),
                            0,
                            '<Day,2> <Month Text,3> <Year4>');

                    // Temporary Demo SAC
                    LineSAC := '998555';

                    LineQty := Quantity;

                    // Source totals are repeated on passenger lines.
                    // Allocate once to avoid double counting.
                    if PassengerCount > 0 then begin
                        LineTktValue :=
                            Round(
                                "AIRIQ Sold Value" / PassengerCount,
                                0.01);

                        LineCancelCharge :=
                            Round(
                                "AIRIQ XXLN Charges" / PassengerCount,
                                0.01);

                        LineGST :=
                            Round(
                                (CGSTOnCharges + SGSTOnCharges) /
                                PassengerCount,
                                0.01);

                        LineRefundAmount :=
                            Round(
                                NetRefund / PassengerCount,
                                0.01);
                    end;
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
                                TaxRate := '9%';

                                ReversedOnTickets :=
                                    CGSTReversed;

                                OnCancelChg :=
                                    CGSTOnCharges;

                                NetGST :=
                                    CGSTOnCharges -
                                    CGSTReversed;
                            end;

                        2:
                            begin
                                TaxComponent := 'SGST';
                                TaxRate := '9%';

                                ReversedOnTickets :=
                                    SGSTReversed;

                                OnCancelChg :=
                                    SGSTOnCharges;

                                NetGST :=
                                    SGSTOnCharges -
                                    SGSTReversed;
                            end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                PostedLine: Record "Sales Cr.Memo Line";
                OriginalInvoice: Record "Sales Invoice Header";
                CompanyInfo: Record "Company Information";
                CustomerRec: Record Customer;

                SourceCGST: Decimal;
                SourceSGST: Decimal;
                SourceIGST: Decimal;
            begin
                Clear(PassengerCount);
                Clear(ValueExclGST);
                Clear(CGSTReversed);
                Clear(SGSTReversed);
                Clear(CreditNoteValue);
                Clear(TotalCancelCharges);
                Clear(CGSTOnCharges);
                Clear(SGSTOnCharges);
                Clear(NetRefund);
                Clear(HeaderPNR);
                Clear(PlaceOfSupply);
                Clear(InvoiceDate);
                Clear(BankName);
                Clear(BankAccountNo);
                Clear(BankIFSC);

                // Credit Note Header
                CreditNoteNo := "No.";

                RefNo := "AIRIQ Return No.";

                CreditNoteDate :=
                    Format(
                        "Posting Date",
                        0,
                        '<Day,2> <Month Text,3> <Year4>');

                AgainstInvoiceNo :=
                    "AIRIQ Original Invoice";

                if OriginalInvoice.Get(AgainstInvoiceNo) then
                    InvoiceDate :=
                        Format(
                            OriginalInvoice."Posting Date",
                            0,
                            '<Day,2> <Month Text,3> <Year4>');

                Reason := "AIRIQ Reference";

                if Reason = '' then
                    Reason := 'Ticket cancellation';

                Narration := "AIRIQ Narration";

                // Company Information
                CompanyInfo.Get();

                SellerName := CompanyInfo.Name;
                SellerAddress1 := CompanyInfo.Address;
                SellerAddress2 := CompanyInfo."Address 2";

                SellerAddress3 :=
                    StrSubstNo(
                        '%1 %2',
                        CompanyInfo.City,
                        CompanyInfo."Post Code");

                SellerGSTIN :=
                    CompanyInfo."GST Registration No.";

                Website := CompanyInfo."Home Page";
                ContactEmail := CompanyInfo."E-Mail";

                // Customer Information
                CustomerName := "Bill-to Name";
                CustomerAddress1 := "Bill-to Address";
                CustomerAddress2 := "Bill-to Address 2";

                CustomerAddress3 :=
                    StrSubstNo(
                        '%1 %2',
                        "Bill-to City",
                        "Bill-to Post Code");

                CustomerGSTIN := '';

                if CustomerRec.Get("Bill-to Customer No.") then
                    CustomerGSTIN :=
                        CustomerRec."GST Registration No.";

                // Posted Passenger Lines
                PostedLine.Reset();

                PostedLine.SetRange(
                    "Document No.",
                    "No.");

                PostedLine.SetFilter(
                    Type,
                    '<>%1',
                    PostedLine.Type::" ");

                PassengerCount := PostedLine.Count();

                if PostedLine.FindFirst() then begin
                    HeaderPNR := PostedLine.Description;

                    PlaceOfSupply :=
                        PostedLine."AIRIQ State";

                    // Source-level amounts are copied
                    // unchanged on each passenger line.
                    // Read only the first matching line.
                    CreditNoteValue :=
                        PostedLine."AIRIQ Sold Value";

                    TotalCancelCharges :=
                        PostedLine."AIRIQ XXLN Charges";

                    NetRefund :=
                        PostedLine."AIRIQ Refund Amount";

                    SourceCGST :=
                        PostedLine."AIRIQ Source CGST";

                    SourceSGST :=
                        PostedLine."AIRIQ Source SGST";

                    SourceIGST :=
                        PostedLine."AIRIQ Source IGST";
                end;

                // Ticket GST Reversal
                CGSTReversed := SourceCGST;
                SGSTReversed := SourceSGST;

                ValueExclGST :=
                    CreditNoteValue -
                    SourceCGST -
                    SourceSGST -
                    SourceIGST;

                // TEMPORARY DEMO GST RULE
                // 18% cancellation GST:
                // CGST 9% + SGST 9%.
                // Not verified against posted BC GST.
                CGSTOnCharges :=
                    Round(
                        TotalCancelCharges * 0.09,
                        0.01);

                SGSTOnCharges :=
                    Round(
                        TotalCancelCharges * 0.09,
                        0.01);

                // Actual source refund amount is retained.
                // Words conversion is pending.
                NetRefundInWords :=
                    Format(NetRefund) +
                    ' INR (demo; words conversion pending)';
            end;
        }
    }

    var
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
        CreditNoteValue: Decimal;
        TotalCancelCharges: Decimal;
        CGSTOnCharges: Decimal;
        SGSTOnCharges: Decimal;
        NetRefund: Decimal;

        NetRefundInWords: Text[250];
        Narration: Text[500];

        BankName: Text[100];
        BankAccountNo: Text[50];
        BankIFSC: Text[50];
        Website: Text[100];
        ContactEmail: Text[100];

        PassengerCount: Integer;

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
}
