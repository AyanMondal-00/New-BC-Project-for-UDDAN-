pageextension 50321 "Airline Inventory Navigation" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action39)
        {
            action("Airline Inventory Payment Due")
            {
                ApplicationArea = All;
                Caption = 'AIRLINE INVENTORY AND PAYMENT DUE FORMAT';
                RunObject = page "Airline Inventory Payment Due";
            }
        }
    }
}