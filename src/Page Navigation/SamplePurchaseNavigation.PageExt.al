
pageextension 50320 "Sample Purchase Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action41)
        {
            group("AIR IQ Purchase Formats")
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

            group("AIR IQ Purchase Return")
            {
                Caption = 'AIR IQ Purchase Return';

                action("Normal Purchase Return")
                {
                    ApplicationArea = All;
                    Caption = 'Normal Purchase Return';
                    RunObject = page "Purchase Return";
                }
                action("Third Party Purchase Return")
                {
                    ApplicationArea = All;
                    Caption = 'Third Party Purchase Return';
                    RunObject = page "Third Party Purchase Return";
                }
                action("API Purchase Return")
                {
                    ApplicationArea = All;
                    Caption = 'API Purchase Return';
                    RunObject = page "API Purchase Return";
                }
            }
        }
    }
}
