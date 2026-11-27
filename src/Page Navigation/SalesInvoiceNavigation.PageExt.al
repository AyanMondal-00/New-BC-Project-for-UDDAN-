pageextension 50420 "Sales Invoice Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action40)
        {
            group("AIR IQ Sales Invoice Formats")
            {
                Caption = 'AIR IQ Sales Invoice Formats';

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

                action("Third-Party Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Third-Party Sales';
                    RunObject = page "Third Party Sales List";
                }
            }

            group("AIR IQ Sales Return")
            {
                Caption = 'AIR IQ Sales Return';

                action("Sales Return")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Normal Sales Return';
                    RunObject = page "Sales Return List";
                }

                action("Third Party Sales Return")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Third Party Sales Return';
                    RunObject = page "Third Party Sales Return";
                }

                action("API Sales Return")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'API Sales Return';
                    RunObject = page "API Sales Return";
                }
            }
        }
    }
}