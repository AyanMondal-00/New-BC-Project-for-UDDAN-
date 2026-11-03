codeunit 50668 "TP Purchase Inv Worker"
{
    TableNo = "Third Party Sample Purchase";
    Permissions = tabledata "Purchase Header" = rimd, tabledata "Purchase Line" = rimd;

    trigger OnRun()
    var
        Purchase: Record "Third Party Sample Purchase";
        Vendor: Record Vendor;
        Item: Record Item;
        Header: Record "Purchase Header";
        Line: Record "Purchase Line";
        InvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
        ExistingNo: Code[20];
    begin
        Purchase.LockTable();
        Purchase.Get(Rec."Serial No.");
        if Purchase."Invoice Posted" or (Purchase."Purchase Invoice No." <> '') then
            Error('Serial No. %1 already has purchase invoice %2.', Purchase."Serial No.", Purchase."Purchase Invoice No.");
        Purchase.ValidateSource();
        ResolveVendor(Purchase, Vendor);
        ResolveItem(Purchase, Item);
        if ConflictingInvoiceExists(Purchase, '', ExistingNo) then
            Error('A purchase invoice for PNR %1 already exists: %2.', Purchase.PNR, ExistingNo);

        Header.Init();
        Header."Document Type" := Header."Document Type"::Invoice;
        Header.Insert(true);
        Header.Validate("Buy-from Vendor No.", Vendor."No.");
        Header.Validate("Document Date", DT2Date(Purchase."Purchase Date"));
        Header.Validate("Vendor Invoice No.", InvoiceNoMgt.GetNextInvoiceNo());
        Header.Modify(true);

        Line.Init();
        Line."Document Type" := Header."Document Type";
        Line."Document No." := Header."No.";
        Line."Line No." := 10000;
        Line.Insert(true);
        Line.Validate(Type, Line.Type::Item);
        Line.Validate("No.", Item."No.");
        Line.Description := Purchase.PNR;
        Line.Validate("Location Code", 'SILIGURI');
        Line.Validate(Quantity, Purchase."Total Pax");
        Line.Validate("Direct Unit Cost", Purchase.Rate);
        Line."Sample Purchase Date" := Purchase."Purchase Date";
        Line."Sample Entry Date" := Purchase."Entry Date";
        Line."Sample Travel Date" := Purchase."Travel Date";
        Line."Sample Airline" := Purchase.Airline;
        Line."Sample Sector" := Purchase.Sector;
        Line."Sample Flight Type" := Purchase.Type;
        Line."Sample Supplier ID" := Purchase."Supplier ID";
        Line.Modify(true);

        Purchase."Purchase Invoice No." := Header."No.";
        Purchase."Invoice Created" := true;
        Purchase."Item Created" := true;
        Purchase."Select" := false;
        Purchase.Modify(true);
        Rec := Purchase;
    end;

    local procedure ResolveVendor(Purchase: Record "Third Party Sample Purchase"; var Vendor: Record Vendor)
    begin
        if Vendor.Get(Purchase."Supplier ID") then exit;
        Vendor.SetRange(Name, Purchase.Airline);
        if not Vendor.FindFirst() then
            Error('Vendor not found for Supplier ID %1 or Airline %2.', Purchase."Supplier ID", Purchase.Airline);
    end;

    local procedure ResolveItem(Purchase: Record "Third Party Sample Purchase"; var Item: Record Item)
    begin
        if Item.Get(Purchase.PNR) then exit;
        Item.SetRange(Description, Purchase.PNR);
        if not Item.FindFirst() then
            Error('Item for PNR %1 not found. Run Create Items first.', Purchase.PNR);
    end;

    procedure ConflictingInvoiceExists(Purchase: Record "Third Party Sample Purchase"; CurrentInvoiceNo: Code[20]; var ExistingNo: Code[20]): Boolean
    var
        Sample: Record "Sample Purchase";
        Other: Record "Third Party Sample Purchase";
        OpenLine: Record "Purchase Line";
        PostedLine: Record "Purch. Inv. Line";
    begin
        Sample.SetRange(PNR, Purchase.PNR);
        Sample.SetFilter("Purchase Invoice No.", '<>%1', '');
        if Sample.FindFirst() then begin
            ExistingNo := Sample."Purchase Invoice No.";
            exit(true);
        end;
        Other.SetRange(PNR, Purchase.PNR);
        Other.SetFilter("Serial No.", '<>%1', Purchase."Serial No.");
        Other.SetFilter("Purchase Invoice No.", '<>%1', '');
        if Other.FindFirst() then begin
            ExistingNo := Other."Purchase Invoice No.";
            exit(true);
        end;
        OpenLine.SetRange("Document Type", OpenLine."Document Type"::Invoice);
        OpenLine.SetRange(Description, Purchase.PNR);
        if CurrentInvoiceNo <> '' then
            OpenLine.SetFilter("Document No.", '<>%1', CurrentInvoiceNo);
        if OpenLine.FindSet() then
            repeat
                ExistingNo := OpenLine."Document No.";
                exit(true);
            until OpenLine.Next() = 0;
        PostedLine.SetRange(Description, Purchase.PNR);
        if PostedLine.FindSet() then
            repeat
                ExistingNo := PostedLine."Document No.";
                exit(true);
            until PostedLine.Next() = 0;
        exit(false);
    end;
}
