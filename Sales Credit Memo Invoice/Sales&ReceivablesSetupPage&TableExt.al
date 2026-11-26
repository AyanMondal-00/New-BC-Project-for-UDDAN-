tableextension 50650 "Sales Receivables Setup Ext" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50650; "Credit Memo Cancilation G/L"; Code[20])
        {
            Caption = 'Credit Memo Cancilation G/L';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
    }
}

pageextension 50651 "Sales Receivables Setup PExt" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Report Output Type")
        {
            field("Credit Memo Cancilation G/L"; Rec."Credit Memo Cancilation G/L")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the G/L account for credit memo cancellation charges.';
            }
        }
    }
}