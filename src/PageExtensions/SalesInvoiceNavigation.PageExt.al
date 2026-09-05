pageextension 50420 "Sales Invoice Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action40)
        {
            group(SalesInvoiceFormats)
            {
                Caption = 'Sales Invoice Formats';

                action("Own Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Own Sales';
                    RunObject = page "Normal Sales List";
                }

                action("API Sales Format")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API Sales Format';
                    RunObject = page "API Sales Format List";
                }

                action("Third-Party Sales ")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Third-Party Sales ';
                    RunObject = page "Third Party Sales List";
                }

            }
            group(PostedSalesReturn)
            {
                Caption = 'Posted Sales Return';

                action("Sales Return")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Return';
                    RunObject = page "Sales Return List";
                }
            }
        }
    }
}