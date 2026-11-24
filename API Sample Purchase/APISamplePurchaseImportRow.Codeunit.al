codeunit 50311 "API SP Purchase Import Row"
{
    TableNo = "API Sample Purchase";
    trigger OnRun()
    begin
        Rec.Insert(true);
    end;
}
