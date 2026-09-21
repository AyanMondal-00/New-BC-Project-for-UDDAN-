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
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        AIRIQInvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
        CreatedCount: Integer;
        DuplicateCount: Integer;
        ErrorCount: Integer;
        ErrorDetails: Text;
        SummaryMsg: Text;
        ExistingInvoiceNo: Code[20];
    begin
        ProcessRec.Copy(SelectedSamplePurchase);

        if (ProcessRec.Count = 1) and (not ProcessRec."Select") then begin
            ProcessRec.Reset();
            ProcessRec.SetRange("Select", true);
            if ProcessRec.IsEmpty() then
                ProcessRec.Copy(SelectedSamplePurchase);
        end;

        if ProcessRec.IsEmpty() then begin
            Message('No Sample Purchase records found to process.');
            exit;
        end;

        if ProcessRec.FindSet() then
            repeat
                // Strong PNR duplicate check
                if PNRInvoiceExists(ProcessRec.PNR, ExistingInvoiceNo) then begin
                    DuplicateCount += 1;
                    ProcessRec."Purchase Invoice No." := ExistingInvoiceNo;
                    ProcessRec.Modify(true);
                end else begin

                    // Smart Vendor lookup: First by Supplier ID (No.), then by Airline (Name)
                    Vendor.Reset();
                    if ProcessRec."Supplier ID" <> '' then
                        if Vendor.Get(ProcessRec."Supplier ID") then;

                    if Vendor."No." = '' then begin
                        Vendor.Reset();
                        Vendor.SetRange(Name, ProcessRec.Airline);
                        if not Vendor.FindFirst() then;
                    end;

                    if Vendor."No." = '' then begin
                        ErrorCount += 1;
                        ErrorDetails += StrSubstNo(
                            '\- Serial No. %1: Vendor not found for Airline "%2" / Supplier ID "%3".',
                            ProcessRec."Serial No.",
                            ProcessRec.Airline,
                            ProcessRec."Supplier ID");
                    end else begin

                        // Item check
                        Item.Reset();
                        Item.SetRange(Description, ProcessRec.PNR);

                        if not Item.FindFirst() then begin
                            ErrorCount += 1;
                            ErrorDetails += StrSubstNo(
                                '\- Serial No. %1: Item not found for PNR "%2". Please run "Create Items" first.',
                                ProcessRec."Serial No.",
                                ProcessRec.PNR);
                        end else begin

                            if ProcessRec."Total Pax" <= 0 then begin
                                ErrorCount += 1;
                                ErrorDetails += StrSubstNo(
                                    '\- Serial No. %1: Total Pax must be greater than 0.',
                                    ProcessRec."Serial No.");
                            end else begin

                                // Create Purchase Invoice Header
                                PurchHeader.Init();
                                PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
                                PurchHeader.Validate("Buy-from Vendor No.", Vendor."No.");
                                PurchHeader.Validate(
                                    "Vendor Invoice No.",
                                    AIRIQInvoiceNoMgt.GetNextInvoiceNo());
                                PurchHeader.Insert(true);

                                // Create Purchase Invoice Line
                                PurchLine.Init();
                                PurchLine."Document Type" := PurchHeader."Document Type";
                                PurchLine."Document No." := PurchHeader."No.";
                                PurchLine."Line No." := 10000;

                                PurchLine.Validate(Type, PurchLine.Type::Item);
                                PurchLine.Validate("No.", Item."No.");
                                PurchLine.Description := ProcessRec.PNR;
                                PurchLine.Validate(Quantity, ProcessRec."Total Pax");
                                PurchLine.Validate("Direct Unit Cost", ProcessRec.Rate);

                                // AIRIQ custom fields
                                PurchLine."Sample Purchase Date" := ProcessRec."Purchase Date";
                                PurchLine."Sample Entry Date" := ProcessRec."Entry Date";
                                PurchLine."Sample Travel Date" := ProcessRec."Travel Date";
                                PurchLine."Sample Airline" := ProcessRec.Airline;
                                PurchLine."Sample Sector" := ProcessRec.Sector;
                                PurchLine."Sample Flight Type" := ProcessRec.Type;
                                PurchLine."Sample Supplier ID" := ProcessRec."Supplier ID";
                                PurchLine."Sample Base Fare" := ProcessRec."Base Fare";
                                PurchLine."Sample Other Charges" := ProcessRec."Other Charges";

                                PurchLine.Insert(true);

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

                                CreatedCount += 1;

                                ProcessRec."Purchase Invoice No." := PurchHeader."No.";
                                ProcessRec.Modify(true);
                            end;
                        end;
                    end;
                end;
            until ProcessRec.Next() = 0;

        // Display Result Alerts
        if (CreatedCount > 0) and (DuplicateCount = 0) and (ErrorCount = 0) then
            Message('Success! %1 Purchase Invoice(s) created successfully.', CreatedCount)
        else if (CreatedCount = 0) and (DuplicateCount > 0) and (ErrorCount = 0) then
            Message('Already Invoiced! All %1 selected record(s) have already been invoiced.', DuplicateCount)
        else begin
            SummaryMsg := StrSubstNo(
                'Purchase Invoice Creation Summary:\- Created: %1\- Already Invoiced: %2\- Errors: %3',
                CreatedCount,
                DuplicateCount,
                ErrorCount);

            if ErrorCount > 0 then
                SummaryMsg += StrSubstNo('\Details:%1', ErrorDetails);

            Message(SummaryMsg);
        end;
    end;

    local procedure PNRInvoiceExists(
        PNR: Code[20];
        var ExistingInvoiceNo: Code[20]): Boolean
    var
        PurchLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        ExistingInvoiceNo := '';

        if PNR = '' then
            exit(false);

        // Check Open Purchase Invoices
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Invoice);
        PurchLine.SetRange(Description, PNR);

        if PurchLine.FindFirst() then begin
            ExistingInvoiceNo := PurchLine."Document No.";
            exit(true);
        end;

        // Check Posted Purchase Invoices
        PurchInvLine.Reset();
        PurchInvLine.SetRange(Description, PNR);

        if PurchInvLine.FindFirst() then begin
            ExistingInvoiceNo := PurchInvLine."Document No.";
            exit(true);
        end;

        exit(false);
    end;
}