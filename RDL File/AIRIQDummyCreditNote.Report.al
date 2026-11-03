report 50391 "AIRIQ Credit Note Invoice"
{
    Caption = 'AIRIQ Credit Note Invoice';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'RDL File/AIRIQ_CreditNote.rdl';

    dataset
    {
        dataitem(Header; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
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

            dataitem(PassengerLine; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
                column(SlNo; Number) { }
                column(PassengerName; LinePassengerName) { }
                column(LinePNR; LinePNR) { }
                column(TravelDate; LineTravelDate) { }
                column(SAC; LineSAC) { }
                column(Qty; LineQty) { }
                column(TktValue; LineTktValue) { }
                column(CancelCharge; LineCancelCharge) { }
                column(LineGST; LineGST) { }
                column(RefundAmount; LineRefundAmount) { }

                trigger OnAfterGetRecord()
                begin
                    case Number of
                        1:
                            begin
                                LinePassengerName := 'Gita Agarwal';
                                LinePNR := 'PNR5625X';
                                LineTravelDate := '08 Sep 2026';
                                LineSAC := '998555';
                                LineQty := 1;
                                LineTktValue := 6300.00;
                                LineCancelCharge := 1500.00;
                                LineGST := 270.00;
                                LineRefundAmount := 4530.00;
                            end;
                        2:
                            begin
                                LinePassengerName := 'Mohan Agarwal';
                                LinePNR := 'PNR5625X';
                                LineTravelDate := '08 Sep 2026';
                                LineSAC := '998555';
                                LineQty := 1;
                                LineTktValue := 6300.00;
                                LineCancelCharge := 1500.00;
                                LineGST := 270.00;
                                LineRefundAmount := 4530.00;
                            end;
                    end;
                end;
            }

            dataitem(GSTSummary; Integer)
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 .. 2));
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
                                ReversedOnTickets := 40.50;
                                OnCancelChg := 270.00;
                                NetGST := 229.50;
                            end;
                        2:
                            begin
                                TaxComponent := 'SGST';
                                TaxRate := '9%';
                                ReversedOnTickets := 40.50;
                                OnCancelChg := 270.00;
                                NetGST := 229.50;
                            end;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                CreditNoteNo := 'CN-103002-01';
                RefNo := '—';
                CreditNoteDate := '15 Sep 2026';
                PlaceOfSupply := 'West Bengal (19)';
                AgainstInvoiceNo := '103002';
                InvoiceDate := '08 Sep 2026';
                HeaderPNR := 'PNR5625X';
                Reason := 'Ticket cancellation (2 of 5 pax)';

                SellerName := 'AIRIQ 365 LIMITED';
                SellerAddress1 := 'Ground, 1st & 2nd Floor, Asmi Square';
                SellerAddress2 := 'Ward No. 43, 2nd Mile, Sevoke Road';
                SellerAddress3 := 'Siliguri – 734001, India';
                SellerGSTIN := '—';

                CustomerName := 'A. Agarwal Pvt Ltd';
                CustomerAddress1 := 'Sevoke Road';
                CustomerAddress2 := 'Siliguri, West Bengal';
                CustomerAddress3 := 'India';
                CustomerGSTIN := '—';

                ValueExclGST := 12519.00;
                CGSTReversed := 40.50;
                SGSTReversed := 40.50;
                CreditNoteValue := 12600.00;
                TotalCancelCharges := 3000.00;
                CGSTOnCharges := 270.00;
                SGSTOnCharges := 270.00;
                NetRefund := 9060.00;
                NetRefundInWords := 'Indian Rupees Nine Thousand Sixty Only';

                Narration := 'Being credit note issued against Invoice No. 103002 dated 08 Sep 2026 for cancellation of 2 passengers (Gita Agarwal, Mohan Agarwal) on PNR5625X; cancellation charges with GST @ 18% deducted.';
                BankName := 'State Bank of India';
                BankAccountNo := 'SBI 133667466';
                BankIFSC := '—';
                Website := 'airiq.in';
                ContactEmail := 'accounts@airiq.in';
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
