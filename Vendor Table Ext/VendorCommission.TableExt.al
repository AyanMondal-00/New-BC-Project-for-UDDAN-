
tableextension 50350 "Vendor Commission Ext" extends Vendor
{
    fields
    {


        field(50351; "PLB"; Decimal)
        {
            Caption = 'PLB';
            DataClassification = CustomerContent;
        }

        field(50352; "MLB"; Decimal)
        {
            Caption = 'MLB';
            DataClassification = CustomerContent;
        }

        field(50353; "Annual PLB"; Decimal)
        {
            Caption = 'Annual PLB';
            DataClassification = CustomerContent;
        }

        field(50354; "Target Incentive"; Decimal)
        {
            Caption = 'Target Incentive';
            DataClassification = CustomerContent;
        }

        field(50355; "Cashback"; Decimal)
        {
            Caption = 'Cashback';
            DataClassification = CustomerContent;
        }

        field(50356; "CMF/TFEE"; Decimal)
        {
            Caption = 'CMF/TFEE';
            DataClassification = CustomerContent;
        }
    }
}
