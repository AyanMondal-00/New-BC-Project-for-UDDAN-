
report 50390 "AIRIQ Sales Invoice"
{
    Caption = 'AIRIQ Sales Invoice';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'RDL File for Sales format/AIRIQ_Sales_Invoice.rdl';

    dataset
    {
        dataitem(Invoice; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.") where("Sales Type" = const("Own Sales"));
            RequestFilterFields = "No.", "Posting Date", "Bill-to Customer No.";

            column(InvoiceNo; "No.") { }
            column(ReferenceNo; "AQ Number") { }
            column(InvoiceDate; "Posting Date") { }
            column(PlaceOfSupply; SupplyState) { }
            column(SellerName; CompanyInfo.Name) { }
            column(SellerAddress; SellerAddressText) { }
            column(SellerGSTIN; "Location GST Reg. No.") { }
            column(CustomerName; "Bill-to Name") { }
            column(CustomerAddress; CustomerAddressText) { }
            column(CustomerGSTIN; "Customer GST Reg. No.") { }
            column(TotalAmount; OriginalInvoiceAmount) { }
            column(CommercialAmount; Amount) { }
            column(AmountInWords; AmountWordsText) { }
            column(BankName; CompanyInfo."Bank Name") { }
            column(BankAccount; CompanyInfo."Bank Account No.") { }
            column(BankIFSC; BankIFSCText) { }
            column(EInvoiceStatus; EInvoiceStatusText) { }
            column(Website; CompanyInfo."Home Page") { }
            column(ContactEmail; CompanyInfo."E-Mail") { }
            column(Narration; "Posting Description") { }
            column(IRN; "IRN Hash") { }
            column(AckNo; "Acknowledgement No.") { }
            column(AckDate; "Acknowledgement Date") { }
            column(QRImage; "QR Code") { }

            dataitem(InvoiceLine; "Sales Invoice Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");

                column(PassengerName; "Passenger Name") { }
                column(PNR; Description) { }
                column(TravelDate; "Travel Date") { }
                column(SAC; "HSN/SAC Code") { }
                column(Qty; Quantity) { }
                column(Rate; InclusiveRate) { }
                column(Amount; InclusiveAmount) { }
                column(RowNumber; "Line No.") { }

                trigger OnAfterGetRecord()
                begin
                    if (Quantity = 0) and
                       (Amount = 0) and
                       (GetLineGST(Invoice, "Line No.") = 0)
                    then begin
                        CurrReport.Skip();
                        exit;
                    end;

                    InclusiveAmount :=
                        Amount + GetLineGST(Invoice, "Line No.");

                    InclusiveRate :=
                        InclusiveAmount / Quantity;
                end;
            }

            dataitem(GST; "Detailed GST Ledger Entry")
            {
                DataItemLink = "Document No." = field("No.");

                DataItemTableView = sorting("Entry No.")
                    where(
                        "Transaction Type" = const(Sales),
                        "Document Type" = const(Invoice),
                        "Entry Type" = const("Initial Entry")
                    );

                column(TaxEntryNo; "Entry No.") { }
                column(TaxComponent; "GST Component Code") { }
                column(TaxPercent; "GST %") { }

                // Negate sales GST credit values.
                // Do not use ABS, as it removes correction signs.
                column(TaxAmount; -"GST Amount") { }
                column(TaxBase; -"GST Base Amount") { }
                column(TaxLineNo; "Document Line No.") { }

                trigger OnAfterGetRecord()
                begin
                    if not IsOriginalGST(GST, Invoice) then
                        CurrReport.Skip();
                end;
            }

            trigger OnAfterGetRecord()
            var
                StateRec: Record State;
                SupplyCode: Code[10];
            begin
                if Count() <> 1 then
                    Error(
                        'Select exactly one posted Own Sales invoice using the No. filter.');

                CalcFields(
                    Amount,
                    "Amount Including VAT",
                    "QR Code");

                SellerAddressText := '';

                AppendAddressLine(
                    SellerAddressText,
                    CompanyInfo.Address);

                AppendAddressLine(
                    SellerAddressText,
                    CompanyInfo."Address 2");

                AppendAddressLine(
                    SellerAddressText,
                    DelChr(
                        CompanyInfo.City + ' ' +
                        CompanyInfo."Post Code",
                        '<>', ' '));

                CustomerAddressText := '';

                AppendAddressLine(
                    CustomerAddressText,
                    "Bill-to Address");

                AppendAddressLine(
                    CustomerAddressText,
                    "Bill-to Address 2");

                AppendAddressLine(
                    CustomerAddressText,
                    DelChr(
                        "Bill-to City" + ' ' +
                        "Bill-to Post Code",
                        '<>', ' '));

                // Fetch and reconcile actual posted amounts.
                PrepareInvoiceAmounts(
                    Invoice,
                    SupplyCode);

                AmountWordsText :=
                    RupeeWords(OriginalInvoiceAmount);

                SupplyState := '';

                if StateRec.Get(SupplyCode) then
                    SupplyState :=
                        StateRec.Description +
                        ' (' + StateRec.Code + ')'
                else
                    SupplyState := SupplyCode;

                EInvoiceStatusText := 'Not available';

                if "IRN Hash" <> '' then
                    EInvoiceStatusText := 'IRN available';
            end;
        }
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get();

        BankIFSCText := '—';

        if StrLen(CompanyInfo."Bank Branch No.") = 11 then
            BankIFSCText :=
                CompanyInfo."Bank Branch No.";
    end;

    var
        CompanyInfo: Record "Company Information";
        SupplyState: Text;
        SellerAddressText: Text;
        CustomerAddressText: Text;
        AmountWordsText: Text;
        OriginalInvoiceAmount: Decimal;
        InclusiveRate: Decimal;
        InclusiveAmount: Decimal;
        EInvoiceStatusText: Text;
        BankIFSCText: Text;

    local procedure PrepareInvoiceAmounts(
        Header: Record "Sales Invoice Header";
        var SupplyCode: Code[10])
    var
        CustEntry: Record "Cust. Ledger Entry";
        PostedLine: Record "Sales Invoice Line";
        TaxEntry: Record "Detailed GST Ledger Entry";
        GLSetup: Record "General Ledger Setup";
        NetTotal: Decimal;
        GSTTotal: Decimal;
        LineGSTTotal: Decimal;
        LineGST: Decimal;
        CurrentSupplyCode: Code[10];
    begin
        // This layout currently supports INR local currency.
        GLSetup.Get();

        if (Header."Currency Code" <> '') or
           ((GLSetup."LCY Code" <> '') and
            (GLSetup."LCY Code" <> 'INR'))
        then
            Error(
                'Invoice %1: this layout supports INR local-currency invoices only.',
                Header."No.");

        // Do not mix standard VAT with the GST-only layout.
        if Round(
            Header."Amount Including VAT" -
            Header.Amount, 0.01) <> 0
        then
            Error(
                'Invoice %1 contains VAT. This GST-only layout cannot reconcile it.',
                Header."No.");

        // Fetch the original posted customer invoice amount.
        CustEntry.SetRange(
            "Document Type",
            CustEntry."Document Type"::Invoice);

        CustEntry.SetRange(
            "Document No.",
            Header."No.");

        CustEntry.SetRange(
            "Customer No.",
            Header."Bill-to Customer No.");

        CustEntry.SetRange(
            "Posting Date",
            Header."Posting Date");

        CustEntry.SetRange(
            "Currency Code",
            Header."Currency Code");

        if CustEntry.Count() <> 1 then
            Error(
                'Invoice %1: expected exactly one original customer ledger invoice entry.',
                Header."No.");

        CustEntry.FindFirst();
        CustEntry.CalcFields("Original Amount");

        OriginalInvoiceAmount :=
            CustEntry."Original Amount";

        SupplyCode := '';

        // Fetch original posted GST ledger data.
        SetGSTFilters(TaxEntry, Header);

        if TaxEntry.FindSet() then
            repeat
                if IsOriginalGST(TaxEntry, Header) then begin

                    GSTTotal -= TaxEntry."GST Amount";

                    CurrentSupplyCode := GetGSTSupplyCode(TaxEntry, Header);

                    if CurrentSupplyCode = '' then
                        Error(
                            'Invoice %1: posted GST place of supply is unavailable.',
                            Header."No.");

                    if (SupplyCode <> '') and
                       (SupplyCode <> CurrentSupplyCode)
                    then
                        Error(
                            'Invoice %1 has multiple GST places of supply. A single-state invoice cannot be printed.',
                            Header."No.");

                    SupplyCode := CurrentSupplyCode;
                end;
            until TaxEntry.Next() = 0;

        if SupplyCode = '' then
            SupplyCode := Header.State;

        // Validate the passenger-wise amounts.
        PostedLine.SetRange(
            "Document No.",
            Header."No.");

        if PostedLine.FindSet() then
            repeat
                LineGST :=
                    GetLineGST(
                        Header,
                        PostedLine."Line No.");

                if (PostedLine.Quantity = 0) and
                   ((PostedLine.Amount <> 0) or
                    (LineGST <> 0))
                then
                    Error(
                        'Invoice %1, line %2: nonzero amount with zero quantity.',
                        Header."No.",
                        PostedLine."Line No.");

                NetTotal += PostedLine.Amount;
                LineGSTTotal += LineGST;

            until PostedLine.Next() = 0;

        // Financial reconciliation before invoice printing.
        if (Round(NetTotal - Header.Amount, 0.01) <> 0) or
           (Round(LineGSTTotal - GSTTotal, 0.01) <> 0) or
           (Round(
                NetTotal + GSTTotal -
                OriginalInvoiceAmount, 0.01) <> 0)
        then
            Error(
                'Invoice %1 does not reconcile. Net %2 + GST %3 = %4; customer original amount %5. Printing stopped.',
                Header."No.",
                NetTotal,
                GSTTotal,
                NetTotal + GSTTotal,
                OriginalInvoiceAmount);
    end;

    local procedure SetGSTFilters(
        var TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Invoice Header")
    begin
        TaxEntry.Reset();

        TaxEntry.SetRange(
            "Document No.",
            Header."No.");

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

    local procedure IsOriginalGST(
        TaxEntry: Record "Detailed GST Ledger Entry";
        Header: Record "Sales Invoice Header"): Boolean
    var
        PostedLine: Record "Sales Invoice Line";
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

        if TaxEntry."Document Line No." <> 0 then
            if not PostedLine.Get(
                Header."No.",
                TaxEntry."Document Line No.")
            then
                Error(
                    'Invoice %1: GST entry %2 has no matching posted line.',
                    Header."No.",
                    TaxEntry."Entry No.");

        exit(true);
    end;

    local procedure GetLineGST(
        Header: Record "Sales Invoice Header";
        LineNo: Integer): Decimal
    var
        TaxEntry: Record "Detailed GST Ledger Entry";
        Result: Decimal;
    begin
        SetGSTFilters(TaxEntry, Header);

        TaxEntry.SetRange(
            "Document Line No.",
            LineNo);

        if TaxEntry.FindSet() then
            repeat
                if IsOriginalGST(TaxEntry, Header) then
                    Result -= TaxEntry."GST Amount";

            until TaxEntry.Next() = 0;

        exit(Result);
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

    local procedure AppendAddressLine(
        var AddressText: Text;
        AddressPart: Text)
    var
        LineBreak: Text[2];
    begin
        AddressPart :=
            DelChr(AddressPart, '<>', ' ,');

        if AddressPart = '' then
            exit;

        LineBreak[1] := 13;
        LineBreak[2] := 10;

        if AddressText <> '' then
            AddressText += LineBreak;

        AddressText += AddressPart;
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

            Part :=
                Round(Value / 10000000, 1, '<');

            Result :=
                IndianNumber(Part) + ' Crore';

            Value :=
                Value - Part * 10000000;
        end;

        if Value >= 100000 then begin

            Part :=
                Round(Value / 100000, 1, '<');

            Result :=
                JoinWords(
                    Result,
                    IndianNumber(Part) + ' Lakh');

            Value :=
                Value - Part * 100000;
        end;

        if Value >= 1000 then begin

            Part :=
                Round(Value / 1000, 1, '<');

            Result :=
                JoinWords(
                    Result,
                    IndianNumber(Part) + ' Thousand');

            Value :=
                Value - Part * 1000;
        end;

        if Value >= 100 then begin

            Part :=
                Round(Value / 100, 1, '<');

            Result :=
                JoinWords(
                    Result,
                    IndianNumber(Part) + ' Hundred');

            Value :=
                Value - Part * 100;
        end;

        if Value >= 20 then begin

            Part :=
                Round(Value / 10, 1, '<');

            Result :=
                JoinWords(
                    Result,
                    SelectStr(
                        Part - 1,
                        'Twenty,Thirty,Forty,Fifty,Sixty,Seventy,Eighty,Ninety'));

            Value :=
                Value - Part * 10;
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
