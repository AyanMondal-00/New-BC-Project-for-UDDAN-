controladdin "AIRIQ P&L Tree AddIn"
{
    Scripts = 'PLControlAddIn/main.js';
    StartupScript = 'PLControlAddIn/startup.js';
    StyleSheets = 'PLControlAddIn/styles.css';

    RequestedHeight = 580;
    MinimumHeight = 360;
    MaximumHeight = 1000;
    HorizontalStretch = true;
    VerticalStretch = true;

    procedure SetPLData(Payload: Text);

    event AddInReady();
    event NodeActivated(NodeId: Integer);
}
