page 50315 "Sample Purchase Date Dialog"
{
    PageType = StandardDialog;
    Caption = 'Entry Date Selection';
    ApplicationArea = All;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(DateRangeGroup)
            {
                Caption = 'Entry Date Range';

                field(FromEntryDateField; FromEntryDate)
                {
                    ApplicationArea = All;
                    Caption = 'From Entry Date';
                    ToolTip = 'Specifies the starting entry date.';

                    trigger OnValidate()
                    begin
                        if (ToEntryDate <> 0D) and (FromEntryDate > ToEntryDate) then
                            Error('From Entry Date cannot be later than To Entry Date.');
                    end;
                }

                field(ToEntryDateField; ToEntryDate)
                {
                    ApplicationArea = All;
                    Caption = 'To Entry Date';
                    ToolTip = 'Specifies the ending entry date.';

                    trigger OnValidate()
                    begin
                        if (FromEntryDate <> 0D) and (ToEntryDate < FromEntryDate) then
                            Error('To Entry Date cannot be earlier than From Entry Date.');
                    end;
                }
            }
        }
    }

    var
        FromEntryDate: Date;
        ToEntryDate: Date;

    procedure SetDates(NewFromDate: Date; NewToDate: Date)
    begin
        FromEntryDate := NewFromDate;
        ToEntryDate := NewToDate;
    end;

    procedure GetDates(var OutFromDate: Date; var OutToDate: Date)
    begin
        OutFromDate := FromEntryDate;
        OutToDate := ToEntryDate;
    end;

    trigger OnOpenPage()
    begin
        if FromEntryDate = 0D then
            FromEntryDate := Today;
        if ToEntryDate = 0D then
            ToEntryDate := Today;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [Action::OK, Action::LookupOK] then begin
            if FromEntryDate = 0D then
                Error('Please select a valid From Entry Date.');
            if ToEntryDate = 0D then
                Error('Please select a valid To Entry Date.');
            if FromEntryDate > ToEntryDate then
                Error('From Entry Date cannot be later than To Entry Date.');
        end;
    end;
}
