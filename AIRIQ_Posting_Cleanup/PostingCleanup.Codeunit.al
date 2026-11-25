namespace AIRIQ.GSTPostingCleanup;
using Microsoft.Finance.TaxEngine.Core;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.ScriptHandler;
using System.Environment;

codeunit 50748 "AIRIQ GST Posting Cleanup"
{
    Permissions = tabledata "Tax Posting Setup" = rd;

    [CommitBehavior(CommitBehavior::Error)]
    procedure Execute()
    var
        Env: Codeunit "Environment Information";
        Posting: Record "Tax Posting Setup";
        FilterHeader: Record "Lookup Table Filter";
        FilterChild: Record "Lookup Field Filter";
        SwitchChild: Record "Switch Case";
        InsertAction: Record "Tax Insert Record";
        Owner: Record "Tax Use Case";
        CaseIDs: List of [Guid];
        OldIDs: List of [Guid];
        KeepIDs: List of [Guid];
        OldFilters: List of [Guid];
        OldSwitches: List of [Guid];
        KeepFilters: List of [Guid];
        KeepSwitches: List of [Guid];
        Components: List of [Integer];
        CaseID: Guid;
        I: Integer;
        Expected: Integer;
        Counts: Dictionary of [Guid, Integer];
    begin
        if not Env.IsSandbox() then
            Error('Sandbox only.');
        if (UpperCase(Env.GetEnvironmentName()) <> 'SANDBOX1') or (CompanyName() <> 'TEST 2') then
            Error('This audit-specific cleanup is restricted to Sandbox1 / TEST 2. Current: %1 / %2.', Env.GetEnvironmentName(), CompanyName());
        if not Confirm('Delete the 24 audited obsolete GST posting lines in TEST 2? No backup is created. Continue?', false) then
            exit;
        LoadPairs(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components);
        Posting.SecurityFiltering(SecurityFilter::Disallowed);
        FilterHeader.SecurityFiltering(SecurityFilter::Disallowed);
        FilterChild.SecurityFiltering(SecurityFilter::Disallowed);
        SwitchChild.SecurityFiltering(SecurityFilter::Disallowed);
        InsertAction.SecurityFiltering(SecurityFilter::Disallowed);
        Owner.SecurityFiltering(SecurityFilter::Disallowed);
        Posting.LockTable();
        FilterHeader.LockTable();
        FilterChild.LockTable();
        SwitchChild.LockTable();
        InsertAction.LockTable();
        Owner.LockTable();
        // Validate ALL pairs before any deletion. Exact audit IDs only.
        for I := 1 to OldIDs.Count() do begin
            CaseID := CaseIDs.Get(I);
            if Counts.Get(CaseID, Expected) then
                Counts.Set(CaseID, Expected + 1)
            else
                Counts.Add(CaseID, 1);
            VerifyPair(CaseID, OldIDs.Get(I), KeepIDs.Get(I), OldFilters.Get(I), OldSwitches.Get(I), KeepFilters.Get(I), KeepSwitches.Get(I), Components.Get(I));
        end;
        foreach CaseID in Counts.Keys() do begin
            Posting.Reset();
            Posting.SetRange("Case ID", CaseID);
            if Posting.Count() <> 2 * Counts.Get(CaseID) then
                Error('Posting row count changed for case %1. Nothing deleted.', CaseID);
        end;
        Posting.Reset();
        for I := 1 to OldIDs.Count() do begin
            Posting.Get(CaseIDs.Get(I), OldIDs.Get(I));
            // Intentionally skip the table OnDelete trigger: its referenced filter is absent.
            // Do not clear pointers, delete child records or modify retained rows.
            Posting.Delete(false);
        end;
        foreach CaseID in Counts.Keys() do begin
            Posting.Reset();
            Posting.SetRange("Case ID", CaseID);
            if Posting.Count() <> Counts.Get(CaseID) then
                Error('Unexpected final row count for case %1. Transaction rolled back.', CaseID);
        end;
        Posting.Reset();
        for I := 1 to KeepIDs.Count() do begin
            if Posting.Get(CaseIDs.Get(I), OldIDs.Get(I)) then
                Error('Obsolete row still exists. Transaction rolled back.');
            Posting.Get(CaseIDs.Get(I), KeepIDs.Get(I));
            VerifyRoot(Posting, KeepFilters.Get(I), KeepSwitches.Get(I), Components.Get(I));
            VerifyLiveMapping(CaseIDs.Get(I), KeepFilters.Get(I), KeepSwitches.Get(I), Components.Get(I));
        end;
        Message('24 obsolete posting lines removed. 24 retained lines verified. Run the read-only audit again and Preview Posting before posting any invoice.');
    end;

    local procedure VerifyPair(CaseID: Guid; OldID: Guid; KeepID: Guid; OldFilter: Guid; OldSwitch: Guid; KeepFilter: Guid; KeepSwitch: Guid; Component: Integer)
    var
        Posting: Record "Tax Posting Setup";
        FilterHeader: Record "Lookup Table Filter";
        FilterChild: Record "Lookup Field Filter";
        SwitchChild: Record "Switch Case";
    begin
        Posting.SecurityFiltering(SecurityFilter::Disallowed);
        FilterHeader.SecurityFiltering(SecurityFilter::Disallowed);
        FilterChild.SecurityFiltering(SecurityFilter::Disallowed);
        SwitchChild.SecurityFiltering(SecurityFilter::Disallowed);
        Posting.Get(CaseID, OldID);
        VerifyRoot(Posting, OldFilter, OldSwitch, Component);
        FilterHeader.SetRange("Case ID", CaseID);
        FilterHeader.SetRange(ID, OldFilter);
        if not FilterHeader.IsEmpty() then
            Error('Old filter %1 exists now. Cleanup stopped.', OldFilter);
        FilterChild.SetRange("Case ID", CaseID);
        FilterChild.SetRange("Table Filter ID", OldFilter);
        if not FilterChild.IsEmpty() then
            Error('Old filter %1 has child records. Cleanup stopped.', OldFilter);
        SwitchChild.SetRange("Case ID", CaseID);
        SwitchChild.SetRange("Switch Statement ID", OldSwitch);
        if not SwitchChild.IsEmpty() then
            Error('Old switch %1 has visible child records. Cleanup stopped.', OldSwitch);
        Posting.Get(CaseID, KeepID);
        VerifyRoot(Posting, KeepFilter, KeepSwitch, Component);
        VerifyLiveMapping(CaseID, KeepFilter, KeepSwitch, Component);
    end;

    local procedure VerifyRoot(var Posting: Record "Tax Posting Setup"; ExpectedFilter: Guid; ExpectedSwitch: Guid; Component: Integer)
    var
        Ref: RecordRef;
        EmptyID: Guid;
    begin
        if (Posting."Table Filter ID" <> ExpectedFilter) or (Posting."Switch Statement ID" <> ExpectedSwitch) or IsNullGuid(ExpectedFilter) or IsNullGuid(ExpectedSwitch) then
            Error('Posting references changed for %1.', Posting.ID);
        if (Posting."Account Lookup ID" <> EmptyID) or (Posting."Reversal Account Lookup ID" <> EmptyID) then
            Error('Unexpected account lookup on %1.', Posting.ID);
        Ref.GetTable(Posting);
        // Compare the same invariant field values and XML format used by the audit.
        CheckField(Ref, 3, Format(Component, 0, 9));
        CheckField(Ref, 4, '18007');
        CheckField(Ref, 5, '4');
        CheckField(Ref, 6, '1');
        CheckField(Ref, 10, 'false');
        CheckField(Ref, 11, '0');
        CheckField(Ref, 12, '0');
        CheckField(Ref, 13, '0');
    end;

    local procedure VerifyLiveMapping(CaseID: Guid; FilterID: Guid; SwitchID: Guid; Component: Integer)
    var
        Header: Record "Lookup Table Filter";
        Child: Record "Lookup Field Filter";
        SwitchChild: Record "Switch Case";
        Owner: Record "Tax Use Case";
        InsertAction: Record "Tax Insert Record";
        Ref: RecordRef;
        EmptyID: Guid;
        Lookup: Record "Script Symbol Lookup";
        TablesSeen: List of [Integer];
        TargetTable: Integer;
    begin
        Header.SecurityFiltering(SecurityFilter::Disallowed);
        Child.SecurityFiltering(SecurityFilter::Disallowed);
        SwitchChild.SecurityFiltering(SecurityFilter::Disallowed);
        Owner.SecurityFiltering(SecurityFilter::Disallowed);
        InsertAction.SecurityFiltering(SecurityFilter::Disallowed);
        Header.Get(CaseID, EmptyID, FilterID);
        Ref.GetTable(Header);
        CheckField(Ref, 4, '18007');
        Child.SetRange("Case ID", CaseID);
        Child.SetRange("Table Filter ID", FilterID);
        if Child.Count() <> 1 then
            Error('Retained filter %1 does not have exactly one child.', FilterID);
        Child.FindFirst();
        if Child."Script ID" <> EmptyID then
            Error('Unexpected retained filter script.');
        Ref.GetTable(Child);
        CheckField(Ref, 4, '2');
        CheckField(Ref, 5, '18007');
        CheckField(Ref, 6, '0');
        if (Component = 3) and (FieldText(Ref, 7) = '1') then begin
            CheckField(Ref, 7, '1');
            CheckField(Ref, 8, '');
            Lookup.SecurityFiltering(SecurityFilter::Disallowed);
            Lookup.Get(CaseID, EmptyID, Child."Lookup ID");
            Ref.GetTable(Lookup);
            CheckField(Ref, 4, '20132');
            CheckField(Ref, 5, '37');
            CheckField(Ref, 6, '3');
        end else begin
            CheckField(Ref, 7, '0');
            CheckField(Ref, 8, Format(Component, 0, 9));
        end;
        Owner.Get(CaseID);
        SwitchChild.SetRange("Case ID", CaseID);
        SwitchChild.SetRange("Switch Statement ID", SwitchID);
        if SwitchChild.Count() <> 3 then
            Error('Retained switch %1 does not have three visible actions.', SwitchID);
        if SwitchChild.FindSet(false) then
            repeat
                if SwitchChild."Action Type" <> SwitchChild."Action Type"::"Insert Record" then
                    Error('Unexpected retained switch action.');
                InsertAction.Get(CaseID, Owner."Posting Script ID", SwitchChild."Action ID");
                Ref.GetTable(InsertAction);
                Evaluate(TargetTable, FieldText(Ref, 3));
                if not (TargetTable in [18001, 18005, 18016]) or TablesSeen.Contains(TargetTable) then
                    Error('Unexpected or duplicate ledger table %1.', TargetTable);
                TablesSeen.Add(TargetTable);
                CheckField(Ref, 4, 'true');
            until SwitchChild.Next() = 0;
        if TablesSeen.Count() <> 3 then
            Error('Retained ledger mapping incomplete.');
    end;

    local procedure CheckField(var Ref: RecordRef; Number: Integer; Expected: Text)
    begin
        if FieldText(Ref, Number) <> Expected then
            Error('Audit mismatch: table %1, field %2, record %3. Cleanup stopped.', Ref.Number, Number, Format(Ref.RecordId));
    end;

    local procedure FieldText(var Ref: RecordRef; Number: Integer): Text
    var
        F: FieldRef;
    begin
        F := Ref.Field(Number);
        exit(Format(F.Value, 0, 9));
    end;

    local procedure LoadPairs(var CaseIDs: List of [Guid]; var OldIDs: List of [Guid]; var KeepIDs: List of [Guid]; var OldFilters: List of [Guid]; var OldSwitches: List of [Guid]; var KeepFilters: List of [Guid]; var KeepSwitches: List of [Guid]; var Components: List of [Integer])
    begin
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000001}', '{314DF721-AAB8-472E-9758-1F6E341D84E4}', '{792A9E86-B669-4782-9877-FEB2E9A7AE7F}',
            '{E0ADC5BF-8DE1-4E8F-B754-7970D62470CF}', '{E8FC1C0F-9915-4724-94B2-5AA53FA4B6B5}', '{B238A04E-AD64-437A-9F54-0982D7256B86}', '{3887F5B3-7C04-4ABB-BDF4-640650B72CD1}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000001}', '{B0900DCA-5F5D-4F9B-A164-915DE527C18D}', '{2F8427E7-E7E5-4E65-9B91-C14376A09B8E}',
            '{D23754CC-F16C-453B-8DAA-2647BAEBCEEE}', '{EBCD701C-2C32-4BC3-B204-179EDCC81E4E}', '{29D9D87A-94C5-4C45-8001-B42AC93D1EBE}', '{110C9B73-8918-4363-B2FB-6B0BCEE3712C}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000101}', '{741D927F-E984-4D4B-8E3C-43CBB4806755}', '{06A99FFD-7BF1-401C-9D93-DC375DDD4DCA}',
            '{6DA6EC3F-767D-4BD1-B671-DEF3510B42FF}', '{9E2E8CE2-A48B-414D-9855-E39D186241FA}', '{AFF5CFE2-17F3-4D63-9E71-BE75610CE598}', '{C9505B51-E17B-4B5D-97BA-1338A2839399}', 3);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000102}', '{268A12E6-40D5-4F5A-B7B2-C7E2E9B69C04}', '{C996272B-184F-4577-9D07-4D60BDCCB7A4}',
            '{F3C67942-5476-4FC5-9600-D217D12F8B51}', '{A6C785B5-AE95-4027-8B80-FD8E411B3003}', '{ED062F44-9D1C-486C-AF68-502B8DFC0977}', '{92EC4263-B88A-4C8E-9CAE-20DC2163E1EE}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000102}', '{574A92E3-9168-413C-A5A1-FB990EBAF31F}', '{1A49FF3E-1DE0-4BFC-8DEB-DA4661719CF0}',
            '{4951FD14-F445-4DE4-8438-3759C6B40B75}', '{DC6ADCC7-6F0B-45F3-B588-F0E385862614}', '{A171182E-9881-435B-A379-4F260E92D566}', '{E88C2973-F71A-4A44-AE71-F30C6864E03A}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000103}', '{44DC816C-E71B-4FE1-904E-B0E5AF9BB80A}', '{F182BE09-1889-4E66-BC3B-73C2D80A24EF}',
            '{3EF3CBA2-3DC0-427B-B103-A3D79D5963E8}', '{34F1B7C1-31D4-4733-94AF-B8D2A4F9493C}', '{B2184118-7584-4A8C-AFB1-BE7FD11D57D6}', '{A19A7133-10A2-4AAE-8DE9-96FE671F4133}', 3);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000104}', '{971A278B-39F6-4EEF-A2B0-14746D6521AB}', '{6CE93253-A117-4DE3-A933-1B96BBF7090B}',
            '{72C86AF2-6CA3-450E-A0D1-D105804D5489}', '{DCC0C403-3A81-4073-B6C4-8B26DD9DE707}', '{6B214A9A-6835-41F6-9766-C8F4CE538D16}', '{A22D6AB0-FB94-4484-B7A9-B53D3A06F60A}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000104}', '{4D9D4B1D-D405-4D2E-9C32-23F1AC0C8FA7}', '{1AB18E6D-EAA4-456E-9D4B-ADE2D47B1A50}',
            '{3538C9F9-3A2E-4527-B30A-A1AD773B4548}', '{9568D75A-1EFF-49EE-8277-52268AA11121}', '{79D3BD75-50FB-4093-A25F-FD5F347423DC}', '{EAD1363E-2B3F-49BA-B918-D966B606522B}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000104}', '{871099BB-E7A1-4659-B094-37EA1CABC4AB}', '{3D0648C0-D655-4735-9984-A55ED7E8F2E5}',
            '{16C67AF5-1794-42B9-BC24-2604492F940A}', '{3098B7C9-74B8-4D3C-BF0A-E6E7E90912A6}', '{921D495F-203A-4989-AE25-8C82EC093ADE}', '{4FAA2E6A-BC88-4C9B-BE28-5C4CBA81BB92}', 17);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000105}', '{205D9783-E06D-42F9-B9FE-50E8E8F7B944}', '{3E54774D-67DC-47CB-9205-9042EC9A8147}',
            '{F6F31514-2577-44FF-844A-2397F7EF0800}', '{892F94F9-A76D-42A7-86DA-9BCF6E6045FF}', '{71B02247-956B-40E5-BBE8-98AE23B2777D}', '{E63C1C17-D416-47D9-83C7-EE5D6A46FFFE}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000105}', '{F3C12154-92A9-4AAC-B704-67E1E40E2123}', '{64946909-D410-4802-BFC3-06166D588A66}',
            '{444AF547-44A7-4E93-82A2-BC6A68C27C74}', '{9A84DDEA-B85B-45E7-B466-E3D987934199}', '{D22BCCC1-3F29-404B-89BE-CEC79EF3040F}', '{3F3BAEF3-26AB-4656-8260-6EA6E1CFDFEF}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10001-7B10-4A10-9010-000000000105}', '{2710DA1F-210C-48FC-B692-B8B35A2B49EB}', '{6B3903E2-6723-4072-A821-36D8008556AA}',
            '{D2F1B74C-1C50-478C-83CF-167287768581}', '{9E75C18E-2997-490F-AAC1-3665B343BDF3}', '{0F83E6FF-F611-410A-8DD3-9AEB5690B007}', '{7453A6CC-8AEF-44A8-A13A-472009996182}', 17);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000002}', '{0A94B659-8C42-4271-883B-089A08664E07}', '{37CB8831-BBC5-407B-B4FE-3BA9B469DE02}',
            '{D8013019-DCD8-4136-8E2F-E1FBB72B4C52}', '{9BEEC27F-0DC0-4AF3-B1C2-1EEF61229722}', '{9578C011-3BEF-4A8F-BF61-DE37419D30AC}', '{3669AF8E-EF17-4D43-B45F-33A70E535A57}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000002}', '{C8D564B5-07C1-4475-8B17-38DCE01C005B}', '{F6F97B83-02D4-47AD-A915-1FAE0A35EB74}',
            '{679B1BAE-8728-43BF-A5C4-3B244836EBC1}', '{E3C3ECEB-5540-4AB9-A699-498EF9B2FEB2}', '{81F6C4B5-AF1F-43E9-9C93-95A67B82E958}', '{1F123BAF-1056-4449-9D14-EF2DC4807EF4}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000101}', '{033E5271-59C1-423D-9047-BA62748E138C}', '{7CCA2B0B-7C0C-42CF-B781-1B9210CD87E2}',
            '{C5B784B0-E8D2-4379-9604-52B67B637BFF}', '{AD8780DD-431D-4B29-908E-B86BBE66CFED}', '{37EEC27A-C457-4F12-BF83-5B196CC3279C}', '{10E47A94-C638-4B7F-A078-03BBC16CA53A}', 3);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000102}', '{4385B569-9017-458A-96D0-AB93D7445DE9}', '{5B3E44D2-C874-43AD-BC9A-78AA4B889F18}',
            '{793D29CB-E65B-43EC-A2BB-50BD5B44FDCD}', '{72E53541-46FA-40C7-BB23-DCC6314E1577}', '{1059C3AF-9DCD-4EBB-A2DD-7F8979CC31BA}', '{BC9D5975-69A9-4E12-B69C-99316D2046D4}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000102}', '{1504BE56-C8D9-4F48-86D2-D0355D7B402F}', '{D2AA3482-9061-42BE-B48A-99F30FF29C35}',
            '{8F1D68CE-F94B-40B6-BBDD-0AB1973D1725}', '{83F57B40-AB56-41C6-BDB3-8A95926872C1}', '{EBA3E835-0467-4A98-A44A-B88E834F58C2}', '{F12BD5FC-0CED-4E63-A895-5344F736CCEF}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000103}', '{8B6E0717-A252-41EA-855E-0CD8F49E70F9}', '{F51B57B9-95F7-411D-88CE-09459145F211}',
            '{0FAEF1A4-8122-4CA2-AFAB-69DCDB96D934}', '{06891E14-B22B-4F03-BEBE-8E392DC9D488}', '{58CBDE97-F163-4E0B-B308-6688F9733FA7}', '{921E1C46-EBFD-4FE9-86FB-D6A08784BAA7}', 3);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000104}', '{CB08E6F1-8F79-4D4E-8DEE-0798E038A25C}', '{4EDC4579-1DEC-4399-BFD9-A41275432B60}',
            '{185EDAF8-52EB-44DE-90D6-9574CDB7198D}', '{A4D24A07-C3BC-470D-88F8-004F4E149373}', '{F2893C8A-4178-4F78-B0CC-B2304C0B92FD}', '{0D58149F-389B-4FD9-A3C1-53EAFAD214DD}', 6);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000104}', '{D3FB259D-EFD7-4D86-8623-73A881F2A535}', '{829070A6-E3F4-4092-B1C6-B514421D40E1}',
            '{47E29A7D-39E8-48AC-8151-C8127D0C9CB1}', '{F0EA6608-F3CA-481D-9A88-2269400BE49C}', '{D01595B7-B445-4601-B4C2-A04C9B8986B7}', '{44FE4C44-4F34-4B6E-B4F9-CBBA466E29F4}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000104}', '{F8C7CAF6-A7E8-4632-9FE9-88545F23A1BF}', '{629E2059-B068-4F78-BD26-B3D488A742E6}',
            '{35D27493-83D5-46DE-92D4-F4F46773E6C5}', '{F42FDAB8-2F3D-4B7B-B2C1-9F6837EFD7DB}', '{1FEC566B-661F-47FC-9DB6-9A127AFE6D9E}', '{5EA6D1DB-91F4-4F1B-B5AD-B0DD3842883B}', 17);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000105}', '{D7D030CB-D776-40ED-8204-686FAC05769E}', '{57BA3FA9-B26E-4C8F-9244-F13170A800CB}',
            '{5E892850-DB69-4F01-BDF8-F7C0D77EAAE5}', '{993F0841-20B6-45A0-A465-DEC2F60E03BA}', '{E432F021-9EE8-4C21-A001-320E82C44968}', '{A24CBC68-E04C-4A57-B9A0-FFE7173A42D4}', 17);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000105}', '{96868C23-1BDC-417D-9B31-B3CDEE0993FB}', '{F24FD8F9-0227-4DC4-8A80-582F22CBAB1D}',
            '{727030F5-0FE9-4EA4-9C2D-795035420849}', '{B7CF44A8-F362-44F8-B302-90FA3D7914C9}', '{0ADDDB30-A675-463D-A4D4-9FCBA7314671}', '{39B6903C-A35D-4452-ACA2-F13AC06272AE}', 2);
        AddPair(CaseIDs, OldIDs, KeepIDs, OldFilters, OldSwitches, KeepFilters, KeepSwitches, Components,
            '{A1D10002-7B10-4A10-9010-000000000105}', '{01777608-CD89-4B79-B849-FCBD0EDDED11}', '{017B9C5E-C298-47CD-AAF4-C12FB74B2B40}',
            '{97F7C9D2-1A89-4D58-A908-7F1B951B29E2}', '{9696CAD7-2E73-420F-A5AA-46488047BF5B}', '{397E455F-069D-4B7E-9D42-BDD22ACB2ABA}', '{1F7D6920-830B-4F3F-9860-5866915F4013}', 6);
    end;

    local procedure AddPair(var CaseIDs: List of [Guid]; var OldIDs: List of [Guid]; var KeepIDs: List of [Guid]; var OldFilters: List of [Guid]; var OldSwitches: List of [Guid]; var KeepFilters: List of [Guid]; var KeepSwitches: List of [Guid]; var Components: List of [Integer]; C: Text; O: Text; K: Text; OFilt: Text; OSwitch: Text; KFilt: Text; KSwitch: Text; Component: Integer)
    var
        G: Guid;
    begin
        Evaluate(G, C); CaseIDs.Add(G);
        Evaluate(G, O); OldIDs.Add(G);
        Evaluate(G, K); KeepIDs.Add(G);
        Evaluate(G, OFilt); OldFilters.Add(G);
        Evaluate(G, OSwitch); OldSwitches.Add(G);
        Evaluate(G, KFilt); KeepFilters.Add(G);
        Evaluate(G, KSwitch); KeepSwitches.Add(G);
        Components.Add(Component);
    end;
}
