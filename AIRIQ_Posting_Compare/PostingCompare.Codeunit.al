namespace AIRIQ.GSTPostingCompare;
using Microsoft.Finance.TaxEngine.Core;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.ScriptHandler;
using System.Environment;
using System.Utilities;

codeunit 50747 "AIRIQ Posting Compare Audit"
{
    trigger OnRun()
    begin
        ExportAudit();
    end;

    procedure ExportAudit()
    var
        Env: Codeunit "Environment Information";
        Blob: Codeunit "Temp Blob";
        Output: OutStream;
        Input: InStream;
        CaseID: Guid;
        TextOutput: Text;
        FileName: Text;
        Document: JsonObject;
    begin
        if not Env.IsSandbox() then
            Error('Sandbox required.');
        Clear(Rows);
        Clear(Visited);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000001');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000101');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000102');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000103');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000104');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10001-7B10-4A10-9010-000000000105');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000002');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000101');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000102');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000103');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000104');
        AuditCase(CaseID);
        Evaluate(CaseID, 'A1D10002-7B10-4A10-9010-000000000105');
        AuditCase(CaseID);
        Document.Add('Environment', Env.GetEnvironmentName());
        Document.Add('Company', CompanyName());
        Document.Add('At', Format(CurrentDateTime, 0, 9));
        Document.Add('ReadOnly', true);
        Document.Add('Rows', Rows);
        Document.WriteTo(TextOutput);
        Blob.CreateOutStream(Output, TextEncoding::UTF8);
        Output.WriteText(TextOutput);
        Blob.CreateInStream(Input, TextEncoding::UTF8);
        FileName := 'AIRIQ-' + Env.GetEnvironmentName() + '-' + CompanyName() + '-posting-audit.json';
        DownloadFromStream(Input, '', '', '', FileName);
    end;

    local procedure AuditCase(CaseID: Guid)
    var
        EmptyID: Guid;
    begin
        ClearLastError();
        if not TryCase(CaseID) then
            Notice(CaseID, EmptyID, 'CASE_SCAN_INCOMPLETE', GetLastErrorText());
        ClearLastError();
        if not TryCaseLookups(CaseID) then
            Notice(CaseID, EmptyID, 'CASE_LOOKUP_SCAN_INCOMPLETE', GetLastErrorText());
    end;

    [TryFunction]
    local procedure TryCaseLookups(CaseID: Guid)
    var
        Lookup: Record "Script Symbol Lookup";
        EmptyID: Guid;
    begin
        Lookup.SecurityFiltering(SecurityFilter::Disallowed);
        Lookup.SetRange("Case ID", CaseID);
        if not Lookup.ReadPermission() then begin
            Notice(CaseID, EmptyID, 'UNRESOLVED_NO_READ_PERMISSION', 'Case-wide Script Symbol Lookup cleanup inventory unavailable.');
            exit;
        end;
        if Lookup.FindSet(false) then
            repeat
                Walk(CaseID, EmptyID, Format(Lookup.RecordId), 'Case-wide lookup cleanup inventory (not a posting owner)', 20144, Lookup."Script ID", Lookup.ID);
            until Lookup.Next() = 0;
    end;

    [TryFunction]
    local procedure TryCase(CaseID: Guid)
    var
        Posting: Record "Tax Posting Setup";
        Owner: Record "Tax Use Case";
        Ref: RecordRef;
        EmptyID: Guid;
        CountSeen: Integer;
    begin
        Posting.SecurityFiltering(SecurityFilter::Disallowed);
        Owner.SecurityFiltering(SecurityFilter::Disallowed);
        Posting.SetRange("Case ID", CaseID);
        if not Posting.ReadPermission() then begin
            Notice(CaseID, EmptyID, 'UNRESOLVED_NO_READ_PERMISSION', 'Tax Posting Setup cannot be enumerated.');
            exit;
        end;
        if Posting.FindSet(false) then
            repeat
                CountSeen += 1;
                Ref.GetTable(Posting);
                Snapshot(Posting."Case ID", Posting.ID, Ref);
                // Each direct dependency is tested independently. No failed Get ends this loop.
                Walk(CaseID, Posting.ID, Format(Posting.RecordId), 'Switch Statement ID (7)', 20284, EmptyID, Posting."Switch Statement ID");
                Walk(CaseID, Posting.ID, Format(Posting.RecordId), 'Table Filter ID (9)', 20142, EmptyID, Posting."Table Filter ID");
                Walk(CaseID, Posting.ID, Format(Posting.RecordId), 'Account Lookup ID (14)', 20144, EmptyID, Posting."Account Lookup ID");
                Walk(CaseID, Posting.ID, Format(Posting.RecordId), 'Reversal Account Lookup ID (15)', 20144, EmptyID, Posting."Reversal Account Lookup ID");
            until Posting.Next() = 0;
        Notice(CaseID, EmptyID, 'POSTING_ROW_COUNT', Format(CountSeen));
        if not Owner.ReadPermission() then
            Notice(CaseID, EmptyID, 'UNRESOLVED_NO_READ_PERMISSION', 'Tax Use Case metadata unavailable.')
        else
            if Owner.Get(CaseID) then begin
                Ref.GetTable(Owner);
                Snapshot(CaseID, EmptyID, Ref);
                Walk(CaseID, EmptyID, Format(Owner.RecordId), 'Posting Table Filter ID (20336)', 20142, EmptyID, Owner."Posting Table Filter ID");
            end else
                Notice(CaseID, EmptyID, 'MISSING_EXPECTED_KEY', 'Tax Use Case parent is missing.');
    end;

    local procedure Notice(CaseID: Guid; PostingID: Guid; Status: Text; Detail: Text)
    var
        Item: JsonObject;
    begin
        Item.Add('CaseID', Format(CaseID));
        Item.Add('PostingSetupID', Format(PostingID));
        Item.Add('Status', Status);
        Item.Add('Detail', Detail);
        Rows.Add(Item);
    end;

    local procedure Snapshot(CaseID: Guid; PostingID: Guid; Ref: RecordRef)
    var
        Item: JsonObject;
        Fields: JsonObject;
        Fld: FieldRef;
        Index: Integer;
    begin
        for Index := 1 to Ref.FieldCount do begin
            Fld := Ref.FieldIndex(Index);
            if Fld.Number < 2000000000 then
                Fields.Add(StrSubstNo('%1: %2', Fld.Number, Fld.Name), Format(Fld.Value, 0, 9));
        end;
        Item.Add('CaseID', Format(CaseID));
        Item.Add('PostingSetupID', Format(PostingID));
        Item.Add('Status', 'PUBLIC_RECORD_SNAPSHOT');
        Item.Add('SourceTable', Ref.Number);
        Item.Add('SourceKey', Format(Ref.RecordId));
        Item.Add('Fields', Fields);
        Rows.Add(Item);
    end;

    local procedure Walk(CaseID: Guid; PostingID: Guid; SourceKey: Text; FieldName: Text; Kind: Integer; ScriptID: Guid; ID: Guid)
    var
        Found: Boolean;
        Status: Text;
        Ref: RecordRef;
        Item: JsonObject;
        ExpectedKey: JsonObject;
        Alternatives: JsonArray;
        VisitKey: Text;
        ExpandNode: Boolean;
        Detail: Text;
    begin
        if IsNullGuid(ID) then
            Status := 'NULL_NO_DEPENDENCY'
        else
            if Kind = 20284 then
                Status := 'UNRESOLVED_INTERNAL_HEADER'
            else begin
                ClearLastError();
                if not TryGetPublic(CaseID, Kind, ScriptID, ID, Found, Status, Ref, Alternatives) then begin
                    Status := 'UNRESOLVED_READ_ERROR';
                    Detail := GetLastErrorText();
                end;
            end;
        ExpectedKey.Add('CaseID', Format(CaseID));
        if Kind in [20142, 20143, 20144, 20334, 20190] then
            ExpectedKey.Add('ScriptID', Format(ScriptID));
        ExpectedKey.Add('ID', Format(ID));
        Item.Add('CaseID', Format(CaseID));
        Item.Add('PostingSetupID', Format(PostingID));
        Item.Add('SourceKey', SourceKey);
        Item.Add('FieldName', FieldName);
        Item.Add('TargetTable', Kind);
        Item.Add('ExpectedKey', ExpectedKey);
        Item.Add('ReferencedGUID', Format(ID));
        Item.Add('Status', Status);
        Item.Add('ReadError', Detail);
        Item.Add('SameCaseOtherScriptCandidates', Alternatives);
        Rows.Add(Item);
        // A repeated edge is always logged. Only expansion is deduplicated per posting root.
        VisitKey := StrSubstNo('%1|%2|%3|%4|%5', CaseID, PostingID, Kind, ScriptID, ID);
        ExpandNode := (Found or (Kind = 20284) or
            ((Kind in [20142, 20143, 20334, 20190]) and
            (Status in ['MISSING_EXPECTED_KEY', 'MISSING_EXPECTED_KEY_ALTERNATE_SCRIPT_FOUND']))) and not IsNullGuid(ID);
        if ExpandNode and not Visited.ContainsKey(VisitKey) then begin
            Visited.Add(VisitKey, true);
            ClearLastError();
            if not TryExpand(CaseID, PostingID, Kind, ScriptID, ID, Ref) then
                Notice(CaseID, PostingID, 'DEPENDENCY_BRANCH_INCOMPLETE', StrSubstNo('%1 / %2 / %3: %4', Kind, ScriptID, ID, GetLastErrorText()));
        end;
    end;

    [TryFunction]
    local procedure TryGetPublic(CaseID: Guid; Kind: Integer; ScriptID: Guid; ID: Guid; var Found: Boolean; var Status: Text; var Ref: RecordRef; var Alternatives: JsonArray)
    var
        T20142: Record "Lookup Table Filter";
        T20143: Record "Lookup Table Sorting";
        T20144: Record "Script Symbol Lookup";
        T20334: Record "Tax Insert Record";
        T20190: Record "Tax Test Condition";
        T20287: Record "Tax Table Relation";
        Alternative: JsonObject;
    begin
        case Kind of
            20142:
                begin
                    T20142.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20142.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20142.Get(CaseID, ScriptID, ID);
                    if Found then
                        Ref.GetTable(T20142);
                    if not Found then begin
                        T20142.SetRange("Case ID", CaseID);
                        T20142.SetRange(ID, ID);
                        T20142.SetFilter("Script ID", '<>%1', ScriptID);
                        if T20142.FindSet(false) then
                            repeat
                                Alternative.Add('ScriptID', Format(T20142."Script ID"));
                                Alternative.Add('RecordID', Format(T20142.RecordId));
                                Alternatives.Add(Alternative);
                                Clear(Alternative);
                            until T20142.Next() = 0;
                    end;
                end;
            20143:
                begin
                    T20143.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20143.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20143.Get(CaseID, ScriptID, ID);
                    if Found then
                        Ref.GetTable(T20143);
                    if not Found then begin
                        T20143.SetRange("Case ID", CaseID);
                        T20143.SetRange(ID, ID);
                        T20143.SetFilter("Script ID", '<>%1', ScriptID);
                        if T20143.FindSet(false) then
                            repeat
                                Alternative.Add('ScriptID', Format(T20143."Script ID"));
                                Alternative.Add('RecordID', Format(T20143.RecordId));
                                Alternatives.Add(Alternative);
                                Clear(Alternative);
                            until T20143.Next() = 0;
                    end;
                end;
            20144:
                begin
                    T20144.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20144.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20144.Get(CaseID, ScriptID, ID);
                    if Found then
                        Ref.GetTable(T20144);
                    if not Found then begin
                        T20144.SetRange("Case ID", CaseID);
                        T20144.SetRange(ID, ID);
                        T20144.SetFilter("Script ID", '<>%1', ScriptID);
                        if T20144.FindSet(false) then
                            repeat
                                Alternative.Add('ScriptID', Format(T20144."Script ID"));
                                Alternative.Add('RecordID', Format(T20144.RecordId));
                                Alternatives.Add(Alternative);
                                Clear(Alternative);
                            until T20144.Next() = 0;
                    end;
                end;
            20334:
                begin
                    T20334.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20334.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20334.Get(CaseID, ScriptID, ID);
                    if Found then
                        Ref.GetTable(T20334);
                    if not Found then begin
                        T20334.SetRange("Case ID", CaseID);
                        T20334.SetRange(ID, ID);
                        T20334.SetFilter("Script ID", '<>%1', ScriptID);
                        if T20334.FindSet(false) then
                            repeat
                                Alternative.Add('ScriptID', Format(T20334."Script ID"));
                                Alternative.Add('RecordID', Format(T20334.RecordId));
                                Alternatives.Add(Alternative);
                                Clear(Alternative);
                            until T20334.Next() = 0;
                    end;
                end;
            20190:
                begin
                    T20190.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20190.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20190.Get(CaseID, ScriptID, ID);
                    if Found then
                        Ref.GetTable(T20190);
                    if not Found then begin
                        T20190.SetRange("Case ID", CaseID);
                        T20190.SetRange(ID, ID);
                        T20190.SetFilter("Script ID", '<>%1', ScriptID);
                        if T20190.FindSet(false) then
                            repeat
                                Alternative.Add('ScriptID', Format(T20190."Script ID"));
                                Alternative.Add('RecordID', Format(T20190.RecordId));
                                Alternatives.Add(Alternative);
                                Clear(Alternative);
                            until T20190.Next() = 0;
                    end;
                end;
            20287:
                begin
                    T20287.SecurityFiltering(SecurityFilter::Disallowed);
                    if not T20287.ReadPermission() then begin
                        Status := 'UNRESOLVED_NO_READ_PERMISSION';
                        exit;
                    end;
                    Found := T20287.Get(CaseID, ID);
                    if Found then
                        Ref.GetTable(T20287);
                end;
            else
                Error('No public read probe implemented for target %1.', Kind);
        end;
        if Found then
            Status := 'FOUND_EXACT_KEY'
        else
            if Alternatives.Count() > 0 then
                Status := 'MISSING_EXPECTED_KEY_ALTERNATE_SCRIPT_FOUND'
            else
                Status := 'MISSING_EXPECTED_KEY';
    end;

    [TryFunction]
    local procedure TryExpand(CaseID: Guid; PostingID: Guid; Kind: Integer; ScriptID: Guid; ID: Guid; Ref: RecordRef)
    var
        Lookup: Record "Script Symbol Lookup";
        Filter: Record "Lookup Field Filter";
        SortField: Record "Lookup Field Sorting";
        InsertField: Record "Tax Insert Record Field";
        ConditionItem: Record "Tax Test Condition Item";
        Child: Record "Switch Case";
        Owner: Record "Tax Use Case";
        Relation: Record "Tax Table Relation";
        EmptyID: Guid;
        DetailRef: RecordRef;
        ChildrenSeen: Integer;
    begin
        case Kind of
            20144:
                begin
                    Ref.SetTable(Lookup);
                    Snapshot(CaseID, PostingID, Ref);
                    Walk(CaseID, PostingID, Format(Lookup.RecordId), 'Table Sorting ID (9)', 20143, ScriptID, Lookup."Table Sorting ID");
                    Walk(CaseID, PostingID, Format(Lookup.RecordId), 'Table Filter ID (7)', 20142, ScriptID, Lookup."Table Filter ID");
                end;
            20142:
                begin
                    if Ref.Number <> 0 then
                        Snapshot(CaseID, PostingID, Ref);
                    Filter.SecurityFiltering(SecurityFilter::Disallowed);
                    // Match actual header OnDelete: Case + Filter ID, deliberately no Script range.
                    Filter.SetRange("Case ID", CaseID);
                    Filter.SetRange("Table Filter ID", ID);
                    if not Filter.ReadPermission() then
                        Error('No read permission for Lookup Field Filter.');
                    if Filter.FindSet(false) then
                        repeat
                            ChildrenSeen += 1;
                            DetailRef.GetTable(Filter);
                            Snapshot(CaseID, PostingID, DetailRef);
                            if Filter."Value Type" = Filter."Value Type"::Lookup then
                                Walk(CaseID, PostingID, Format(Filter.RecordId), 'Lookup ID (9)', 20144, Filter."Script ID", Filter."Lookup ID");
                        until Filter.Next() = 0;
                    Notice(CaseID, PostingID, 'FILTER_CHILD_ENUMERATION_COMPLETE', StrSubstNo('%1 / all child Script IDs: %2', ID, ChildrenSeen));
                end;
            20334:
                begin
                    if Ref.Number <> 0 then
                        Snapshot(CaseID, PostingID, Ref);
                    InsertField.SecurityFiltering(SecurityFilter::Disallowed);
                    InsertField.SetRange("Case ID", CaseID);
                    InsertField.SetRange("Script ID", ScriptID);
                    InsertField.SetRange("Insert Record ID", ID);
                    if not InsertField.ReadPermission() then
                        Error('No read permission for Tax Insert Record Field.');
                    if InsertField.FindSet(false) then
                        repeat
                            ChildrenSeen += 1;
                            DetailRef.GetTable(InsertField);
                            Snapshot(CaseID, PostingID, DetailRef);
                            if InsertField."Value Type" = InsertField."Value Type"::Lookup then
                                Walk(CaseID, PostingID, Format(InsertField.RecordId), 'Lookup ID (6)', 20144, InsertField."Script ID", InsertField."Lookup ID");
                        until InsertField.Next() = 0;
                    Notice(CaseID, PostingID, 'INSERT_FIELD_ENUMERATION_COMPLETE', StrSubstNo('%1 / %2: %3', ScriptID, ID, ChildrenSeen));
                end;
            20190:
                begin
                    if Ref.Number <> 0 then
                        Snapshot(CaseID, PostingID, Ref);
                    ConditionItem.SecurityFiltering(SecurityFilter::Disallowed);
                    ConditionItem.SetRange("Case ID", CaseID);
                    // Match actual Condition.OnDelete: Case + Condition ID, no Script range.
                    ConditionItem.SetRange("Condition ID", ID);
                    if not ConditionItem.ReadPermission() then
                        Error('No read permission for Tax Test Condition Item.');
                    if ConditionItem.FindSet(false) then
                        repeat
                            ChildrenSeen += 1;
                            DetailRef.GetTable(ConditionItem);
                            Snapshot(CaseID, PostingID, DetailRef);
                            Walk(CaseID, PostingID, Format(ConditionItem.RecordId), 'LHS Lookup ID (6)', 20144, ConditionItem."Script ID", ConditionItem."LHS Lookup ID");
                            if ConditionItem."RHS Type" = ConditionItem."RHS Type"::Lookup then
                                Walk(CaseID, PostingID, Format(ConditionItem.RecordId), 'RHS Lookup ID (11)', 20144, ConditionItem."Script ID", ConditionItem."RHS Lookup ID");
                        until ConditionItem.Next() = 0;
                    Notice(CaseID, PostingID, 'CONDITION_ITEM_ENUMERATION_COMPLETE', StrSubstNo('%1 / all child Script IDs: %2', ID, ChildrenSeen));
                end;
            20287:
                begin
                    Ref.SetTable(Relation);
                    Snapshot(CaseID, PostingID, Ref);
                    Walk(CaseID, PostingID, Format(Relation.RecordId), 'Table Filter ID (7)', 20142, EmptyID, Relation."Table Filter ID");
                end;
            20284:
                begin
                    Child.SecurityFiltering(SecurityFilter::Disallowed);
                    Owner.SecurityFiltering(SecurityFilter::Disallowed);
                    Child.SetRange("Case ID", CaseID);
                    Child.SetRange("Switch Statement ID", ID);
                    if not Child.ReadPermission() then
                        Error('No read permission for Switch Case.');
                    if Child.FindSet(false) then
                        repeat
                            ChildrenSeen += 1;
                            DetailRef.GetTable(Child);
                            Snapshot(CaseID, PostingID, DetailRef);
                            Walk(CaseID, PostingID, Format(Child.RecordId), 'Condition ID (4)', 20190, EmptyID, Child."Condition ID");
                            case Child."Action Type" of
                                Child."Action Type"::Lookup:
                                    Walk(CaseID, PostingID, Format(Child.RecordId), 'Action ID (6): Lookup', 20144, EmptyID, Child."Action ID");
                                Child."Action Type"::Relation:
                                    Walk(CaseID, PostingID, Format(Child.RecordId), 'Action ID (6): Relation', 20287, EmptyID, Child."Action ID");
                                Child."Action Type"::"Insert Record":
                                    begin
                                        if not Owner.ReadPermission() then
                                            Error('No read permission for Tax Use Case posting script metadata.');
                                        if Owner.Get(CaseID) then
                                            Walk(CaseID, PostingID, Format(Child.RecordId), 'Action ID (6): Insert Record', 20334, Owner."Posting Script ID", Child."Action ID")
                                        else
                                            Notice(CaseID, PostingID, 'UNRESOLVED_ACTION_KEY', 'Tax Use Case missing; cannot establish Posting Script ID.');
                                    end;
                                else
                                    Notice(CaseID, PostingID, 'UNRESOLVED_ACTION_TYPE', Format(Child.RecordId));
                            end;
                        until Child.Next() = 0;
                    Notice(CaseID, PostingID, 'VISIBLE_SWITCH_CHILD_COUNT_NOT_HEADER_PROOF', StrSubstNo('%1: %2', ID, ChildrenSeen));
                end;
            20143:
                begin
                    if Ref.Number <> 0 then
                        Snapshot(CaseID, PostingID, Ref);
                    SortField.SecurityFiltering(SecurityFilter::Disallowed);
                    SortField.SetRange("Case ID", CaseID);
                    SortField.SetRange("Script ID", ScriptID);
                    SortField.SetRange("Table Sorting ID", ID);
                    if not SortField.ReadPermission() then
                        Error('No read permission for Lookup Field Sorting.');
                    if SortField.FindSet(false) then
                        repeat
                            ChildrenSeen += 1;
                            DetailRef.GetTable(SortField);
                            Snapshot(CaseID, PostingID, DetailRef);
                        until SortField.Next() = 0;
                    Notice(CaseID, PostingID, 'SORT_FIELD_ENUMERATION_COMPLETE', StrSubstNo('%1 / %2: %3', ScriptID, ID, ChildrenSeen));
                end;
        end;
    end;

    var
        Rows: JsonArray;
        Visited: Dictionary of [Text, Boolean];
}
