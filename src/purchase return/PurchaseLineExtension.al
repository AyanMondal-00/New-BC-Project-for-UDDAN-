tableextension 50421 "Purchase Line Extension" extends "Purchase Line"
{
    fields
    {
        field(50421; "Other Charges"; Decimal)
        {
            Caption = 'Other Charges';
            DataClassification = CustomerContent;
        }

        field(50422; "CGST Amount"; Decimal)
        {
            Caption = 'CGST Amount';
            DataClassification = CustomerContent;
        }

        field(50423; "SGST Amount"; Decimal)
        {
            Caption = 'SGST Amount';
            DataClassification = CustomerContent;
        }

        field(50424; "IGST Amount"; Decimal)
        {
            Caption = 'IGST Amount';
            DataClassification = CustomerContent;
        }

        field(50425; "Taxable Basis"; Decimal)
        {
            Caption = 'Taxable Basis';
            DataClassification = CustomerContent;
        }

        field(50426; "Total Amount"; Decimal)
        {
            Caption = 'Total Amount';
            DataClassification = CustomerContent;
        }
    }
}