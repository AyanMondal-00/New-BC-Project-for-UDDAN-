table 50715 "AIRIQ SR Return Registry" {
DataClassification = CustomerContent;
fields { field(1; "Return No."; Code[50]) { DataClassification = CustomerContent; } field(2; "Serial No."; Integer) { DataClassification = SystemMetadata; } }
keys { key(PK; "Return No.") { Clustered = true; } }
}
codeunit 50716 "AIRIQ SR Integrity" {
Permissions = tabledata "AIRIQ SR Return Registry" = rimd;
procedure Audit()
var Source: Record "Sales Return";
begin Source.LockTable(); if Source.FindSet() then repeat Claim(Source); until Source.Next() = 0; end;
local procedure Claim(Source: Record "Sales Return")
var Registry: Record "AIRIQ SR Return Registry"; Other: Record "Sales Return";
begin
if Source.IsTemporary() or (Source."Return No." = '') then exit;
Registry.LockTable();
if Registry.Get(Source."Return No.") then begin
if Registry."Serial No." <> Source."Serial No." then Error('Sales Return with Return No. %1 already exists.', Source."Return No.");
end else begin Registry.Init(); Registry."Return No." := Source."Return No."; Registry."Serial No." := Source."Serial No."; Registry.Insert(); end;
Other.SetRange("Return No.", Source."Return No."); Other.SetFilter("Serial No.", '<>%1', Source."Serial No.");
if not Other.IsEmpty() then Error('Sales Return with Return No. %1 already exists.', Source."Return No.");
end;
local procedure Release(Source: Record "Sales Return")
var Registry: Record "AIRIQ SR Return Registry";
begin if Source.IsTemporary() or (Source."Return No." = '') then exit; Registry.LockTable(); if Registry.Get(Source."Return No.") then if Registry."Serial No." = Source."Serial No." then Registry.Delete(); end;
[EventSubscriber(ObjectType::Table, Database::"Sales Return", 'OnAfterInsertEvent', '', false, false)]
local procedure Inserted(var Rec: Record "Sales Return"; RunTrigger: Boolean)
begin Claim(Rec); end;
[EventSubscriber(ObjectType::Table, Database::"Sales Return", 'OnAfterModifyEvent', '', false, false)]
local procedure Modified(var Rec: Record "Sales Return"; var xRec: Record "Sales Return"; RunTrigger: Boolean)
begin
if Rec.IsTemporary() then exit;
if xRec."AIRIQ Memo Created" and (Rec."Return No." <> xRec."Return No.") then Error('Return No. cannot change after Sales Credit Memo %1 was created.', xRec."AIRIQ Memo No.");
if Rec."Return No." <> xRec."Return No." then Release(xRec); Claim(Rec);
end;
[EventSubscriber(ObjectType::Table, Database::"Sales Return", 'OnAfterDeleteEvent', '', false, false)]
local procedure Deleted(var Rec: Record "Sales Return"; RunTrigger: Boolean)
begin
if Rec.IsTemporary() then exit;
if Rec."AIRIQ Memo Created" then Error('Sales Return linked to Credit Memo %1 cannot be deleted.', Rec."AIRIQ Memo No.");
Release(Rec);
end;
[EventSubscriber(ObjectType::Table, Database::"Sales Return", 'OnAfterRenameEvent', '', false, false)]
local procedure Renamed(var Rec: Record "Sales Return"; var xRec: Record "Sales Return"; RunTrigger: Boolean)
begin if Rec.IsTemporary() then exit; if Rec."AIRIQ Memo Created" then Error('A Sales Return linked to a credit memo cannot be renamed.'); Release(xRec); Claim(Rec); end;
}
codeunit 50717 "AIRIQ SR Install" { Subtype = Install; trigger OnInstallAppPerCompany() var Integrity: Codeunit "AIRIQ SR Integrity"; begin Integrity.Audit(); end; }
codeunit 50718 "AIRIQ SR Upgrade" { Subtype = Upgrade; trigger OnUpgradePerCompany() var Integrity: Codeunit "AIRIQ SR Integrity"; begin Integrity.Audit(); end; }

permissionset 50715 "AIRIQ SALES RETURN"
{
    Assignable = true;
    Caption = 'AIRIQ Sales Return Credit Memo';
    Permissions = codeunit "AIRIQ SR Create Memo" = X,
                  codeunit "AIRIQ SR Integrity" = X,
                  codeunit "AIRIQ SR Posting" = X,
                  table "AIRIQ SR Return Registry" = X,
                  tabledata "AIRIQ SR Return Registry" = Rimd,
                  tabledata "Sales Return" = Rm;
}
