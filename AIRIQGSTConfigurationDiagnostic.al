
page 50591 "AIRIQ GST Config Diagnostic"
{
    Caption = 'AIRIQ GST Configuration Diagnostic';
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
            repeater(GSTDetails)
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

                field(FlightType; FlightTypeValue)
                {
                    Caption = 'Flight Type';
                    ApplicationArea = All;
                }

                field(SalesLineAmount; SalesLineAmountValue)
                {
                    Caption = 'Sales Line Amount';
                    ApplicationArea = All;
                }

                field(ExpectedGSTBase; ExpectedGSTBaseValue)
                {
                    Caption = 'Expected AIRIQ GST Base';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(LoadInvoice)
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
        }
    }

    trigger OnOpenPage()
    begin
        LoadInvoiceGST('102048');
    end;

    trigger OnAfterGetRecord()
    var
        SalesLine: Record "Sales Line";
    begin
        Clear(FlightTypeValue);
        Clear(SalesLineAmountValue);
        Clear(ExpectedGSTBaseValue);

        if Rec."Tax Record ID".TableNo() <> Database::"Sales Line" then
            exit;

        if not SalesLine.Get(Rec."Tax Record ID") then
            exit;

        FlightTypeValue := SalesLine.FlightType;
        SalesLineAmountValue := SalesLine.Amount;

        case UpperCase(DelChr(FlightTypeValue, '<>', ' ')) of
            'DOMESTIC':
                ExpectedGSTBaseValue :=
                    Round(SalesLine.Amount * 0.05, 0.01);

            'INTERNATIONAL':
                ExpectedGSTBaseValue :=
                    Round(SalesLine.Amount * 0.10, 0.01);
        end;
    end;

    local procedure LoadInvoiceGST(InvoiceNo: Code[20])
    var
        SalesLine: Record "Sales Line";
        FilterText: Text;
    begin
        Rec.Reset();

        SalesLine.Reset();
        SalesLine.SetRange(
            "Document Type",
            SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", InvoiceNo);

        if not SalesLine.FindSet() then begin
            Rec.SetRange("Tax Record ID", GetEmptyRecordId());
            CurrPage.Update(false);
            exit;
        end;

        repeat
            if FilterText <> '' then
                FilterText += '|';

            FilterText += Format(SalesLine.RecordId());
        until SalesLine.Next() = 0;

        Rec.SetFilter("Tax Record ID", FilterText);
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

    var
        FlightTypeValue: Text[50];
        SalesLineAmountValue: Decimal;
        ExpectedGSTBaseValue: Decimal;
}
