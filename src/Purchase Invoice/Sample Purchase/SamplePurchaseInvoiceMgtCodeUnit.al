codeunit 50336 "Sample Purchase Invoice Mngt"
{
    Permissions =
        tabledata "Purchase Header" = rimd,
        tabledata "Purchase Line" = rimd,
        tabledata "Purch. Inv. Header" = r,
        tabledata "Purch. Inv. Line" = r,
        tabledata "Sample Purchase" = rimd;

    procedure CreatePurchaseInvoices()
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        CreatePurchaseInvoices(SamplePurchase);
    end;

    procedure CreatePurchaseInvoices(var SelectedSamplePurchase: Record "Sample Purchase")
    var
        ProcessRec: Record "Sample Purchase";
        FreshRec: Record "Sample Purchase";
        CreatedCount: Integer;
        DuplicateCount: Integer;
        ErrorCount: Integer;
        ErrorDetails: Text;
        SummaryMsg: Text;
        ExistingInvoiceNo: Code[20];
    begin
        ProcessRec.Copy(SelectedSamplePurchase);

        if ProcessRec.IsEmpty() then begin
            Message('No Sample Purchase records selected.');
            exit;
        end;

        if ProcessRec.FindSet(true) then
            repeat
                ExistingInvoiceNo := '';

                // Re-read latest state from database with record locking to prevent concurrent race conditions
                if FreshRec.Get(ProcessRec."Serial No.") then begin
                    FreshRec.LockTable();
                    FreshRec.Get(ProcessRec."Serial No.");

                    // Verify record has not already been invoiced or posted concurrently
                    if (FreshRec."Purchase Invoice No." <> '') or FreshRec."Invoice Posted" then begin
                        DuplicateCount += 1;
                        FreshRec."Select" := false;
                        FreshRec.Modify(true);
                        Commit();
                    end else if PNRInvoiceExists(FreshRec.PNR, ExistingInvoiceNo) then begin
                        DuplicateCount += 1;

                        if ExistingInvoiceNo <> '' then begin
                            FreshRec."Purchase Invoice No." := ExistingInvoiceNo;
                            FreshRec."Select" := false;
                            FreshRec.Modify(true);
                            Commit();
                        end;
                    end else begin
                        if CreateSinglePurchaseInvoice(
                            FreshRec,
                            ErrorDetails)
                        then begin
                            CreatedCount += 1;

                            FreshRec."Select" := false;
                            FreshRec.Modify(true);
                            Commit();
                        end else
                            ErrorCount += 1;
                    end;
                end;

            until ProcessRec.Next() = 0;

        // Result
        if (CreatedCount > 0) and
           (DuplicateCount = 0) and
           (ErrorCount = 0) then begin

            Message(
                'Success! %1 Purchase Invoice(s) created successfully.',
                CreatedCount);

        end else if (CreatedCount = 0) and
                   (DuplicateCount > 0) and
                   (ErrorCount = 0) then begin

            Message(
                'Already Invoiced! All %1 selected record(s) have already been invoiced.',
                DuplicateCount);

        end else begin
            SummaryMsg :=
                StrSubstNo(
                    'Purchase Invoice Creation Summary:\- Created: %1\- Already Invoiced: %2\- Errors: %3',
                    CreatedCount,
                    DuplicateCount,
                    ErrorCount);

            if ErrorCount > 0 then
                SummaryMsg +=
                    StrSubstNo('\Details:%1', ErrorDetails);

            Message(SummaryMsg);
        end;
    end;

    procedure CreateAndPostPurchaseInvoices()
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        CreateAndPostPurchaseInvoices(SamplePurchase);
    end;

    procedure CreateAndPostPurchaseInvoices(var SelectedSamplePurchase: Record "Sample Purchase")
    var
        ProcessRec: Record "Sample Purchase";
        FreshRec: Record "Sample Purchase";
        PurchHeader: Record "Purchase Header";
        CreatedAndPostedCount: Integer;
        DuplicateCount: Integer;
        ErrorCount: Integer;
        ErrorDetails: Text;
        SummaryMsg: Text;
        ExistingInvoiceNo: Code[20];
        PostedInvoiceNo: Code[20];
        PostingError: Text;
    begin
        ProcessRec.Copy(SelectedSamplePurchase);

        if ProcessRec.IsEmpty() then begin
            Message('No Sample Purchase records selected.');
            exit;
        end;

        if ProcessRec.FindSet(true) then
            repeat
                ExistingInvoiceNo := '';

                // Re-read latest state from database with record locking to prevent concurrent race conditions
                if FreshRec.Get(ProcessRec."Serial No.") then begin
                    FreshRec.LockTable();
                    FreshRec.Get(ProcessRec."Serial No.");

                    // Check if already posted or invoiced
                    if FreshRec."Invoice Posted" then begin
                        DuplicateCount += 1;
                        FreshRec."Select" := false;
                        FreshRec.Modify(true);
                        Commit();
                    end else if (FreshRec."Purchase Invoice No." <> '') and (not PurchHeaderExists(FreshRec."Purchase Invoice No.")) then begin
                        // Existing invoice was posted or closed
                        DuplicateCount += 1;
                        FreshRec."Select" := false;
                        FreshRec.Modify(true);
                        Commit();
                    end else if PNRInvoiceExists(FreshRec.PNR, ExistingInvoiceNo) then begin
                        DuplicateCount += 1;

                        if ExistingInvoiceNo <> '' then begin
                            FreshRec."Purchase Invoice No." := ExistingInvoiceNo;
                            FreshRec."Select" := false;
                            FreshRec.Modify(true);
                            Commit();
                        end;
                    end else begin
                        Clear(PurchHeader);
                        if CreateSinglePurchaseInvoiceInternal(
                            FreshRec,
                            ErrorDetails,
                            PurchHeader,
                            false)
                        then begin
                            // Prepare the Purchase Header for posting
                            PurchHeader.Receive := true;
                            PurchHeader.Invoice := true;
                            PurchHeader.Modify(true);

                            // Commit the created invoice before posting.
                            // In Business Central AL, Codeunit.Run cannot be evaluated in a condition
                            // (if Codeunit.Run(...) then) while an uncommitted write transaction is active.
                            // Committing here closes the write transaction so Codeunit.Run can execute safely.
                            Commit();

                            ClearLastError();
                            if Codeunit.Run(Codeunit::"Purch.-Post", PurchHeader) then begin
                                PostedInvoiceNo := GetPostedInvoiceNo(PurchHeader);

                                FreshRec."Purchase Invoice No." := PostedInvoiceNo;
                                FreshRec."Invoice Posted" := true;
                                FreshRec."Select" := false;
                                FreshRec.Modify(true);

                                Commit();
                                CreatedAndPostedCount += 1;
                            end else begin
                                PostingError := GetLastErrorText();
                                ClearLastError();

                                // Safe cleanup:
                                // Because Commit() was executed before posting, the draft PurchHeader exists in the database.
                                // If posting failed, we must delete this draft invoice so that:
                                // 1. No unmanaged draft invoice is left behind.
                                // 2. Future duplicate checks (PNRInvoiceExists) will not block retry of this PNR.
                                if PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.") then
                                    PurchHeader.Delete(true);

                                // Keep source record clean:
                                FreshRec."Invoice Posted" := false;
                                FreshRec."Purchase Invoice No." := '';
                                FreshRec."Select" := true;
                                FreshRec.Modify(true);

                                // Finalize cleanup transaction before moving to next record
                                Commit();

                                ErrorCount += 1;
                                ErrorDetails +=
                                    StrSubstNo(
                                        '\- Serial No. %1 (PNR %2): Posting failed: %3',
                                        FreshRec."Serial No.",
                                        FreshRec.PNR,
                                        PostingError);
                            end;
                        end else
                            ErrorCount += 1;
                    end;
                end;

            until ProcessRec.Next() = 0;

        // Result
        if (CreatedAndPostedCount > 0) and
           (DuplicateCount = 0) and
           (ErrorCount = 0) then begin

            Message(
                'Success! %1 Purchase Invoice(s) created and posted successfully.',
                CreatedAndPostedCount);

        end else if (CreatedAndPostedCount = 0) and
                   (DuplicateCount > 0) and
                   (ErrorCount = 0) then begin

            Message(
                'Already Invoiced! All %1 selected record(s) have already been invoiced.',
                DuplicateCount);

        end else begin
            SummaryMsg :=
                StrSubstNo(
                    'Create & Post Purchase Invoice Summary:\- Created & Posted: %1\- Already Invoiced: %2\- Errors: %3',
                    CreatedAndPostedCount,
                    DuplicateCount,
                    ErrorCount);

            if ErrorCount > 0 then
                SummaryMsg +=
                    StrSubstNo('\Details:%1', ErrorDetails);

            Message(SummaryMsg);
        end;
    end;

    local procedure CreateSinglePurchaseInvoice(
        var ProcessRec: Record "Sample Purchase";
        var ErrorDetails: Text): Boolean
    var
        PurchHeader: Record "Purchase Header";
    begin
        exit(CreateSinglePurchaseInvoiceInternal(ProcessRec, ErrorDetails, PurchHeader, true));
    end;

    local procedure CreateSinglePurchaseInvoiceInternal(
        var ProcessRec: Record "Sample Purchase";
        var ErrorDetails: Text;
        var PurchHeader: Record "Purchase Header";
        UpdateSourceRec: Boolean): Boolean
    var
        PurchLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        AIRIQInvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
    begin
        // -------------------------
        // Vendor lookup
        // -------------------------
        Clear(Vendor);

        if ProcessRec."Supplier ID" <> '' then
            if Vendor.Get(ProcessRec."Supplier ID") then;

        if Vendor."No." = '' then begin
            Clear(Vendor);
            Vendor.SetRange(Name, ProcessRec.Airline);

            if not Vendor.FindFirst() then begin
                ErrorDetails +=
                    StrSubstNo(
                        '\- Serial No. %1: Vendor not found for Airline "%2" / Supplier ID "%3".',
                        ProcessRec."Serial No.",
                        ProcessRec.Airline,
                        ProcessRec."Supplier ID");

                exit(false);
            end;
        end;

        // -------------------------
        // Item lookup
        // -------------------------
        Clear(Item);
        Item.SetRange(Description, ProcessRec.PNR);

        if not Item.FindFirst() then begin
            ErrorDetails +=
                StrSubstNo(
                    '\- Serial No. %1: Item not found for PNR "%2". Please run "Create Items" first.',
                    ProcessRec."Serial No.",
                    ProcessRec.PNR);

            exit(false);
        end;

        // -------------------------
        // Validation
        // -------------------------
        if ProcessRec."Total Pax" <= 0 then begin
            ErrorDetails +=
                StrSubstNo(
                    '\- Serial No. %1: Total Pax must be greater than 0.',
                    ProcessRec."Serial No.");

            exit(false);
        end;

        if ProcessRec.Rate < 0 then begin
            ErrorDetails +=
                StrSubstNo(
                    '\- Serial No. %1: Rate cannot be negative.',
                    ProcessRec."Serial No.");

            exit(false);
        end;

        if ProcessRec."Other Charges" < 0 then begin
            ErrorDetails +=
                StrSubstNo(
                    '\- Serial No. %1: Other Charges cannot be negative.',
                    ProcessRec."Serial No.");

            exit(false);
        end;

        // =========================================================
        // IMPORTANT:
        // Create a completely fresh Purchase Header for every row.
        // =========================================================
        Clear(PurchHeader);
        PurchHeader.Init();

        PurchHeader."Document Type" :=
            PurchHeader."Document Type"::Invoice;

        PurchHeader.Validate(
            "Buy-from Vendor No.",
            Vendor."No.");

        PurchHeader.Validate(
            "Vendor Invoice No.",
            AIRIQInvoiceNoMgt.GetNextInvoiceNo());

        PurchHeader.Insert(true);

        // =========================================================
        // Create Purchase Line
        // =========================================================
        Clear(PurchLine);
        PurchLine.Init();

        PurchLine."Document Type" :=
            PurchHeader."Document Type";

        PurchLine."Document No." :=
            PurchHeader."No.";

        PurchLine."Line No." := 10000;

        PurchLine.Validate(
            Type,
            PurchLine.Type::Item);

        PurchLine.Validate(
            "No.",
             ProcessRec.PNR);

        PurchLine.Description :=
            ProcessRec.PNR;

        PurchLine.Validate
        ("Location Code", 'SILIGURI');

        PurchLine.Validate(
            Quantity,
            ProcessRec."Total Pax");

        PurchLine.Validate(
            "Direct Unit Cost",
            ProcessRec.Rate);

        // AIRIQ custom fields
        PurchLine."Sample Purchase Date" :=
            ProcessRec."Purchase Date";

        PurchLine."Sample Entry Date" :=
            ProcessRec."Entry Date";

        PurchLine."Sample Travel Date" :=
            ProcessRec."Travel Date";

        PurchLine."Sample Airline" :=
            ProcessRec.Airline;

        PurchLine."Sample Sector" :=
            ProcessRec.Sector;

        PurchLine."Sample Flight Type" :=
            ProcessRec.Type;

        PurchLine."Sample Supplier ID" :=
            ProcessRec."Supplier ID";

        PurchLine."Sample Base Fare" :=
            ProcessRec."Base Fare";

        PurchLine."Sample Other Charges" :=
            ProcessRec."Other Charges";

        PurchLine.Insert(true);

        // =========================================================
        // Required formula:
        // Line Amount = (Total Pax × Rate) + (Total Pax x Other Charges)= Line Amount Excl. VAT
        // =========================================================
        if ProcessRec."Other Charges" <> 0 then begin
            PurchLine.Get(
                PurchLine."Document Type",
                PurchLine."Document No.",
                PurchLine."Line No.");

            // Quantity = Total Pax
            PurchLine.Validate(
                Quantity,
                ProcessRec."Total Pax");

            // Direct Unit Cost Excl. VAT = Base Fare + Other Charges
            PurchLine.Validate(
                "Direct Unit Cost",
                ProcessRec."Base Fare" + ProcessRec."Other Charges");

            // Line Amount Excl. VAT = Direct Unit Cost * Total Pax
            PurchLine.Validate(
                "Line Amount",
                (ProcessRec."Base Fare" + ProcessRec."Other Charges") *
                ProcessRec."Total Pax");

            PurchLine.Modify(true);
        end;

        if UpdateSourceRec then begin
            // -------------------------
            // Source record update
            // -------------------------
            ProcessRec."Purchase Invoice No." :=
                PurchHeader."No.";

            ProcessRec."Select" := false;

            ProcessRec.Modify(true);
        end;

        exit(true);
    end;

    local procedure PurchHeaderExists(DocNo: Code[20]): Boolean
    var
        PurchHeader: Record "Purchase Header";
    begin
        if DocNo = '' then
            exit(false);
        exit(PurchHeader.Get(PurchHeader."Document Type"::Invoice, DocNo));
    end;

    local procedure GetPostedInvoiceNo(var PurchHeader: Record "Purchase Header"): Code[20]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.Reset();
        PurchInvHeader.SetCurrentKey("Pre-Assigned No.");
        PurchInvHeader.SetRange("Pre-Assigned No.", PurchHeader."No.");
        if PurchInvHeader.FindLast() then
            exit(PurchInvHeader."No.");

        if PurchHeader."Last Posting No." <> '' then
            exit(PurchHeader."Last Posting No.");

        if PurchHeader."Posting No." <> '' then
            exit(PurchHeader."Posting No.");

        exit(PurchHeader."No.");
    end;

    local procedure PNRInvoiceExists(
        PNR: Text[10];
        var ExistingInvoiceNo: Code[20]): Boolean
    var
        PurchLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
        SamplePurchase: Record "Sample Purchase";
    begin
        ExistingInvoiceNo := '';

        if PNR = '' then
            exit(false);

        // ---------------------------------------------------------
        // 1. Source Sample Purchase history
        // ---------------------------------------------------------
        SamplePurchase.Reset();
        SamplePurchase.SetRange(PNR, PNR);
        SamplePurchase.SetFilter(
            "Purchase Invoice No.",
            '<>%1',
            '');

        if SamplePurchase.FindFirst() then begin
            ExistingInvoiceNo :=
                SamplePurchase."Purchase Invoice No.";

            exit(true);
        end;

        // ---------------------------------------------------------
        // 2. Open Purchase Invoice Lines
        // ---------------------------------------------------------
        PurchLine.Reset();
        PurchLine.SetRange(
            "Document Type",
            PurchLine."Document Type"::Invoice);

        PurchLine.SetRange(
            Description,
            PNR);

        if PurchLine.FindFirst() then begin
            ExistingInvoiceNo :=
                PurchLine."Document No.";

            exit(true);
        end;

        // ---------------------------------------------------------
        // 3. Posted Purchase Invoice Lines
        // ---------------------------------------------------------
        PurchInvLine.Reset();
        PurchInvLine.SetRange(
            Description,
            PNR);

        if PurchInvLine.FindFirst() then begin
            ExistingInvoiceNo :=
                PurchInvLine."Document No.";

            exit(true);
        end;

        exit(false);
    end;
}