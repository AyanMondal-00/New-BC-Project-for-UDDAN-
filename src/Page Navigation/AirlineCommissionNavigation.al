
pageextension 50421 "Airline Commission Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action39)
        {
            group(AirlineCommissionCalculator)
            {
                Caption = 'AirLine Commission Calculator';

                action(PLB)
                {
                    ApplicationArea = All;
                    Caption = 'PLB';
                    RunObject = page "PLB";
                }

                action(MLB)
                {
                    ApplicationArea = All;
                    Caption = 'MLB';
                    RunObject = page "MLB";
                }

                action(AnnualPLB)
                {
                    ApplicationArea = All;
                    Caption = 'Annual PLB';
                    RunObject = page "Annual PLB";
                }

                action(TargetIncentive)
                {
                    ApplicationArea = All;
                    Caption = 'Target Incentive';
                    RunObject = page "Target Incentive";
                }

                action(CashBack)
                {
                    ApplicationArea = All;
                    Caption = 'Cash Back';
                    RunObject = page "Cash Back";
                }

                action(CMFTFFE)
                {
                    ApplicationArea = All;
                    Caption = 'CMF/TFFE';
                    RunObject = page "CMF TFFE";
                }
            }
        }
    }
}
