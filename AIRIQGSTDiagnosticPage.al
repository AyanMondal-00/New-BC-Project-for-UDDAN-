
page 50590 "AIRIQ GST Diagnostic"
{
    Caption = 'AIRIQ GST Diagnostic';
    PageType = List;
    SourceTable = "Tax Transaction Value";
    ApplicationArea = All;
    UsageCategory = Lists;

    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater("GST Transaction Details")
            {
                Editable = false;

                field("Tax Record ID"; Rec."Tax Record ID")
                {
                    ApplicationArea = All;
                }

                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = All;
                }

                field("Case ID"; Rec."Case ID")
                {
                    ApplicationArea = All;
                }

                field("Value Type"; Rec."Value Type")
                {
                    ApplicationArea = All;
                }

                field("Value ID"; Rec."Value ID")
                {
                    ApplicationArea = All;
                }

                field("Column Value"; Rec."Column Value")
                {
                    ApplicationArea = All;
                }

                field(Percent; Rec.Percent)
                {
                    ApplicationArea = All;
                }

                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }

                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                }

                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }

                field("Currency Factor"; Rec."Currency Factor")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadInvoice102048)
            {
                Caption = 'Load Invoice 102048';
                ApplicationArea = All;
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    LoadInvoiceGST('102048');
                end;
            }

            action(LoadInvoice102039)
            {
                Caption = 'Load Invoice 102039';
                ApplicationArea = All;
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    LoadInvoiceGST('102039');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        LoadInvoiceGST('102048');
    end;

    local procedure LoadInvoiceGST(InvoiceNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        TaxValue: Record "Tax Transaction Value";
        FilterText: Text;
        TotalRecords: Integer;
    begin
        Rec.Reset();

        SalesLine.Reset();
        SalesLine.SetRange(
            "Document Type",
            SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", InvoiceNo);

        if not SalesLine.FindSet() then begin
            Rec.SetRange("Tax Record ID", GetEmptyRecordId());

            Message(
                'Sales Invoice %1 was not found.',
                InvoiceNo);
            exit;
        end;

        repeat
            if FilterText <> '' then
                FilterText += '|';

            FilterText += Format(SalesLine.RecordId());
        until SalesLine.Next() = 0;

        Rec.SetFilter("Tax Record ID", FilterText);

        TaxValue.Reset();
        TaxValue.SetFilter("Tax Record ID", FilterText);
        TotalRecords := TaxValue.Count();

        if TotalRecords = 0 then
            Message(
                'Invoice %1 was found, but no GST transaction records matched its Sales Line RecordIds.',
                InvoiceNo);

        CurrPage.Update(false);
    end;

    local procedure GetEmptyRecordId(): RecordId
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.Init();
        SalesLine."Document Type" :=
            SalesLine."Document Type"::Invoice;
        SalesLine."Document No." := 'AIRIQ-NOT-FOUND';
        SalesLine."Line No." := -1;

        exit(SalesLine.RecordId());
    end;
}
