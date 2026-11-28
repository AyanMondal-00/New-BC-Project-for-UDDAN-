pageextension 50720 "AIRIQ Posted SR Memo Page"
    extends "Posted Sales Credit Memo"
{
    layout
    {
        addafter(General)
        {
            group(AIRIQReturn)
            {
                Caption = 'AIRIQ Sales Return Details';

                field("AIRIQ Return No."; Rec."AIRIQ Return No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip =
                        'Specifies the Sales Return number from which this posted credit memo was created.';
                }

                field("AIRIQ Return Serial"; Rec."AIRIQ Return Serial")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ API Return Serial"; Rec."AIRIQ API Return Serial")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("AIRIQ TP Return Serial"; Rec."AIRIQ TP Return Serial")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("AIRIQ Bill No."; Rec."AIRIQ Bill No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ Original Invoice"; Rec."AIRIQ Original Invoice")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip =
                        'Specifies the original posted Sales Invoice number.';
                }

                field("AIRIQ Entry Date"; Rec."AIRIQ Entry Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ Reference"; Rec."AIRIQ Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ Narration"; Rec."AIRIQ Narration")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ Supplier"; Rec."AIRIQ Supplier")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("AIRIQ Sale Type"; Rec."AIRIQ Sale Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }
}


pageextension 50721 "AIRIQ Posted SR Memo Lines"
    extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
            field("AIRIQ Rate"; Rec."AIRIQ Rate")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Specifies the original Third Party per-passenger rate.';
            }
            field("Passenger Name"; Rec."Passenger Name")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Passenger Type"; Rec."AIRIQ Passenger Type")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Travel Date"; Rec."Travel Date")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(Sector; Rec.Sector)
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(FlightType; Rec.FlightType)
            {
                ApplicationArea = All;
                Editable = false;
            }

            field(BaseFare; Rec.BaseFare)
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("Other Charges"; Rec."Other Charges")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Taxable Value"; Rec."AIRIQ Taxable Value")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Source CGST"; Rec."AIRIQ Source CGST")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Source SGST"; Rec."AIRIQ Source SGST")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Source IGST"; Rec."AIRIQ Source IGST")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Sold Value"; Rec."AIRIQ Sold Value")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ XXLN Charges"; Rec."AIRIQ XXLN Charges")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Refund Amount"; Rec."AIRIQ Refund Amount")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Country"; Rec."AIRIQ Country")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ State"; Rec."AIRIQ State")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ City"; Rec."AIRIQ City")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Travel Time"; Rec."AIRIQ Travel Time")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Airline"; Rec."AIRIQ Airline")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Airline Code"; Rec."AIRIQ Airline Code")
            {
                ApplicationArea = All;
                Editable = false;
            }

            field("AIRIQ Reference"; Rec."AIRIQ Reference")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }
}