
page 50451 "Commission Calculation"
{
    PageType = List;
    Caption = 'Commission Calculation';
    SourceTable = "Commission Calculation";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field(Purchase; Rec.Purchase)
                {
                    ApplicationArea = All;
                }

                field("Purchase Return"; Rec."Purchase Return")
                {
                    ApplicationArea = All;
                }

                field("Available Commission"; Rec."Available Commission")
                {
                    ApplicationArea = All;
                }

                field("Commission Percentage"; Rec."Commission Percentage")
                {
                    ApplicationArea = All;
                }

                field("Total Commission"; Rec."Total Commission")
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
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
            action("Choose Date to Date")
            {
                Caption = 'Choose Date to Date';
                ApplicationArea = All;
                Image = DateRange;

                trigger OnAction()
                var
                    DateDialog: Page "Commission Sync Date Request";
                    SyncMgt: Codeunit "Commission Calculation Sync";
                begin
                    if DateDialog.RunModal() = Action::OK then
                        SyncMgt.SyncPostedPurchaseInvoices(
                            DateDialog.GetStartDate(),
                            DateDialog.GetEndDate());

                    CurrPage.Update(false);
                end;
            }
        }
    }
}
