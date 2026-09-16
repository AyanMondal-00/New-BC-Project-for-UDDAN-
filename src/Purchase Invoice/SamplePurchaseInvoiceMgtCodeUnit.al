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
        ErrorCount: Integer;
        ErrorMessages: Text;
    begin
        SamplePurchase.SetRange("Select", true);
        SamplePurchase.SetRange("Select", true);

        if SamplePurchase.FindSet() then
            repeat
                Vendor.Reset();
                Vendor.SetRange(Name, SamplePurchase.Airline);

                if not Vendor.FindFirst() then begin
                    ErrorCount += 1;
                    ErrorMessages += StrSubstNo(
                        'Serial No. %1: Vendor not found for Airline %2.\',
                        SamplePurchase."Serial No.",
                        SamplePurchase.Airline);
                end else begin

                    Item.Reset();
                    Item.SetRange(Description, SamplePurchase.PNR);

                    if not Item.FindFirst() then begin
                        ErrorCount += 1;
                        ErrorMessages += StrSubstNo(
                            'Serial No. %1: Item not found for PNR %2.',
                            SamplePurchase."Serial No.",
                            SamplePurchase.PNR);
                    end else begin

                        PurchHeader.Init();
                        PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
                        PurchHeader.Insert(true);

                        PurchHeader.Validate("Buy-from Vendor No.", Vendor."No.");
                        PurchHeader.Validate(
                            "Vendor Invoice No.",
                            AIRIQInvoiceNoMgt.GetNextInvoiceNo());
                        PurchHeader.Modify(true);

                        PurchLine.Init();
                        PurchLine."Document Type" := PurchLine."Document Type"::Invoice;
                        PurchLine."Document No." := PurchHeader."No.";
                        PurchLine."Line No." := 10000;

                        PurchLine.Validate(Type, PurchLine.Type::Item);
                        PurchLine.Validate("No.", Item."No.");
                        PurchLine.Description := SamplePurchase.PNR;
                        PurchLine.Validate(Quantity, SamplePurchase."Total Pax");
                        PurchLine.Validate("Direct Unit Cost", SamplePurchase.Rate);

                        PurchLine."Sample Purchase Date" := SamplePurchase."Purchase Date";
                        PurchLine."Sample Entry Date" := SamplePurchase."Entry Date";
                        PurchLine."Sample Travel Date" := SamplePurchase."Travel Date";
                        PurchLine."Sample Airline" := SamplePurchase.Airline;
                        PurchLine."Sample Sector" := SamplePurchase.Sector;
                        PurchLine."Sample Flight Type" := SamplePurchase.Type;
                        PurchLine."Sample Supplier ID" := SamplePurchase."Supplier ID";
                        PurchLine."Sample Base Fare" := SamplePurchase."Base Fare";
                        PurchLine."Sample Other Charges" := SamplePurchase."Other Charges";

                        PurchLine.Insert(true);

                        PurchLine.Get(
                            PurchLine."Document Type",
                            PurchLine."Document No.",
                            PurchLine."Line No.");

                        PurchLine.Validate(
                            "Line Amount",
                            (SamplePurchase."Total Pax" * SamplePurchase.Rate) +
                            SamplePurchase."Other Charges");

                        PurchLine.Modify(true);

                        CreatedCount += 1;

                        SamplePurchase."Select" := false;
                        SamplePurchase.Modify(true);
                    end;
                end;
            until SamplePurchase.Next() = 0;

        if (CreatedCount > 0) and (ErrorCount = 0) then
            Message(
                'Success! %1 Purchase Invoice(s) created.',
                CreatedCount)
        else
            if (CreatedCount > 0) and (ErrorCount > 0) then
                Message(
                    '%1 Purchase Invoice(s) created successfully.\%2 record(s) could not be processed:\%3',
                    CreatedCount,
                    ErrorCount,
                    ErrorMessages)
            else
                if ErrorCount > 0 then
                    Message(
                        'No Purchase Invoices were created.\%1 record(s) could not be processed:\%2',
                        ErrorCount,
                        ErrorMessages)
                else
                    Message('No new Purchase Invoices were created.');
    end;
}