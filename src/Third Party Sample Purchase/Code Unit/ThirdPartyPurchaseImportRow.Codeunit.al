codeunit 50667 "TP Purchase Import Row"
{
    TableNo = "Third Party Sample Purchase";
    trigger OnRun()
    begin
        Rec.Insert(true);
    end;
}
