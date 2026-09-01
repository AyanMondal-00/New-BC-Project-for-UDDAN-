page 50313 "Airline Inventory Payment Due"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Airline Inventory Payment Due";
    Caption = 'AIRLINE INVENTORY AND PAYMENT DUE FORMAT';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Purchase Date"; Rec."Purchase Date")
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field("PAX Count"; Rec."PAX Count")
                {
                    ApplicationArea = All;
                }

                field("Per PAX Rate"; Rec."Per PAX Rate")
                {
                    ApplicationArea = All;
                }

                field("Total Value"; Rec."Total Value")
                {
                    ApplicationArea = All;
                }

                field("Amount Paid"; Rec."Amount Paid")
                {
                    ApplicationArea = All;
                }

                field("Balance Due"; Rec."Balance Due")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field(Remark; Rec.Remark)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        SyncCodeunit: Codeunit "Sample Purchase Inventory Sync";
    begin
        SyncCodeunit.SyncAllSamplePurchases();
    end;
}