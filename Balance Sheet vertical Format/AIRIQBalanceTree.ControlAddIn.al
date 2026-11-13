controladdin "AIRIQ Balance Tree AddIn"
{
    Scripts = 'ControlAddIn/main.js';
    StartupScript = 'ControlAddIn/startup.js';
    StyleSheets = 'ControlAddIn/styles.css';

    RequestedHeight = 580;
    MinimumHeight = 360;
    MaximumHeight = 1000;
    HorizontalStretch = true;
    VerticalStretch = true;

    procedure SetBalanceSheetData(Payload: Text);

    event AddInReady();
    event NodeActivated(NodeId: Integer);
}
