page 50740 "AIRIQ PLB Calculator"
{
    Caption = 'PLB Commission Calculator';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            usercontrol(PLBCalculator; "AIRIQ PLB Calculator AddIn")
            {
                ApplicationArea = All;

                trigger AddInReady()
                begin
                    AddInIsReady := true;
                end;

                trigger PostedDataRequested(FilterJson: Text)
                var
                    Mapper: Codeunit "AIRIQ PLB Posted Mapping";
                    ResponseJson: Text;
                begin
                    // Read-only test: no PLB record insertion.
                    ResponseJson := Mapper.Fetch(FilterJson);
                    if AddInIsReady then
                        CurrPage.PLBCalculator.SetPostedData(ResponseJson);
                end;
            }
        }
    }

    var
        AddInIsReady: Boolean;
}
