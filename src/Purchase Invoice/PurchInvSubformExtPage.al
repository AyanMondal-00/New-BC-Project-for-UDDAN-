pageextension 50335 "Purch Inv Subform Ext" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Sample Purchase Date"; Rec."Sample Purchase Date")
            {
                ApplicationArea = All;
            }

            field("Sample Entry Date"; Rec."Sample Entry Date")
            {
                ApplicationArea = All;
            }

            field("Sample Travel Date"; Rec."Sample Travel Date")
            {
                ApplicationArea = All;
            }

            field("Sample Airline"; Rec."Sample Airline")
            {
                ApplicationArea = All;
            }

            field("Sample Sector"; Rec."Sample Sector")
            {
                ApplicationArea = All;
            }

            field("Sample Flight Type"; Rec."Sample Flight Type")
            {
                ApplicationArea = All;
            }

            field("Sample Supplier ID"; Rec."Sample Supplier ID")
            {
                ApplicationArea = All;
            }

            field("Sample Base Fare"; Rec."Sample Base Fare")
            {
                ApplicationArea = All;
            }

            field("Sample Other Charges"; Rec."Sample Other Charges")
            {
                ApplicationArea = All;
            }


        }
    }
}