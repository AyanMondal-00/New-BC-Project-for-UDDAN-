
pageextension 50342 "Posted Purch Inv Subform Ext" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Sample Purchase Date"; Rec."Sample Purchase Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original sample purchase date.';
            }

            field("Sample Entry Date"; Rec."Sample Entry Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original sample entry date.';
            }

            field("Sample Travel Date"; Rec."Sample Travel Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original sample travel date.';
            }

            field("Sample Airline"; Rec."Sample Airline")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the airline.';
            }

            field("Sample Sector"; Rec."Sample Sector")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the travel sector.';
            }

            field("Sample Flight Type"; Rec."Sample Flight Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the flight type.';
            }

            field("Sample Supplier ID"; Rec."Sample Supplier ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the supplier ID.';
            }

            field("Sample Base Fare"; Rec."Sample Base Fare")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sample base fare.';
            }

            field("Sample Other Charges"; Rec."Sample Other Charges")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the sample other charges.';
            }
        }
    }
}
