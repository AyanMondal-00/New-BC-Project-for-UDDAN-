page 50425 "MLB"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "MLB";
    Caption = 'MLB';
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Serial No. (auto-incremented).';
                }

                field("AirLine"; Rec."AirLine")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Airline.';
                }

                field("AirLine ID"; Rec."AirLine ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Airline ID.';
                }

                field("Commission Basis"; Rec."Commission Basis")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Commission Basis (Booking Date / Travel Date).';
                }

                field("Calculation Base"; Rec."Calculation Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Calculation Base.';
                }

                field("Commission %"; Rec."Commission %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Commission Percentage.';
                }

                field("TDS % on Commission"; Rec."TDS % on Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the TDS % on Commission.';
                }

                field("GST %"; Rec."GST %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the GST % (Fixed at 18%, not editable).';
                }

                field("Our State"; Rec."Our State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Our State.';
                }

                field("AirLine State"; Rec."AirLine State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Airline State.';
                }

                field("GST Type"; Rec."GST Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies GST Type.';
                }
                field("Rule Period Booking date From"; Rec."Rule Period Booking date From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Rule Period Booking date From.';
                }
                field("Rule Period Booking date To"; Rec."Rule Period Booking date To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Rule Period Booking date To.';
                }

                field("Amount From"; Rec."Amount From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Amount From.';
                }

                field("Transaction"; Rec."Transaction")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Transaction type.';
                }

                field("PNR / Ticket"; Rec."PNR / Ticket")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the PNR or Ticket number.';
                }

                field("Purchase Base Fare"; Rec."Purchase Base Fare")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Base Fare.';
                }

                field("Purchase Other Charges"; Rec."Purchase Other Charges")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Other Charges.';
                }

                field("Purchase Total"; Rec."Purchase Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Total.';
                }

                field("Purchase Commission"; Rec."Purchase Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Purchase Commission.';
                }

                field("Total Commission"; Rec."Total Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Total Commission.';
                }

                field("GST Percentage"; Rec."GST Percentage")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the GST Percentage (Fixed at 18%).';
                }

                field("Invoice Incl. GST"; Rec."Invoice Incl. GST")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Invoice Amount Including GST.';
                }

                field("TDS (2.00%) on Commission"; Rec."TDS (2.00%) on Commission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies TDS on Commission.';
                }

                field("Net Receivable"; Rec."Net Receivable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Net Receivable amount.';
                }

                field("Received On"; Rec."Received On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Date and Time received.';
                }

                field("Received In (Bank/ID)"; Rec."Received In (Bank/ID)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Bank or Account ID where received.';
                }
            }
        }
    }


}
