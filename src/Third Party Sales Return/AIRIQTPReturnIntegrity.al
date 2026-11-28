table 50726 "AIRIQ TP SR Return Registry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Return No."; Code[50])
        {
            DataClassification = CustomerContent;
        }

        field(2; "Serial No."; Code[20])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Return No.")
        {
            Clustered = true;
        }
    }
}

codeunit 50727 "AIRIQ TP SR Integrity"
{
    Permissions =
        tabledata "AIRIQ TP SR Return Registry" = rimd;

    procedure Audit()
    var
        Source: Record "Third Party Sales Return";
    begin
        Source.LockTable();

        if Source.FindSet() then
            repeat
                Claim(Source);
            until Source.Next() = 0;
    end;

    local procedure Claim(Source: Record "Third Party Sales Return")
    var
        Registry: Record "AIRIQ TP SR Return Registry";
        Other: Record "Third Party Sales Return";
    begin
        if Source.IsTemporary() or
           (Source."Return No." = '') then
            exit;

        Registry.LockTable();

        if Registry.Get(Source."Return No.") then begin
            if Registry."Serial No." <> Source."Serial No." then
                Error(
                    'Sales Return with Return No. %1 already exists.',
                    Source."Return No.");
        end else begin
            Registry.Init();
            Registry."Return No." := Source."Return No.";
            Registry."Serial No." := Source."Serial No.";
            Registry.Insert();
        end;

        Other.SetRange(
            "Return No.",
            Source."Return No.");

        Other.SetFilter(
            "Serial No.",
            '<>%1',
            Source."Serial No.");

        if not Other.IsEmpty() then
            Error(
                'Sales Return with Return No. %1 already exists.',
                Source."Return No.");
    end;

    local procedure Release(Source: Record "Third Party Sales Return")
    var
        Registry: Record "AIRIQ TP SR Return Registry";
    begin
        if Source.IsTemporary() or
           (Source."Return No." = '') then
            exit;

        Registry.LockTable();

        if Registry.Get(Source."Return No.") then
            if Registry."Serial No." = Source."Serial No." then
                Registry.Delete();
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Third Party Sales Return",
        'OnAfterInsertEvent',
        '',
        false,
        false)]
    local procedure Inserted(
        var Rec: Record "Third Party Sales Return";
        RunTrigger: Boolean)
    begin
        Claim(Rec);
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Third Party Sales Return",
        'OnAfterModifyEvent',
        '',
        false,
        false)]
    local procedure Modified(
        var Rec: Record "Third Party Sales Return";
        var xRec: Record "Third Party Sales Return";
        RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if xRec."Sales Credit Memo Created" and
           (Rec."Return No." <> xRec."Return No.") then
            Error(
                'Return No. cannot change after Sales Credit Memo was created.');

        if Rec."Return No." <> xRec."Return No." then
            Release(xRec);

        Claim(Rec);
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Third Party Sales Return",
        'OnAfterDeleteEvent',
        '',
        false,
        false)]
    local procedure Deleted(
        var Rec: Record "Third Party Sales Return";
        RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        // Allow deletion even after Credit Memo creation.
        // The Credit Memo itself is NOT deleted.

        // Remove passenger staging details.
        RemovePassengers(Rec);

        // Release Return No. from custom registry.
        Release(Rec);
    end;

    local procedure RemovePassengers(
        Source: Record "Third Party Sales Return")
    var
        Passenger: Record "TP Sales Return Passenger";
    begin
        Passenger.SetRange(
            "Return No.",
            Source."Return No.");

        Passenger.SetRange(
            PNR,
            Source.PNR);

        Passenger.DeleteAll(true);
    end;

    [EventSubscriber(
        ObjectType::Table,
        Database::"Third Party Sales Return",
        'OnAfterRenameEvent',
        '',
        false,
        false)]
    local procedure Renamed(
        var Rec: Record "Third Party Sales Return";
        var xRec: Record "Third Party Sales Return";
        RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Sales Credit Memo Created" then
            Error(
                'A Sales Return linked to a credit memo cannot be renamed.');

        Release(xRec);
        Claim(Rec);
    end;
}

codeunit 50728 "AIRIQ TP SR Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        Integrity: Codeunit "AIRIQ TP SR Integrity";
    begin
        Integrity.Audit();
    end;
}

codeunit 50729 "AIRIQ TP SR Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        Integrity: Codeunit "AIRIQ TP SR Integrity";
    begin
        Integrity.Audit();
    end;
}