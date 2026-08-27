pageextension 50320 "Sample Purchase Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action41)
        {
            action("Sample Purchase Format")
            {
                ApplicationArea = All;
                Caption = 'Sample Purchase Format';
                RunObject = page "Sample Purchase List";
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