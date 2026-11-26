page 50744 "AIRIQ Excel Validation Errors"
{
    Caption = 'Excel Import Validation Errors';
    PageType = List;
    SourceTable = "AIRIQ Excel Validation Buffer";
    SourceTableTemporary = true;
    SourceTableView = sorting("Excel Row No.", "Excel Column No.", "Passenger No.");
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(Summary)
            {
                Caption = 'Import blocked - correct errors and upload again';
                field(Module; ModuleName) { ApplicationArea = All; Caption = 'Module'; }
                field(SourceFile; SourceFileName) { ApplicationArea = All; Caption = 'File'; }
                field(SourceSheet; SourceSheetName) { ApplicationArea = All; Caption = 'Source Sheet'; }
                field(CheckedRows; CheckedRowCount) { ApplicationArea = All; Caption = 'Data Rows Checked'; }
                field(ValidRows; ValidRowCount) { ApplicationArea = All; Caption = 'Valid Rows'; }
                field(InvalidRows; InvalidRowCount) { ApplicationArea = All; Caption = 'Invalid Data Rows'; }
                field(Errors; ErrorCount) { ApplicationArea = All; Caption = 'Total Errors'; Style = Unfavorable; }
                field(ImportedRows; ImportedRowCount) { ApplicationArea = All; Caption = 'Imported Records'; }
            }
            repeater(ValidationErrors)
            {
                field("Excel Row No."; Rec."Excel Row No.") { ApplicationArea = All; }
                field("Cell Reference"; Rec."Cell Reference") { ApplicationArea = All; }
                field(PNR; Rec.PNR) { ApplicationArea = All; }
                field("Passenger No."; Rec."Passenger No.") { ApplicationArea = All; BlankZero = true; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; }
                field("Current Value"; Rec."Current Value") { ApplicationArea = All; }
                field("Error Reason"; Rec."Error Reason") { ApplicationArea = All; Style = Unfavorable; }
                field("Correction Required"; Rec."Correction Required") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(SeeInExcel)
            {
                Caption = 'See in Excel';
                ApplicationArea = All;
                Image = ExportToExcel;
                ToolTip = 'Download all validation errors and a copy of the selected data sheet.';
                trigger OnAction()
                var
                    Validation: Codeunit "AIRIQ Excel Validation Mgt.";
                begin
                    Validation.DownloadReport(Rec, SourceExcel, ModuleName, SourceFileName, SourceSheetName, CheckedRowCount, InvalidRowCount);
                end;
            }
        }
        area(Promoted)
        {
            actionref(SeeInExcel_Promoted; SeeInExcel) { }
        }
    }

    var
        SourceExcel: Record "Excel Buffer" temporary;
        ModuleName: Text;
        SourceFileName: Text;
        SourceSheetName: Text;
        CheckedRowCount: Integer;
        ValidRowCount: Integer;
        InvalidRowCount: Integer;
        ErrorCount: Integer;
        ImportedRowCount: Integer;

    procedure SetData(var Errors: Record "AIRIQ Excel Validation Buffer" temporary; var Excel: Record "Excel Buffer" temporary; ImportModule: Text; FileName: Text; SheetName: Text; Checked: Integer; Invalid: Integer)
    begin
        Rec.Copy(Errors, true);
        Rec.Reset();
        SourceExcel.Copy(Excel, true);
        SourceExcel.Reset();
        ModuleName := ImportModule;
        SourceFileName := FileName;
        SourceSheetName := SheetName;
        CheckedRowCount := Checked;
        InvalidRowCount := Invalid;
        ValidRowCount := Checked - Invalid;
        ErrorCount := Rec.Count();
        ImportedRowCount := 0;
    end;
}
