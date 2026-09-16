codeunit 50336 "Sample Purchase Invoice Mngt"
{
    procedure CreatePurchaseInvoices()
    var
        SamplePurchase: Record "Sample Purchase";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Vendor: Record Vendor;
        Item: Record Item;
        AIRIQInvoiceNoMgt: Codeunit "AIRIQ Invoice No. Mgt";
        CreatedCount: Integer;
        DuplicateCount: Integer;
        ErrorCount: Integer;
        ErrorMessages: Text;
        ExistingInvoiceNo: Code[20];
    begin
        SamplePurchase.SetRange("Select", true);

        if not SamplePurchase.FindSet() then begin
            Message('No Sample Purchase records selected.');
            exit;
        end;

        repeat
            // Strong PNR duplicate check.
            if PNRInvoiceExists(
                SamplePurchase.PNR,
                ExistingInvoiceNo)
            then begin

                DuplicateCount += 1;

                SamplePurchase."Select" := false;
                
                SamplePurchase."Purchase Invoice No." := ExistingInvoiceNo;
                SamplePurchase.Modify(true);

            end else begin

                // Vendor check.
                Vendor.Reset();
                Vendor.SetRange(Name, SamplePurchase.Airline);

                if not Vendor.FindFirst() then begin
                    ErrorCount += 1;

                    ErrorMessages += StrSubstNo(
                        'Serial No. %1: Vendor not found for Airline %2.\',
                        SamplePurchase."Serial No.",
                        SamplePurchase.Airline);

                end else begin

                    // Item check.
                    Item.Reset();
                    Item.SetRange(
                        Description,
                        SamplePurchase.PNR);

                    if not Item.FindFirst() then begin
                        ErrorCount += 1;

                        ErrorMessages += StrSubstNo(
                            'Serial No. %1: Item not found for PNR %2.\',
                            SamplePurchase."Serial No.",
                            SamplePurchase.PNR);

                    end else begin

                        // Create Purchase Invoice Header.
                        PurchHeader.Init();

                        PurchHeader."Document Type" :=
                            PurchHeader."Document Type"::Invoice;

                        PurchHeader.Insert(true);

                        PurchHeader.Validate(
                            "Buy-from Vendor No.",
                            Vendor."No.");

                        PurchHeader.Validate(
                            "Vendor Invoice No.",
                            AIRIQInvoiceNoMgt.GetNextInvoiceNo());

                        PurchHeader.Modify(true);

                        // Create Purchase Invoice Line.
                        PurchLine.Init();

                        PurchLine."Document Type" :=
                            PurchLine."Document Type"::Invoice;

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
                            SamplePurchase.PNR;

                        PurchLine.Validate(
                            Quantity,
                            SamplePurchase."Total Pax");

                        PurchLine.Validate(
                            "Direct Unit Cost",
                            SamplePurchase.Rate);

                        // AIRIQ custom fields.
                        PurchLine."Sample Purchase Date" :=
                            SamplePurchase."Purchase Date";

                        PurchLine."Sample Entry Date" :=
                            SamplePurchase."Entry Date";

                        PurchLine."Sample Travel Date" :=
                            SamplePurchase."Travel Date";

                        PurchLine."Sample Airline" :=
                            SamplePurchase.Airline;

                        PurchLine."Sample Sector" :=
                            SamplePurchase.Sector;

                        PurchLine."Sample Flight Type" :=
                            SamplePurchase.Type;

                        PurchLine."Sample Supplier ID" :=
                            SamplePurchase."Supplier ID";

                        PurchLine."Sample Base Fare" :=
                            SamplePurchase."Base Fare";

                        PurchLine."Sample Other Charges" :=
                            SamplePurchase."Other Charges";

                        PurchLine.Insert(true);

                        PurchLine.Get(
                            PurchLine."Document Type",
                            PurchLine."Document No.",
                            PurchLine."Line No.");

                        // Total = Qty × Rate + Other Charges.
                        PurchLine.Validate(
                            "Line Amount",
                            (SamplePurchase."Total Pax" *
                            SamplePurchase.Rate) +
                            SamplePurchase."Other Charges");

                        PurchLine.Modify(true);

                        // Mark Sample Purchase as invoiced.
                        SamplePurchase."Select" := false;
                  
                        SamplePurchase."Purchase Invoice No." :=
                            PurchHeader."No.";

                        SamplePurchase.Modify(true);

                        CreatedCount += 1;
                    end;
                end;
            end;

        until SamplePurchase.Next() = 0;

        // Result message.
        if (CreatedCount > 0) and
           (DuplicateCount = 0) and
           (ErrorCount = 0)
        then begin

            Message(
                'Success! %1 Purchase Invoice(s) created successfully.',
                CreatedCount);

        end else begin

            ErrorMessages :=
                StrSubstNo(
                    'Purchase Invoice Creation Summary:\Created: %1\Already Invoiced: %2\Errors: %3',
                    CreatedCount,
                    DuplicateCount,
                    ErrorCount);

            if ErrorCount > 0 then
                ErrorMessages +=
                    StrSubstNo(
                        '\Details:\%1',
                        ErrorMessages);

            Message(ErrorMessages);
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

        // Check Open Purchase Invoices.
        PurchLine.Reset();

        PurchLine.SetRange(
            "Document Type",
            PurchLine."Document Type"::Invoice);

        PurchLine.SetRange(
            Description,
            PNR);

        if PurchLine.FindFirst() then begin
            ExistingInvoiceNo := PurchLine."Document No.";
            exit(true);
        end;

        // Check Posted Purchase Invoices.
        PurchInvLine.Reset();

        PurchInvLine.SetRange(
            Description,
            PNR);

        if PurchInvLine.FindFirst() then begin
            ExistingInvoiceNo := PurchInvLine."Document No.";
            exit(true);
        end;

        exit(false);
    end;
}