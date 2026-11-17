controladdin "AIRIQ PLB Calculator AddIn"
{
    Scripts = 'PLBCalculatorAddIn/main.js';
    StartupScript = 'PLBCalculatorAddIn/startup.js';
    StyleSheets = 'PLBCalculatorAddIn/styles.css';

    RequestedHeight = 1600;
    MinimumHeight = 1100;
    MaximumHeight = 2000;
    HorizontalStretch = true;
    VerticalStretch = false;

    event AddInReady();

    // Reserved for the next phase: request BC posted document totals.
    event PostedDataRequested(FilterJson: Text);
    procedure SetPostedData(DataJson: Text);
}
