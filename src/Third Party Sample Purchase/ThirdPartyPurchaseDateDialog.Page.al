page 50666 "TP Purchase Date Dialog"
{
    Caption = 'Entry Date Selection';
    PageType = StandardDialog;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(DateRange)
            {
                Caption = 'Entry Date Range';
                field(FromDateField; FromDate) { ApplicationArea = All; Caption = 'From Entry Date'; }
                field(ToDateField; ToDate) { ApplicationArea = All; Caption = 'To Entry Date'; }
            }
        }
    }
    var
        FromDate: Date;
        ToDate: Date;

    trigger OnOpenPage()
    begin
        if FromDate = 0D then FromDate := Today;
        if ToDate = 0D then ToDate := Today;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then
            if (FromDate = 0D) or (ToDate = 0D) or (FromDate > ToDate) then
                Error('Enter a valid Entry Date range.');
    end;

    procedure GetDates(var StartDate: Date; var EndDate: Date)
    begin
        StartDate := FromDate;
        EndDate := ToDate;
    end;
}
