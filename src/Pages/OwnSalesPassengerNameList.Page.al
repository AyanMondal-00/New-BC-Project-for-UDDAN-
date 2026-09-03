page 50412 "Own Sales Passenger List Name"
{
    Caption = 'Passenger Name List';
    PageType = List;
    SourceTable = "Own Sales Passenger Name";
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(InvoiceDetails)
            {
                Caption = 'Invoice Details';

                field("Invoice No."; CurrentInvoiceNumber)
                {
                    ApplicationArea = All;
                    Caption = 'Invoice No.';
                    Editable = false;
                }
            }

            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Passenger Name"; Rec."Passenger Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Passenger: Record "Own Sales Passenger Name";
    begin
        Rec."Invoice Number" := CurrentInvoiceNumber;

        Passenger.Reset();
        Passenger.SetRange("Invoice Number", CurrentInvoiceNumber);

        if Passenger.FindLast() then
            Rec."Entry No." := Passenger."Entry No." + 1
        else
            Rec."Entry No." := 1;
    end;

    procedure SetInvoiceNumber(InvoiceNo: Code[50])
    begin
        CurrentInvoiceNumber := InvoiceNo;
        Rec.SetRange("Invoice Number", CurrentInvoiceNumber);
    end;

    var
        CurrentInvoiceNumber: Code[50];
}