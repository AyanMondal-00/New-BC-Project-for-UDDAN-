page 50410 "Normal Sales List"
{
    Caption = 'Normal Sales';
    PageType = List;
    SourceTable = "Normal Sales";
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

                field("Supplier ID"; Rec."Supplier ID")
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
                    Editable = false;
                }

                field(CGST; Rec.CGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(SGST; Rec.SGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field(IGST; Rec.IGST)
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        NormalSales: Record "Normal Sales";
    begin
        NormalSales.Reset();
        if NormalSales.FindLast() then
            if NormalSales."Entry No." >= 1 then
                Rec."Entry No." := NormalSales."Entry No." + 1
            else
                Rec."Entry No." := 1
        else
            Rec."Entry No." := 1;
    end;
}