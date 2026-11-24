
pageextension 50320 "Sample Purchase Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action41)
        {
            group(SamplePurchaseFormats)
            {
                Caption = 'AIR IQ Purchase Format';

                action("Sample Purchase Format")
                {
                    ApplicationArea = All;
                    Caption = 'Normal Purchase Format';
                    RunObject = page "Sample Purchase List";
                }

                action("Third Party Sample Purchase")
                {
                    ApplicationArea = All;
                    Caption = 'Third Party Purchase';
                    RunObject = page "TP Sample Purchase List";
                }

                action("API Sample Purchase")
                {
                    ApplicationArea = All;
                    Caption = 'API Purchase';
                    RunObject = page "API Sample Purchase List";
                }
            }

            group("Posted Purchase Invoices")
            {
                Caption = 'Posted Purchase Invoices';

                action("Purchase Return")
                {
                    ApplicationArea = All;
                    Caption = 'Purchase Return';
                    RunObject = page "Purchase Return";
                }
            }
        }
    }
}
