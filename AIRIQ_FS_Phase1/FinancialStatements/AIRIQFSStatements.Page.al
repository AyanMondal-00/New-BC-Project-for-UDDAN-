page 50731 "AIRIQ FS Statements"
{
    Caption = 'AIRIQ Financial Statement Definitions';
    PageType = List;
    SourceTable = "AIRIQ FS Statement";
    ApplicationArea = All;
    UsageCategory = Lists;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
            }
        }
    }
}
