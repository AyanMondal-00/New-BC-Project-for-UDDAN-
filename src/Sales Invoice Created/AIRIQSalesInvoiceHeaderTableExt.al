tableextension 50424 "AIRIQ Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(50424; "AQ Number"; Integer)
        {
            Caption = 'AQ Number';
            DataClassification = CustomerContent;
        }

        field(50425; "Agency ID"; Code[30])
        {
            Caption = 'Agency ID';
            DataClassification = CustomerContent;
        }

        field(50426; "Sales Type"; Option)
        {
            Caption = 'Sales Type';
            OptionMembers = "Own Sales","API Sales","Third Party Sales";
            DataClassification = CustomerContent;
        }
    }
}