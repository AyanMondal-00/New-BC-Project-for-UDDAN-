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
            column(TotalAmount; "Amount Including VAT") { }
            column(CommercialAmount; Amount) { }
            column(AmountInWords; AmountWordsText) { }
            column(BankName; CompanyInfo."Bank Name") { }
            column(BankAccount; CompanyInfo."Bank Account No.") { }
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
                column(Rate; "Unit Price") { }
                column(Amount; Amount) { }
                column(RowNumber; "Line No.") { }
            }
            dataitem(GST; "Detailed GST Ledger Entry")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = sorting("Entry No.") where("Transaction Type" = const(Sales), "Document Type" = const(Invoice), "Entry Type" = const("Initial Entry"));
                column(TaxEntryNo; "Entry No.") { }
                column(TaxComponent; "GST Component Code") { }
                column(TaxPercent; "GST %") { }
                // Sales invoice GST is a credit: negate, never ABS, to preserve correction signs.
                column(TaxAmount; -"GST Amount") { }
                column(TaxBase; -"GST Base Amount") { }
                column(TaxLineNo; "Document Line No.") { }
                trigger OnAfterGetRecord()
                var
                    PostedLine: Record "Sales Invoice Line";
                begin
                    // Original invoice presentation, not net-of-reversal accounting.
                    if "Reversal Entry" then
                        CurrReport.Skip();
                    if ("Source Type" <> "Source Type"::Customer) or
                       (("Source No." <> Invoice."Bill-to Customer No.") and
                        ("Source No." <> Invoice."Sell-to Customer No.")) then
                        CurrReport.Skip();
                    if ("Document Line No." <> 0) and
                       not PostedLine.Get(Invoice."No.", "Document Line No.") then
                        CurrReport.Skip();
                end;
            }
            trigger OnAfterGetRecord()
            var
                StateRec: Record State;
            begin
                if Count() <> 1 then
                    Error('Select exactly one posted Own Sales invoice using the No. filter.');
                CalcFields(Amount, "Amount Including VAT", "QR Code");
                SellerAddressText := '';
                AppendAddressLine(SellerAddressText, CompanyInfo.Address);
                AppendAddressLine(SellerAddressText, CompanyInfo."Address 2");
                AppendAddressLine(SellerAddressText, DelChr(CompanyInfo.City + ' ' + CompanyInfo."Post Code", '<>', ' '));
                CustomerAddressText := '';
                AppendAddressLine(CustomerAddressText, "Bill-to Address");
                AppendAddressLine(CustomerAddressText, "Bill-to Address 2");
                AppendAddressLine(CustomerAddressText, DelChr("Bill-to City" + ' ' + "Bill-to Post Code", '<>', ' '));
                AmountWordsText := '';
                AmountWordsText := RupeeWords("Amount Including VAT");
                SupplyState := '';
                // Mixed place-of-supply lines cannot be represented by one header state safely.
                if StateRec.Get(State) then
                    SupplyState := StateRec.Description + ' (' + StateRec.Code + ')';
            end;
        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;
    var
        CompanyInfo: Record "Company Information";
        SupplyState: Text;
        SellerAddressText: Text;
        CustomerAddressText: Text;
        AmountWordsText: Text;



    local procedure AppendAddressLine(var AddressText: Text; AddressPart: Text)
    var
        LineBreak: Text[2];
    begin
        AddressPart := DelChr(AddressPart, '<>', ' ,');
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
        Paise := Round((Value - Whole) * 100, 1);
        Prefix += IndianNumber(Whole);
        if Paise <> 0 then
            Prefix += ' And ' + IndianNumber(Paise) + ' Paise';
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
            Result := JoinWords(Result, SelectStr(Part - 1, 'Twenty,Thirty,Forty,Fifty,Sixty,Seventy,Eighty,Ninety'));
            Value := Value - Part * 10;
        end;
        if Value > 0 then
            Result := JoinWords(Result, SelectStr(Value, 'One,Two,Three,Four,Five,Six,Seven,Eight,Nine,Ten,Eleven,Twelve,Thirteen,Fourteen,Fifteen,Sixteen,Seventeen,Eighteen,Nineteen'));
        if Result = '' then
            Result := 'Zero';
        exit(Result);
    end;

    local procedure JoinWords(LeftText: Text; RightText: Text): Text
    begin
        if LeftText = '' then
            exit(RightText);
        exit(LeftText + ' ' + RightText);
    end;
}
