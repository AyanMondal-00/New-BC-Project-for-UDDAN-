
codeunit 50316 "API SP Purchase Inv Worker"
{
    TableNo = "API Sample Purchase";

    Permissions =
        tabledata "Purchase Header" = rimd,
        tabledata "Purchase Line" = rimd;

    trigger OnRun()
    var
        Purchase: Record "API Sample Purchase";
        Vendor: Record Vendor;
        Item: Record Item;
        Header: Record "Purchase Header";
        Line: Record "Purchase Line";
        InvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
        ExistingNo: Code[20];
    begin
        // STEP 1: GET SELECTED PURCHASE RECORD
        Purchase.LockTable();
        Purchase.Get(Rec."Serial No.");

        // STEP 2: PREVENT DUPLICATE INVOICE
        if Purchase."Invoice Posted" or
           (Purchase."Purchase Invoice No." <> '') then
            Error(
                'Serial No. %1 already has purchase invoice %2.',
                Purchase."Serial No.",
                Purchase."Purchase Invoice No.");

        // STEP 3: FINAL VALIDATION
        // Incomplete manual entries are allowed in staging.
        // Mandatory validation runs only during invoice creation.
        Purchase.ValidateSource();

        // STEP 4: RESOLVE VENDOR
        ResolveVendor(Purchase, Vendor);

        // STEP 5: RESOLVE ITEM
        ResolveItem(Purchase, Item);

        // STEP 6: CHECK EXISTING INVOICES
        if ConflictingInvoiceExists(Purchase, '', ExistingNo) then
            Error(
                'A purchase invoice for PNR %1 already exists: %2.',
                Purchase.PNR,
                ExistingNo);

        // STEP 7: CREATE PURCHASE INVOICE HEADER
        Header.Init();

        Header."Document Type" :=
            Header."Document Type"::Invoice;

        // Standard BC Purchase Invoice No. Series
        Header.Insert(true);

        Header.Validate(
            "Buy-from Vendor No.",
            Vendor."No.");

        Header.Validate(
            "Document Date",
            DT2Date(Purchase."Purchase Date"));

        // Existing Vendor Invoice Number Logic
        Header.Validate(
            "Vendor Invoice No.",
            InvoiceNoMgt.GetNextInvoiceNo());

        Header.Modify(true);

        // STEP 8: CREATE PURCHASE INVOICE LINE
        Line.Init();

        Line."Document Type" :=
            Header."Document Type";

        Line."Document No." :=
            Header."No.";

        Line."Line No." := 10000;

        Line.Insert(true);

        Line.Validate(
            Type,
            Line.Type::Item);

        Line.Validate(
            "No.",
            Item."No.");

        Line.Description := Purchase.PNR;

        Line.Validate(
            "Location Code",
            'SILIGURI');

        Line.Validate(
            Quantity,
            Purchase."Total Pax");

        Line.Validate(
            "Direct Unit Cost",
            Purchase.Rate);

        // STEP 9: PURCHASE DETAILS MAPPING
        Line."Sample Purchase Date" :=
            Purchase."Purchase Date";

        Line."Sample Entry Date" :=
            Purchase."Entry Date";

        Line."Sample Travel Date" :=
            Purchase."Travel Date";

        Line."Sample Airline" :=
            Purchase.Airline;

        Line."Sample Sector" :=
            Purchase.Sector;

        Line."Sample Flight Type" :=
            Purchase.Type;

        Line."Sample Supplier ID" :=
            Purchase."Supplier ID";

        Line.Modify(true);

        // STEP 10: UPDATE STAGING STATUS
        Purchase."Purchase Invoice No." :=
            Header."No.";

        Purchase."Invoice Created" := true;
        Purchase."Item Created" := true;
        Purchase."Select" := false;

        Purchase.Modify(true);

        Rec := Purchase;
    end;

    // ==========================================
    // VENDOR RESOLUTION
    // ==========================================

    local procedure ResolveVendor(
        Purchase: Record "API Sample Purchase";
        var Vendor: Record Vendor)
    begin
        if Vendor.Get(Purchase."Supplier ID") then
            exit;

        Vendor.SetRange(Name, Purchase.Airline);

        if not Vendor.FindFirst() then
            Error(
                'Vendor not found for Supplier ID %1 or Airline %2.',
                Purchase."Supplier ID",
                Purchase.Airline);
    end;

    // ==========================================
    // ITEM RESOLUTION
    // ==========================================

    local procedure ResolveItem(
        Purchase: Record "API Sample Purchase";
        var Item: Record Item)
    begin
        if Item.Get(Purchase.PNR) then
            exit;

        Item.SetRange(Description, Purchase.PNR);

        if not Item.FindFirst() then
            Error(
                'Item for PNR %1 not found. Run Create Items first.',
                Purchase.PNR);
    end;

    // ==========================================
    // DUPLICATE INVOICE PROTECTION
    // ==========================================

    procedure ConflictingInvoiceExists(
        Purchase: Record "API Sample Purchase";
        CurrentInvoiceNo: Code[20];
        var ExistingNo: Code[20]): Boolean
    var
        Sample: Record "Sample Purchase";
        Other: Record "API Sample Purchase";
        OpenLine: Record "Purchase Line";
        PostedLine: Record "Purch. Inv. Line";
    begin
        // Check Normal Sample Purchase
        Sample.SetRange(PNR, Purchase.PNR);

        Sample.SetFilter(
            "Purchase Invoice No.",
            '<>%1',
            '');

        if Sample.FindFirst() then begin
            ExistingNo := Sample."Purchase Invoice No.";
            exit(true);
        end;

        // Check Other Third-Party Purchase Records
        Other.SetRange(PNR, Purchase.PNR);

        Other.SetFilter(
            "Serial No.",
            '<>%1',
            Purchase."Serial No.");

        Other.SetFilter(
            "Purchase Invoice No.",
            '<>%1',
            '');

        if Other.FindFirst() then begin
            ExistingNo := Other."Purchase Invoice No.";
            exit(true);
        end;

        // Check Unposted Purchase Invoice Lines
        OpenLine.SetRange(
            "Document Type",
            OpenLine."Document Type"::Invoice);

        OpenLine.SetRange(
            Description,
            Purchase.PNR);

        if CurrentInvoiceNo <> '' then
            OpenLine.SetFilter(
                "Document No.",
                '<>%1',
                CurrentInvoiceNo);

        if OpenLine.FindFirst() then begin
            ExistingNo := OpenLine."Document No.";
            exit(true);
        end;

        // Check Posted Purchase Invoice Lines
        PostedLine.SetRange(
            Description,
            Purchase.PNR);

        if PostedLine.FindFirst() then begin
            ExistingNo := PostedLine."Document No.";
            exit(true);
        end;

        exit(false);
    end;
}
