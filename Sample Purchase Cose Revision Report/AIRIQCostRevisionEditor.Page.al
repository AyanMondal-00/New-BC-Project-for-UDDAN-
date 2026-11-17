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
                field("Serial No."; Rec."Serial No.") { ApplicationArea = All; Editable = false; }
                field(PNR; Rec.PNR) { ApplicationArea = All; Editable = false; }
                field("Supplier ID"; Rec."Supplier ID") { ApplicationArea = All; Editable = false; }
                field(Airline; Rec.Airline) { ApplicationArea = All; Editable = false; }
            }
            group(Financial)
            {
                Caption = 'Financial Values';
                field("Total Pax"; Rec."Total Pax") { ApplicationArea = All; }
                field("Base Fare"; Rec."Base Fare") { ApplicationArea = All; }
                field("Total Amount"; Rec."Total Amount") { ApplicationArea = All; }
                field(Rate; Rec.Rate) { ApplicationArea = All; }
                field("Other Charges"; Rec."Other Charges") { ApplicationArea = All; Editable = false; }
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
                    CurrPage.SaveRecord(); // Saves TEMPORARY row only.
                    Rec.TestField(PNR);
                    if (Rec."Total Pax" <= 0) or (Rec."Total Amount" <= 0) or
                       (Rec.Rate <= 0) or (Rec."Base Fare" < 0) then
                        Error('Enter positive Pax, Total Amount and Rate, and nonnegative Base Fare.');
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

    procedure LoadPurchase(Purchase: Record "Sample Purchase")
    begin
        Rec.Init();
        Rec := Purchase;
        Rec.Insert(false);
        Confirmed := false;
    end;

    procedure GetCompletedPurchase(var Purchase: Record "Sample Purchase"): Boolean
    begin
        if not Confirmed then
            exit(false);
        if not Rec.FindFirst() then
            exit(false);
        Purchase := Rec;
        exit(true);
    end;
}
