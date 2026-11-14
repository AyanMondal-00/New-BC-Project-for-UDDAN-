page 50746 "AIRIQ BS Party Balances"
{
    Caption = 'AIRIQ Customer / Vendor Balances';
    PageType = List;
    SourceTable = "AIRIQ BS Party Balance Buffer";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Context)
            {
                Caption = 'Balance Sheet Context';
                field(SelectedAccount; SelectedAccount)
                {
                    Caption = 'G/L Account No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(SelectedDate; SelectedDate)
                {
                    Caption = 'Balance As On Date';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(PartyTypeText; PartyTypeText)
                {
                    Caption = 'Ledger Type';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            repeater(Parties)
            {
                field("Party No."; Rec."Party No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    trigger OnDrillDown()
                    begin
                        OpenPartyLedger();
                    end;
                }
                field("Party Name"; Rec."Party Name")
                {
                    ApplicationArea = All;
                }
                field("Balance (LCY)"; Rec."Balance (LCY)")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Open customer or vendor ledger entries for this party, posting group and as-on date.';
                    trigger OnDrillDown()
                    begin
                        OpenPartyLedger();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ViewPartyLedger)
            {
                Caption = 'View Customer / Vendor Ledger Entries';
                ApplicationArea = All;
                Image = Ledger;
                trigger OnAction()
                begin
                    OpenPartyLedger();
                end;
            }
            action(ViewGeneralLedger)
            {
                Caption = 'View General Ledger Entries';
                ApplicationArea = All;
                Image = GeneralLedger;
                trigger OnAction()
                var
                    GLEntry: Record "G/L Entry";
                begin
                    GLEntry.SetRange("G/L Account No.", SelectedAccount);
                    GLEntry.SetFilter("Posting Date", '..%1', SelectedDate);
                    Page.Run(Page::"General Ledger Entries", GLEntry);
                end;
            }
        }
    }

    var
        SelectedAccount: Code[20];
        SelectedDate: Date;
        IsVendorLedger: Boolean;
        PartyTypeText: Text[20];

    procedure LoadBalances(AccountNo: Code[20]; AsOfDate: Date; VendorMode: Boolean)
    begin
        SelectedAccount := AccountNo;
        SelectedDate := AsOfDate;
        IsVendorLedger := VendorMode;
        Rec.Reset();
        Rec.DeleteAll();
        if IsVendorLedger then begin
            PartyTypeText := 'Vendor';
            LoadVendors();
        end else begin
            PartyTypeText := 'Customer';
            LoadCustomers();
        end;
        Rec.Reset();
    end;

    local procedure LoadCustomers()
    var
        PostingGroup: Record "Customer Posting Group";
        LedgerEntry: Record "Cust. Ledger Entry";
        DetailedEntry: Record "Detailed Cust. Ledg. Entry";
        Customer: Record Customer;
        BalanceAmount: Decimal;
    begin
        PostingGroup.SetRange("Receivables Account", SelectedAccount);
        if PostingGroup.FindSet() then
            repeat
                LedgerEntry.Reset();
                LedgerEntry.SetRange("Customer Posting Group", PostingGroup.Code);
                LedgerEntry.SetFilter("Posting Date", '..%1', SelectedDate);
                if LedgerEntry.FindSet() then
                    repeat
                        DetailedEntry.Reset();
                        DetailedEntry.SetRange("Cust. Ledger Entry No.", LedgerEntry."Entry No.");
                        DetailedEntry.SetFilter("Posting Date", '..%1', SelectedDate);
                        DetailedEntry.CalcSums("Amount (LCY)");
                        BalanceAmount := DetailedEntry."Amount (LCY)";
                        if BalanceAmount <> 0 then begin
                            if not Rec.Get(Rec."Party Type"::Customer, LedgerEntry."Customer No.") then begin
                                Rec.Init();
                                Rec."Party Type" := Rec."Party Type"::Customer;
                                Rec."Party No." := LedgerEntry."Customer No.";
                                if Customer.Get(LedgerEntry."Customer No.") then
                                    Rec."Party Name" := Customer.Name
                                else
                                    Rec."Party Name" := LedgerEntry."Customer Name";
                                Rec."Balance (LCY)" := 0;
                                Rec.Insert();
                            end;
                            Rec."Balance (LCY)" += BalanceAmount;
                            Rec.Modify();
                        end;
                    until LedgerEntry.Next() = 0;
            until PostingGroup.Next() = 0;
    end;

    local procedure LoadVendors()
    var
        PostingGroup: Record "Vendor Posting Group";
        LedgerEntry: Record "Vendor Ledger Entry";
        DetailedEntry: Record "Detailed Vendor Ledg. Entry";
        Vendor: Record Vendor;
        BalanceAmount: Decimal;
    begin
        PostingGroup.SetRange("Payables Account", SelectedAccount);
        if PostingGroup.FindSet() then
            repeat
                LedgerEntry.Reset();
                LedgerEntry.SetRange("Vendor Posting Group", PostingGroup.Code);
                LedgerEntry.SetFilter("Posting Date", '..%1', SelectedDate);
                if LedgerEntry.FindSet() then
                    repeat
                        DetailedEntry.Reset();
                        DetailedEntry.SetRange("Vendor Ledger Entry No.", LedgerEntry."Entry No.");
                        DetailedEntry.SetFilter("Posting Date", '..%1', SelectedDate);
                        DetailedEntry.CalcSums("Amount (LCY)");
                        BalanceAmount := DetailedEntry."Amount (LCY)";
                        if BalanceAmount <> 0 then begin
                            if not Rec.Get(Rec."Party Type"::Vendor, LedgerEntry."Vendor No.") then begin
                                Rec.Init();
                                Rec."Party Type" := Rec."Party Type"::Vendor;
                                Rec."Party No." := LedgerEntry."Vendor No.";
                                if Vendor.Get(LedgerEntry."Vendor No.") then
                                    Rec."Party Name" := Vendor.Name
                                else
                                    Rec."Party Name" := LedgerEntry."Vendor Name";
                                Rec."Balance (LCY)" := 0;
                                Rec.Insert();
                            end;
                            Rec."Balance (LCY)" += BalanceAmount;
                            Rec.Modify();
                        end;
                    until LedgerEntry.Next() = 0;
            until PostingGroup.Next() = 0;
    end;

    local procedure OpenPartyLedger()
    var
        CustEntry: Record "Cust. Ledger Entry";
        VendorEntry: Record "Vendor Ledger Entry";
        GroupFilter: Text;
    begin
        if Rec."Party No." = '' then
            exit;
        GroupFilter := GetPostingGroupFilter();
        if GroupFilter = '' then
            exit;
        if IsVendorLedger then begin
            VendorEntry.SetRange("Vendor No.", Rec."Party No.");
            VendorEntry.SetFilter("Vendor Posting Group", GroupFilter);
            VendorEntry.SetFilter("Posting Date", '..%1', SelectedDate);
            Page.Run(Page::"Vendor Ledger Entries", VendorEntry);
        end else begin
            CustEntry.SetRange("Customer No.", Rec."Party No.");
            CustEntry.SetFilter("Customer Posting Group", GroupFilter);
            CustEntry.SetFilter("Posting Date", '..%1', SelectedDate);
            Page.Run(Page::"Customer Ledger Entries", CustEntry);
        end;
    end;

    local procedure GetPostingGroupFilter(): Text
    var
        CustomerGroup: Record "Customer Posting Group";
        VendorGroup: Record "Vendor Posting Group";
        ResultFilter: Text;
    begin
        if IsVendorLedger then begin
            VendorGroup.SetRange("Payables Account", SelectedAccount);
            if VendorGroup.FindSet() then
                repeat
                    if ResultFilter <> '' then
                        ResultFilter += '|';
                    ResultFilter += VendorGroup.Code;
                until VendorGroup.Next() = 0;
        end else begin
            CustomerGroup.SetRange("Receivables Account", SelectedAccount);
            if CustomerGroup.FindSet() then
                repeat
                    if ResultFilter <> '' then
                        ResultFilter += '|';
                    ResultFilter += CustomerGroup.Code;
                until CustomerGroup.Next() = 0;
        end;
        exit(ResultFilter);
    end;
}
