page 50749 "AIRIQ GST Period Dates"
{
    Caption = 'GST Period Dates';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    SourceTable = "Tax Accounting Period";
    SourceTableView = where("Tax Type Code" = const('GST'));
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Periods)
            {
                field("Tax Type Code"; Rec."Tax Type Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the tax type for the accounting period.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the beginning of the accounting period.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the end of the accounting period.';
                }
                field("Financial Year"; Rec."Financial Year")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the financial year.';
                }
                field("Credit Memo Locking Date"; Rec."Credit Memo Locking Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the credit memo locking date for the period.';
                }
                field("Annual Return Filed Date"; Rec."Annual Return Filed Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the annual return filed date for the period.';
                }
            }
        }
    }
}