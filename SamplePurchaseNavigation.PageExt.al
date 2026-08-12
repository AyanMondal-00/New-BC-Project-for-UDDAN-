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
        }
    }
}




























