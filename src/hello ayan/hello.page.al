page 50601 "hello"
{
    Caption = 'Hello';
    PageType = List;
    SourceTable = "hello";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Agent ID"; Rec."Agent ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}