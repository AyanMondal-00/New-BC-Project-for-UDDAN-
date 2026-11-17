
page 50545 "AIRIQ Cost Revision Editor"
{
    Caption = 'Edit Cost Revision';
    PageType = Card;
    SourceTable = "Sample Purchase";
    SourceTableTemporary = true;
    ApplicationArea = All;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;

    layout
    {
        area(content)
        {
            group(Reference)
            {
                Caption = 'Purchase Reference';

                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Supplier ID"; Rec."Supplier ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Airline; Rec.Airline)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }

            group(Financial)
            {
                Caption = 'Financial Values';

                field("Total Pax"; Rec."Total Pax")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                    Editable = true;

                    trigger OnValidate()
                    begin
                        RecalculateFromBaseFare();
                        CurrPage.Update(false);
                    end;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(Rate; Rec.Rate)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveAndComplete)
            {
                Caption = 'Save & Complete Revision';
                ApplicationArea = All;
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    // Saves only the temporary record.
                    CurrPage.SaveRecord();

                    RecalculateFromBaseFare();

                    Rec.TestField(PNR);

                    if (Rec."Total Pax" <= 0) or
                       (Rec."Total Amount" <= 0) or
                       (Rec.Rate <= 0) or
                       (Rec."Base Fare" < 0) then
                        Error(
                            'Enter positive Pax, Total Amount and Rate, and nonnegative Base Fare.');

                    Confirmed := true;
                    CurrPage.Close();
                end;
            }

            action(CancelRevision)
            {
                Caption = 'Cancel';
                ApplicationArea = All;
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Confirmed := false;
                    CurrPage.Close();
                end;
            }
        }
    }

    var
        Confirmed: Boolean;
        OriginalOtherCharges: Decimal;
        OriginalPax: Integer;

    local procedure RecalculateFromBaseFare()
    begin
        if OriginalPax <= 0 then
            Error(
                'Total Pax must be greater than zero before revising Base Fare.');

        if Rec."Base Fare" < 0 then
            Error('Base Fare cannot be negative.');

        // Preserve the original per-passenger Other Charges.
        Rec."Other Charges" := OriginalOtherCharges;

        // New Rate = New Base Fare + Original Other Charges.
        Rec.Rate := Rec."Base Fare" + OriginalOtherCharges;

        // New Total Amount = New Rate * Original Pax.
        Rec."Total Amount" := Rec.Rate * OriginalPax;

        // Pax remains unchanged.
        Rec."Total Pax" := OriginalPax;
    end;

    procedure LoadPurchase(Purchase: Record "Sample Purchase")
    begin
        Rec.Init();
        Rec := Purchase;

        OriginalOtherCharges := Purchase."Other Charges";
        OriginalPax := Purchase."Total Pax";

        Rec.Insert(false);
        Confirmed := false;
    end;

    procedure GetCompletedPurchase(
        var Purchase: Record "Sample Purchase"): Boolean
    begin
        if not Confirmed then
            exit(false);

        if not Rec.FindFirst() then
            exit(false);

        Purchase := Rec;
        exit(true);
    end;
}
