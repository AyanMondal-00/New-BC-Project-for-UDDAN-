tableextension 50429 "AIRIQ Posted Sales Header Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(50424; "AQ Number"; Integer)
        {
            Caption = 'AQ Number';
            DataClassification = CustomerContent;
        }

        field(50425; "Agency ID"; Code[20])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(50426; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionMembers = "Own Sales", "API Sales", "Third Party Sales";
            DataClassification = CustomerContent;
        }
    }
}