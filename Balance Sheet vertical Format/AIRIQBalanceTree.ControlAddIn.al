
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

    // NEW: Ask JavaScript for currently visible rows
    procedure RequestExcelExportState();

    event AddInReady();

    // Existing ledger drill-down
    event NodeActivated(NodeId: Integer);

    // NEW: JavaScript returns the visible row IDs
    event ExcelExportStateReady(StateJson: Text);
}
