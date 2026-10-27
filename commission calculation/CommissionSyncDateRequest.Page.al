
page 50454 "Commission Sync Date Request"
{
    PageType = StandardDialog;
    Caption = 'Choose Date to Date';

    layout
    {
        area(Content)
        {
            group(Options)
            {
                Caption = 'Posting Date Range';

                field(StartDate; StartDate)
                {
                    Caption = 'Start Date';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }

                field(EndDate; EndDate)
                {
                    Caption = 'End Date';
                    ApplicationArea = All;
                    ShowMandatory = true;
                }
            }
        }
    }

    var
        StartDate: Date;
        EndDate: Date;

    procedure GetStartDate(): Date
    begin
        exit(StartDate);
    end;

    procedure GetEndDate(): Date
    begin
        exit(EndDate);
    end;
}
