page 50411 "API Sales Format List"
{
    Caption = 'API Sales Format';
    PageType = List;
    SourceTable = "API Sales Format";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Date"; Rec."Date")
                {
                    ApplicationArea = All;
                }

                field("Invoice Number"; Rec."Invoice Number")
                {
                    ApplicationArea = All;
                }

                field("Agency ID"; Rec."Agency ID")
                {
                    ApplicationArea = All;
                }

                field("Agency Name"; Rec."Agency Name")
                {
                    ApplicationArea = All;
                }

                field("Ref No./AQ Number"; Rec."Ref No./AQ Number")
                {
                    ApplicationArea = All;
                }

                field(PNR; Rec.PNR)
                {
                    ApplicationArea = All;
                }

                field(Passenger; Rec.Passenger)
                {
                    ApplicationArea = All;
                }

                field(Pax; Rec.Pax)
                {
                    ApplicationArea = All;
                }

                field("Travel Date"; Rec."Travel Date")
                {
                    ApplicationArea = All;
                }

                field(Sector; Rec.Sector)
                {
                    ApplicationArea = All;
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }

                field("Base Fare"; Rec."Base Fare")
                {
                    ApplicationArea = All;
                }

                field("Other Charges"; Rec."Other Charges")
                {
                    ApplicationArea = All;
                }

                field("Taxable Basis"; Rec."Taxable Basis")
                {
                    ApplicationArea = All;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        APISalesFormat: Record "API Sales Format";
    begin
        APISalesFormat.Reset();
        if APISalesFormat.FindLast() then
            if APISalesFormat."Entry No." >= 1 then
                Rec."Entry No." := APISalesFormat."Entry No." + 1
            else
                Rec."Entry No." := 1
        else
            Rec."Entry No." := 1;
    end;
}