page 50417 "Choose Date to Date"
{
    PageType = StandardDialog;
    Caption = 'Choose Date to Date';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(DateRange)
            {
                Caption = 'Select Date Range';

                field(FromDateField; FromDate)
                {
                    ApplicationArea = All;
                    Caption = 'From Date';
                    ToolTip = 'Specifies the starting date for importing sales data.';

                    trigger OnValidate()
                    begin
                        if (ToDate <> 0D) and (FromDate > ToDate) then
                            Error('From Date cannot be later than To Date.');
                    end;
                }

                field(ToDateField; ToDate)
                {
                    ApplicationArea = All;
                    Caption = 'To Date';
                    ToolTip = 'Specifies the ending date for importing sales data.';

                    trigger OnValidate()
                    begin
                        if (FromDate <> 0D) and (ToDate < FromDate) then
                            Error('To Date cannot be earlier than From Date.');
                    end;
                }
            }
        }
    }

    var
        FromDate: Date;
        ToDate: Date;

    procedure SetDates(NewFromDate: Date; NewToDate: Date)
    begin
        FromDate := NewFromDate;
        ToDate := NewToDate;
    end;

    procedure GetDates(var OutFromDate: Date; var OutToDate: Date)
    begin
        OutFromDate := FromDate;
        OutToDate := ToDate;
    end;

    trigger OnOpenPage()
    begin
        if FromDate = 0D then
            FromDate := Today;
        if ToDate = 0D then
            ToDate := Today;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then begin
            if FromDate = 0D then
                Error('Please select a valid From Date.');
            if ToDate = 0D then
                Error('Please select a valid To Date.');
            if FromDate > ToDate then
                Error('From Date cannot be later than To Date.');
        end;
    end;
}
