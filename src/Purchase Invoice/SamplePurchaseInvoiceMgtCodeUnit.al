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
    begin
        SamplePurchase.SetRange("Create Purchase Invoice", true);
        SamplePurchase.SetRange("Purchase Invoice Created", false);

        if SamplePurchase.FindSet() then
            repeat
                Vendor.Reset();
                Vendor.SetRange(Name, SamplePurchase.Airline);

                if not Vendor.FindFirst() then
                    Error(
                        'Vendor not found for Airline %1.',
                        SamplePurchase.Airline);

                Item.Reset();
                Item.SetRange(Description, SamplePurchase.PNR);

                if not Item.FindFirst() then
                    Error(
                        'Item not found for PNR %1. Please create Items first.',
                        SamplePurchase.PNR);

                PurchHeader.Init();
                PurchHeader."Document Type" := PurchHeader."Document Type"::Invoice;
                PurchHeader.Insert(true);

                PurchHeader.Validate("Buy-from Vendor No.", Vendor."No.");
                PurchHeader.Validate("Vendor Invoice No.",AIRIQInvoiceNoMgt.GetNextInvoiceNo());
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

                SamplePurchase."Purchase Invoice Created" := true;
                SamplePurchase."Purchase Invoice No." := PurchHeader."No.";
                SamplePurchase.Modify(true);
            until SamplePurchase.Next() = 0;
    end;
}