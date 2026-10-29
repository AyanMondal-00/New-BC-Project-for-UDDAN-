
report 50390 "AIRIQ Dummy Invoice"
{
    Caption = 'AIRIQ Dummy Invoice';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    DefaultLayout = RDLC;
    RDLCLayout = 'design.rdl';

    dataset
    {
        dataitem(InvoiceRows; Integer)
        {
            DataItemTableView = sorting(Number)
                where(Number = filter(1..3));

            column(InvoiceNo; '103002') { }
            column(ReferenceNo; 'SAMPLE') { }
            column(InvoiceDate; '08 Sep 2026') { }
            column(PlaceOfSupply; 'West Bengal (19)') { }

            column(SellerName; 'AIRIQ 365 LIMITED') { }
            column(SellerAddress; 'Siliguri, West Bengal') { }
            column(SellerGSTIN; 'SAMPLE') { }

            column(CustomerName; 'Sample Customer') { }
            column(CustomerAddress; 'Siliguri, India') { }
            column(CustomerGSTIN; 'SAMPLE') { }

            column(PassengerName; GetPassengerName(Number)) { }
            column(PNR; 'PNR001') { }
            column(TravelDate; '08 Sep 2026') { }
            column(SAC; '998555') { }
            column(Qty; 1) { }
            column(Rate; 6300.00) { }
            column(Amount; 6300.00) { }

            column(CGSTAmount; 0.00) { }
            column(SGSTAmount; 0.00) { }
            column(TotalAmount; 18900.00) { }
            column(AmountInWords; 'Eighteen Thousand Nine Hundred Only') { }

            column(BankName; 'Sample Bank') { }
            column(BankAccount; 'XXXXX') { }
            column(Website; 'airiq.in') { }
            column(ContactEmail; 'accounts@airiq.in') { }

            column(Narration;
                'Being air tickets issued to the sample customer.') { }

            column(RowNumber; Number) { }
        }
    }

    requestpage
    {
        AboutTitle = 'AIRIQ Dummy Invoice';
        AboutText = 'Preview the sample AIRIQ invoice layout.';
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }
    }

    local procedure GetPassengerName(RowNo: Integer): Text[100]
    begin
        case RowNo of
            1:
                exit('Sample Passenger 1');
            2:
                exit('Sample Passenger 2');
            3:
                exit('Sample Passenger 3');
        end;

        exit('');
    end;
}
