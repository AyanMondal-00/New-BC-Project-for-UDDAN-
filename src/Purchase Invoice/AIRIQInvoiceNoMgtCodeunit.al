codeunit 50338 "AIRIQ Invoice No. Mgt"
{
    procedure GetNextInvoiceNo(): Code[35]
    var
        Counter: Record "AIRIQ Invoice Counter";
        FinancialYear: Code[5];
        NextNo: BigInteger;
        AIRIQInvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
    begin
        FinancialYear := GetFinancialYear();

        Counter.LockTable();

        if Counter.Get(FinancialYear) then begin
            Counter."Last Invoice No." += 1;
            NextNo := Counter."Last Invoice No.";
            Counter.Modify(true);
        end else begin
            Counter.Init();
            Counter."Financial Year" := FinancialYear;
            Counter."Last Invoice No." := 1;
            NextNo := 1;
            Counter.Insert(true);
        end;

        exit(StrSubstNo('AIRIQ/VI%1/%2', NextNo, FinancialYear));
    end;

    local procedure GetFinancialYear(): Code[5]
    var
        CurrentDate: Date;
        CurrentYear: Integer;
        NextYear: Integer;
    begin
        CurrentDate := Today();

        if Date2DMY(CurrentDate, 2) >= 4 then begin
            CurrentYear := Date2DMY(CurrentDate, 3) MOD 100;
            NextYear := (CurrentYear + 1) MOD 100;
        end else begin
            CurrentYear := (Date2DMY(CurrentDate, 3) - 1) MOD 100;
            NextYear := Date2DMY(CurrentDate, 3) MOD 100;
        end;

        exit(StrSubstNo('%1-%2', CurrentYear, NextYear));
    end;
}