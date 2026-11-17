page 50740 "AIRIQ PLB Calculator"
{
    Caption = 'PLB Commission Calculator';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Tasks;
    Editable = true;

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
                begin
                    // Phase 2: use the submitted filters to read posted documents.
                    // This acknowledgement deliberately does not fabricate amounts.
                    if AddInIsReady then
                        CurrPage.PLBCalculator.SetPostedData(
                          '{"ok":false,"message":"Posted Purchase Invoice / Credit Memo mapping is not yet enabled. Use Manual totals in Phase 1."}');
                end;
            }
        }
    }

    var
        AddInIsReady: Boolean;
}
