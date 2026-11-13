codeunit 50730 "AIRIQ FS GL Calculation"
{
    // PHASE 1: G/L-based candidates only. Not audited/restated statement amounts.
    procedure BuildPreview(var Preview: Record "AIRIQ FS Preview Buffer" temporary; StatementCode: Code[10]; AsOfDate: Date)
    var
        Mapping: Record "AIRIQ FS Mapping";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
        RowNo: Integer;
        Amount: Decimal;
    begin
        if AsOfDate = 0D then
            Error('As-at date must be specified.');

        Preview.Reset();
        Preview.DeleteAll();
        Mapping.SetRange("Statement Code", StatementCode);
        Mapping.SetRange(Active, true);
        Mapping.SetFilter("G/L Account No.", '<>%1', '');
        if Mapping.FindSet() then
            repeat
                GLAccount.Get(Mapping."G/L Account No.");
                GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
                GLEntry.Reset();
                GLEntry.SetRange("G/L Account No.", Mapping."G/L Account No.");
                GLEntry.SetFilter("Posting Date", '..%1', AsOfDate);
                GLEntry.CalcSums(Amount);
                Amount := GLEntry.Amount;
                if Mapping."Reverse Sign" then
                    Amount := -Amount;

                RowNo += 1;
                Preview.Init();
                Preview."Entry No." := RowNo;
                Preview."Statement Code" := Mapping."Statement Code";
                Preview."Note No." := Mapping."Note No.";
                Preview."Financial Heading" := Mapping."Financial Heading";
                Preview."G/L Account No." := Mapping."G/L Account No.";
                Preview."G/L Account Name" := CopyStr(GLAccount.Name, 1, MaxStrLen(Preview."G/L Account Name"));
                Preview.Amount := Amount;
                Preview."Finance Approved" := Mapping."Approved Mapping";
                Preview.Insert();
            until Mapping.Next() = 0;
    end;
}
