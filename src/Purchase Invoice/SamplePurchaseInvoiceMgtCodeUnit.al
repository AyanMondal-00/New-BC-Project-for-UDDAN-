codeunit 50336 "Sample Purchase Invoice Mngt"
{
    procedure CreatePurchaseInvoices()
    var
        SamplePurchase: Record "Sample Purchase";
    begin
        CreatePurchaseInvoices(SamplePurchase);
    end;

    procedure CreatePurchaseInvoices(var SelectedSamplePurchase: Record "Sample Purchase")
    var
        ProcessRec: Record "Sample Purchase";
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

                // Strong PNR duplicate protection
                if PNRInvoiceExists(ProcessRec.PNR, ExistingInvoiceNo) then begin
                    DuplicateCount += 1;

                    if ExistingInvoiceNo <> '' then begin
                        ProcessRec."Purchase Invoice No." := ExistingInvoiceNo;
                        ProcessRec."Select" := false;
                        ProcessRec.Modify(true);
                    end;
                end else begin
                    if CreateSinglePurchaseInvoice(
                        ProcessRec,
                        ErrorDetails)
                    then begin
                        CreatedCount += 1;

                        ProcessRec."Select" := false;
                        ProcessRec.Modify(true);
                    end else
                        ErrorCount += 1;
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

    local procedure CreateSinglePurchaseInvoice(
        var ProcessRec: Record "Sample Purchase";
        var ErrorDetails: Text): Boolean
    var
        PurchHeader: Record "Purchase Header";
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
            Item."No.");

        PurchLine.Description :=
            ProcessRec.PNR;

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
        // Line Amount = (Total Pax × Rate) + Other Charges
        // =========================================================
        if ProcessRec."Other Charges" <> 0 then begin
            PurchLine.Get(
                PurchLine."Document Type",
                PurchLine."Document No.",
                PurchLine."Line No.");

            PurchLine.Validate(
                "Line Amount",
                (ProcessRec."Total Pax" * ProcessRec.Rate) +
                ProcessRec."Other Charges");

            PurchLine.Modify(true);
        end;

        // -------------------------
        // Source record update
        // -------------------------
        ProcessRec."Purchase Invoice No." :=
            PurchHeader."No.";

        ProcessRec."Select" := false;

        ProcessRec.Modify(true);

        exit(true);
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