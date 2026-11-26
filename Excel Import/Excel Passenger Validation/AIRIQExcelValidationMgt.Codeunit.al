codeunit 50743 "AIRIQ Excel Validation Mgt."
{
    var
        Errors: Record "AIRIQ Excel Validation Buffer" temporary;
        InvalidRows: Dictionary of [Integer, Boolean];
        CheckedRows: Integer;
        EntryNo: Integer;

    procedure Initialize()
    begin
        Errors.Reset();
        Errors.DeleteAll();
        Clear(InvalidRows);
        CheckedRows := 0;
        EntryNo := 0;
    end;

    procedure HasErrors(): Boolean
    begin
        Errors.Reset();
        exit(not Errors.IsEmpty());
    end;

    procedure ReadCell(var Excel: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    begin
        if ColNo <= 0 then
            exit('');
        Excel.Reset();
        if Excel.Get(RowNo, ColNo) then
            exit(Excel."Cell Value as Text");
        exit('');
    end;

    procedure AddIssue(RowNo: Integer; ColNo: Integer; PNRValue: Text; PassengerNo: Integer; FieldName: Text; CurrentValue: Text; Reason: Text; Correction: Text)
    begin
        EntryNo += 1;
        Errors.Init();
        Errors."Entry No." := EntryNo;
        Errors."Excel Row No." := RowNo;
        Errors."Excel Column No." := ColNo;
        if ColNo > 0 then
            Errors."Cell Reference" := CopyStr(CellAddress(RowNo, ColNo), 1, MaxStrLen(Errors."Cell Reference"));
        Errors.PNR := CopyStr(PNRValue, 1, MaxStrLen(Errors.PNR));
        Errors."Passenger No." := PassengerNo;
        Errors."Field Name" := CopyStr(FieldName, 1, MaxStrLen(Errors."Field Name"));
        Errors."Current Value" := CopyStr(CurrentValue, 1, MaxStrLen(Errors."Current Value"));
        Errors."Error Reason" := CopyStr(Reason, 1, MaxStrLen(Errors."Error Reason"));
        Errors."Correction Required" := CopyStr(Correction, 1, MaxStrLen(Errors."Correction Required"));
        Errors.Insert();
        if (RowNo > 1) and not InvalidRows.ContainsKey(RowNo) then
            InvalidRows.Add(RowNo, true);
    end;

    procedure CheckHeaderPosition(var Excel: Record "Excel Buffer" temporary; ColNo: Integer; Expected: Text; IgnoreSeparators: Boolean)
    var
        Actual: Text;
        NormalActual: Text;
        NormalExpected: Text;
    begin
        Actual := ReadCell(Excel, 1, ColNo);
        if IgnoreSeparators then begin
            NormalActual := UpperCase(DelChr(Actual, '=', ' _-'));
            NormalExpected := UpperCase(DelChr(Expected, '=', ' _-'));
        end else begin
            NormalActual := UpperCase(DelChr(Actual, '<>', ' '));
            NormalExpected := UpperCase(DelChr(Expected, '<>', ' '));
        end;
        if NormalActual <> NormalExpected then
            AddIssue(1, ColNo, '', 0, 'Excel Header', Actual, StrSubstNo('Expected header: %1.', Expected), StrSubstNo('Use %1 in this column.', Expected));
    end;

    procedure CheckHeaderName(var Excel: Record "Excel Buffer" temporary; Expected: Text; AllowPassengerAlias: Boolean; OptionalHeader: Boolean; RejectDuplicates: Boolean)
    var
        ColNo: Integer;
        Actual: Text;
    begin
        Excel.Reset();
        Excel.SetRange("Row No.", 1);
        if Excel.FindSet() then
            repeat
                Actual := UpperCase(DelChr(Excel."Cell Value as Text", '<>', ' '));
                if AllowPassengerAlias and (Actual = 'PASSENGER NAME') then
                    Actual := 'VIEW PASSENGER';
                if Actual = UpperCase(Expected) then begin
                    if (ColNo <> 0) and RejectDuplicates then
                        AddIssue(1, Excel."Column No.", '', 0, 'Excel Header', Excel."Cell Value as Text", StrSubstNo('Duplicate header: %1.', Expected), 'Keep only one column with this header.');
                    ColNo := Excel."Column No.";
                end;
            until Excel.Next() = 0;
        Excel.Reset();
        if (ColNo = 0) and not OptionalHeader then
            AddIssue(1, 0, '', 0, 'Excel Header', '', StrSubstNo('Required header %1 is missing.', Expected), StrSubstNo('Add the %1 column.', Expected));
    end;

    procedure CheckDuplicateHeaders(var Excel: Record "Excel Buffer" temporary; AllowPassengerAlias: Boolean)
    var
        Seen: Dictionary of [Text, Boolean];
        Actual: Text;
    begin
        Excel.Reset();
        Excel.SetRange("Row No.", 1);
        if Excel.FindSet() then
            repeat
                Actual := UpperCase(DelChr(Excel."Cell Value as Text", '<>', ' '));
                if AllowPassengerAlias and (Actual = 'PASSENGER NAME') then
                    Actual := 'VIEW PASSENGER';
                if Actual <> '' then
                    if Seen.ContainsKey(Actual) then
                        AddIssue(1, Excel."Column No.", '', 0, 'Excel Header', Excel."Cell Value as Text", StrSubstNo('Duplicate header: %1.', Actual), 'Keep only one column with this header.')
                    else
                        Seen.Add(Actual, true);
            until Excel.Next() = 0;
        Excel.Reset();
    end;

    procedure CheckRateHeader(var Excel: Record "Excel Buffer" temporary)
    var
        Actual: Text;
        Found: Boolean;
    begin
        Excel.Reset();
        Excel.SetRange("Row No.", 1);
        if Excel.FindSet() then
            repeat
                Actual := UpperCase(DelChr(Excel."Cell Value as Text", '<>', ' '));
                if (Actual = 'RATE') or (Actual = 'BASE FARE') then
                    Found := true;
            until Excel.Next() = 0;
        Excel.Reset();
        if not Found then
            AddIssue(1, 0, '', 0, 'Excel Header', '', 'Required Rate or Base Fare header is missing.', 'Add a Rate or Base Fare column.');
    end;

    procedure CheckPassengerRow(RowNo: Integer; PNRValue: Text; PaxText: Text; NamesText: Text; IDsText: Text; TypesText: Text; PaxColumn: Integer; NamesColumn: Integer; IDsColumn: Integer; TypesColumn: Integer)
    var
        Names: List of [Text];
        IDs: List of [Text];
        Types: List of [Text];
        Pax: Integer;
        ValidPax: Boolean;
    begin
        CheckedRows += 1;
        if Evaluate(Pax, PaxText) then
            ValidPax := Pax > 0;
        if not ValidPax then
            AddIssue(RowNo, PaxColumn, PNRValue, 0, 'PAX', PaxText, 'PAX must be a positive whole number.', 'Enter a PAX count greater than 0.');

        Names := SplitValues(NamesText);
        IDs := SplitValues(IDsText);
        Types := SplitValues(TypesText);
        CheckColumn(RowNo, NamesColumn, PNRValue, 'Passenger Name', NamesText, Names, Pax, ValidPax, 100, false);
        CheckColumn(RowNo, IDsColumn, PNRValue, 'Passenger ID', IDsText, IDs, Pax, ValidPax, 0, true);
        CheckColumn(RowNo, TypesColumn, PNRValue, 'Passenger Type', TypesText, Types, Pax, ValidPax, 50, false);
        if not ValidPax then
            if (Names.Count() <> IDs.Count()) or (Names.Count() <> Types.Count()) then
                AddIssue(RowNo, NamesColumn, PNRValue, 0, 'Passenger Details', NamesText, StrSubstNo('List counts differ: Name=%1, ID=%2, Type=%3.', Names.Count(), IDs.Count(), Types.Count()), 'Make all three lists match the corrected PAX.');
    end;

    local procedure SplitValues(ValueText: Text): List of [Text]
    var
        Values: List of [Text];
        Parts: List of [Text];
        Part: Text;
    begin
        if DelChr(ValueText, '<>', ' ') = '' then
            exit(Values);
        Parts := ValueText.Split(',');
        foreach Part in Parts do
            Values.Add(DelChr(Part, '<>', ' '));
        exit(Values);
    end;

    local procedure CheckColumn(RowNo: Integer; ColNo: Integer; PNRValue: Text; FieldName: Text; RawValue: Text; Values: List of [Text]; Pax: Integer; ValidPax: Boolean; MaxLength: Integer; IsID: Boolean)
    var
        I: Integer;
        Value: Text;
        NumericID: BigInteger;
    begin
        // One count error per column, even for very large invalid PAX; do not loop up to PAX.
        if ValidPax and (Values.Count() <> Pax) then
            if Values.Count() < Pax then
                AddIssue(RowNo, ColNo, PNRValue, 0, FieldName, RawValue, StrSubstNo('Expected %1 values; found %2.', Pax, Values.Count()), StrSubstNo('Add %1 missing value(s) in passenger order.', Pax - Values.Count()))
            else
                AddIssue(RowNo, ColNo, PNRValue, 0, FieldName, RawValue, StrSubstNo('Expected %1 values; found %2.', Pax, Values.Count()), StrSubstNo('Remove %1 extra value(s).', Values.Count() - Pax));
        if Values.Count() = 0 then begin
            AddIssue(RowNo, ColNo, PNRValue, 0, FieldName, RawValue, StrSubstNo('%1 is blank.', FieldName), 'Enter the complete comma-separated list.');
            exit;
        end;
        for I := 1 to Values.Count() do begin
            Value := Values.Get(I);
            if Value = '' then
                AddIssue(RowNo, ColNo, PNRValue, I, FieldName, Value, StrSubstNo('%1 must not be blank.', FieldName), 'Enter the missing value at this passenger position.')
            else
                if IsID then begin
                    if not Evaluate(NumericID, Value) then
                        AddIssue(RowNo, ColNo, PNRValue, I, FieldName, Value, 'Passenger ID is not a valid whole number.', 'Enter a valid positive numeric ID.')
                    else
                        if NumericID <= 0 then
                            AddIssue(RowNo, ColNo, PNRValue, I, FieldName, Value, 'Passenger ID must be greater than 0.', 'Enter a positive numeric ID.');
                end else
                    if StrLen(Value) > MaxLength then
                        AddIssue(RowNo, ColNo, PNRValue, I, FieldName, Value, StrSubstNo('%1 exceeds %2 characters.', FieldName, MaxLength), StrSubstNo('Use no more than %1 characters.', MaxLength));
        end;
    end;

    procedure ShowErrors(var Excel: Record "Excel Buffer" temporary; ModuleName: Text; FileName: Text; SheetName: Text)
    var
        ErrorPage: Page "AIRIQ Excel Validation Errors";
    begin
        Errors.Reset();
        Excel.Reset();
        ErrorPage.SetData(Errors, Excel, ModuleName, FileName, SheetName, CheckedRows, InvalidRows.Count());
        ErrorPage.RunModal();
    end;

    local procedure CellAddress(RowNo: Integer; ColNo: Integer): Text
    var
        Letters: Text;
        Alphabet: Text;
        Remainder: Integer;
    begin
        Alphabet := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        while ColNo > 0 do begin
            Remainder := (ColNo - 1) mod 26;
            Letters := CopyStr(Alphabet, Remainder + 1, 1) + Letters;
            ColNo := (ColNo - 1) div 26;
        end;
        exit(Letters + Format(RowNo, 0, 9));
    end;

    procedure DownloadReport(var ErrorView: Record "AIRIQ Excel Validation Buffer" temporary; var Source: Record "Excel Buffer" temporary; ModuleName: Text; FileName: Text; SheetName: Text; Checked: Integer; Invalid: Integer)
    var
        ReportErrors: Record "AIRIQ Excel Validation Buffer" temporary;
        SourceCopy: Record "Excel Buffer" temporary;
        DataBuffer: Record "Excel Buffer" temporary;
        ReportBuffer: Record "Excel Buffer" temporary;
        Workbook: Record "Excel Buffer" temporary;
        RawWorkbook: Codeunit "Temp Blob";
        ColoredWorkbook: Codeunit "Temp Blob";
        ErrorCells: Dictionary of [Text, Boolean];
        Address: Text;
        RawIn: InStream;
        WorkbookOut: OutStream;
        DownloadIn: InStream;
        DownloadName: Text;
    begin
        // Shared temporary tables: Reset on the copies, never filter the user's report.
        ReportErrors.Copy(ErrorView, true);
        ReportErrors.Reset();
        ReportErrors.SetCurrentKey("Excel Row No.", "Excel Column No.", "Passenger No.");
        if ReportErrors.FindSet() then
            repeat
                Address := ReportErrors."Cell Reference";
                if (Address <> '') and not ErrorCells.ContainsKey(Address) then
                    ErrorCells.Add(Address, true);
            until ReportErrors.Next() = 0;

        // Reproduce the selected import sheet at the same cell coordinates.
        // Export the text read by the importer, not formulas or executable cell content.
        SourceCopy.Copy(Source, true);
        SourceCopy.Reset();
        if SourceCopy.FindSet() then
            repeat
                DataBuffer := SourceCopy;
                Clear(DataBuffer.Formula);
                Clear(DataBuffer.Formula2);
                Clear(DataBuffer.Formula3);
                Clear(DataBuffer.Formula4);
                Clear(DataBuffer."Cell Value as Blob");
                DataBuffer."Cell Type" := DataBuffer."Cell Type"::Text;
                DataBuffer.NumberFormat := '@';
                DataBuffer.Bold := (DataBuffer."Row No." = 1) or ErrorCells.ContainsKey(CellAddress(DataBuffer."Row No.", DataBuffer."Column No."));
                DataBuffer.Italic := false;
                DataBuffer.Underline := false;
                Clear(DataBuffer.Comment);
                DataBuffer.Insert();
            until SourceCopy.Next() = 0;

        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Module', true);
        AddText(ReportBuffer, ModuleName, false);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Source file', true);
        AddText(ReportBuffer, FileName, false);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Source sheet', true);
        AddText(ReportBuffer, SheetName, false);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Status', true);
        AddText(ReportBuffer, 'IMPORT BLOCKED - no records imported', true);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Checked data rows', true);
        AddText(ReportBuffer, Format(Checked), false);
        AddText(ReportBuffer, 'Invalid data rows', true);
        AddText(ReportBuffer, Format(Invalid), false);
        AddText(ReportBuffer, 'Total errors', true);
        AddText(ReportBuffer, Format(ReportErrors.Count()), false);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Correct the Original Data sheet and select that sheet on re-import.', true);
        ReportBuffer.NewRow();
        AddText(ReportBuffer, 'Excel Row', true);
        AddText(ReportBuffer, 'Cell', true);
        AddText(ReportBuffer, 'PNR', true);
        AddText(ReportBuffer, 'Passenger No.', true);
        AddText(ReportBuffer, 'Field Name', true);
        AddText(ReportBuffer, 'Current Value', true);
        AddText(ReportBuffer, 'Error Reason', true);
        AddText(ReportBuffer, 'Correction Required', true);
        if ReportErrors.FindSet() then
            repeat
                ReportBuffer.NewRow();
                AddText(ReportBuffer, Format(ReportErrors."Excel Row No."), false);
                AddText(ReportBuffer, ReportErrors."Cell Reference", false);
                AddText(ReportBuffer, ReportErrors.PNR, false);
                if ReportErrors."Passenger No." = 0 then
                    AddText(ReportBuffer, '', false)
                else
                    AddText(ReportBuffer, Format(ReportErrors."Passenger No."), false);
                AddText(ReportBuffer, ReportErrors."Field Name", false);
                AddText(ReportBuffer, ReportErrors."Current Value", false);
                AddText(ReportBuffer, ReportErrors."Error Reason", false);
                AddText(ReportBuffer, ReportErrors."Correction Required", false);
            until ReportErrors.Next() = 0;

        Workbook.CreateNewBook('Original Data');
        DataBuffer.Reset();
        Workbook.WriteAllToCurrentSheet(DataBuffer);
        Workbook.SelectOrAddSheet('Error Report');
        ReportBuffer.Reset();
        Workbook.WriteAllToCurrentSheet(ReportBuffer);
        Workbook.SetColumnWidth('A', 24);
        Workbook.SetColumnWidth('B', 24);
        Workbook.SetColumnWidth('C', 18);
        Workbook.SetColumnWidth('D', 20);
        Workbook.SetColumnWidth('E', 25);
        Workbook.SetColumnWidth('F', 35);
        Workbook.SetColumnWidth('G', 65);
        Workbook.SetColumnWidth('H', 65);
        Workbook.CloseBook();
        RawWorkbook.CreateOutStream(WorkbookOut);
        Workbook.SaveToStream(WorkbookOut, true);

        // Standard Excel Buffer supports bold, not a red fill. Add a red differential
        // style to the generated XLSX only; never modify the user's uploaded file.
        if ErrorCells.Count() > 0 then begin
            RawWorkbook.CreateInStream(RawIn);
            if TryAddRedHighlight(RawIn, ErrorCells, ColoredWorkbook) then
                ColoredWorkbook.CreateInStream(DownloadIn)
            else begin
                ClearLastError();
                RawWorkbook.CreateInStream(DownloadIn);
                Message('Red highlighting could not be generated. The error list and bold-marked existing cells are still available.');
            end;
        end else
            RawWorkbook.CreateInStream(DownloadIn);
        DownloadName := 'AIRIQ_' + ConvertStr(ModuleName, ' ', '_') + '_Validation_Errors.xlsx';
        DownloadFromStream(DownloadIn, '', '', 'Excel Files (*.xlsx)|*.xlsx', DownloadName);
    end;

    local procedure AddText(var Excel: Record "Excel Buffer" temporary; Value: Text; IsBold: Boolean)
    begin
        Excel.AddColumn(CopyStr(Value, 1, 250), false, '', IsBold, false, false, '@', Excel."Cell Type"::Text);
    end;

    [TryFunction]
    local procedure TryAddRedHighlight(Input: InStream; ErrorCells: Dictionary of [Text, Boolean]; var Output: Codeunit "Temp Blob")
    var
        Zip: Codeunit "Data Compression";
        Styles: XmlDocument;
        Sheet: XmlDocument;
        StylesRoot: XmlElement;
        SheetRoot: XmlElement;
        Dxfs: XmlElement;
        Dxf: XmlElement;
        Fill: XmlElement;
        PatternFill: XmlElement;
        Color: XmlElement;
        Node: XmlNode;
        Anchor: XmlNode;
        Children: XmlNodeList;
        NS: Text;
        Address: Text;
        RangeText: Text;
        DxfId: Integer;
        Priority: Integer;
        CellCount: Integer;
    begin
        NS := 'http://schemas.openxmlformats.org/spreadsheetml/2006/main';
        Zip.OpenZipArchive(Input, true);
        ReadZipXml(Zip, 'xl/styles.xml', Styles);
        ReadZipXml(Zip, 'xl/worksheets/sheet1.xml', Sheet);
        Styles.GetRoot(StylesRoot);
        Sheet.GetRoot(SheetRoot);
        if StylesRoot.SelectSingleNode('*[local-name()="dxfs"]', Node) then
            Dxfs := Node.AsXmlElement()
        else begin
            Dxfs := XmlElement.Create('dxfs', NS);
            if StylesRoot.SelectSingleNode('*[local-name()="tableStyles" or local-name()="colors" or local-name()="extLst"]', Anchor) then
                Anchor.AddBeforeSelf(Dxfs)
            else
                StylesRoot.Add(Dxfs);
        end;
        // Obtain the inserted element from the document (XML Add may copy nodes).
        StylesRoot.SelectSingleNode('*[local-name()="dxfs"]', Node);
        Dxfs := Node.AsXmlElement();
        Dxfs.SelectNodes('*[local-name()="dxf"]', Children);
        DxfId := Children.Count();
        Dxf := XmlElement.Create('dxf', NS);
        Fill := XmlElement.Create('fill', NS);
        PatternFill := XmlElement.Create('patternFill', NS);
        PatternFill.SetAttribute('patternType', 'solid');
        Color := XmlElement.Create('fgColor', NS);
        Color.SetAttribute('rgb', 'FFFFC7CE');
        PatternFill.Add(Color);
        Color := XmlElement.Create('bgColor', NS);
        Color.SetAttribute('rgb', 'FFFFC7CE');
        PatternFill.Add(Color);
        Fill.Add(PatternFill);
        Dxf.Add(Fill);
        Dxfs.Add(Dxf);
        Dxfs.SetAttribute('count', Format(DxfId + 1, 0, 9));

        // One conditional-format rule per 200 cells. Missing cells are highlighted too.
        foreach Address in ErrorCells.Keys() do begin
            if RangeText <> '' then
                RangeText += ' ';
            RangeText += Address;
            CellCount += 1;
            if CellCount = 200 then begin
                Priority += 1;
                AddHighlightRule(SheetRoot, NS, RangeText, DxfId, Priority);
                Clear(RangeText);
                CellCount := 0;
            end;
        end;
        if RangeText <> '' then begin
            Priority += 1;
            AddHighlightRule(SheetRoot, NS, RangeText, DxfId, Priority);
        end;
        WriteZipXml(Zip, 'xl/styles.xml', Styles);
        WriteZipXml(Zip, 'xl/worksheets/sheet1.xml', Sheet);
        Zip.SaveZipArchive(Output);
        Zip.CloseZipArchive();
    end;

    local procedure AddHighlightRule(var SheetRoot: XmlElement; NS: Text; RangeText: Text; DxfId: Integer; Priority: Integer)
    var
        Conditional: XmlElement;
        Rule: XmlElement;
        Formula: XmlElement;
        Anchor: XmlNode;
    begin
        Conditional := XmlElement.Create('conditionalFormatting', NS);
        Conditional.SetAttribute('sqref', RangeText);
        Rule := XmlElement.Create('cfRule', NS);
        Rule.SetAttribute('type', 'expression');
        Rule.SetAttribute('dxfId', Format(DxfId, 0, 9));
        Rule.SetAttribute('priority', Format(Priority, 0, 9));
        Formula := XmlElement.Create('formula', NS);
        Formula.Add(XmlText.Create('TRUE()'));
        Rule.Add(Formula);
        Conditional.Add(Rule);
        // OOXML worksheet schema requires conditionalFormatting before these elements.
        if SheetRoot.SelectSingleNode('*[local-name()="dataValidations" or local-name()="hyperlinks" or local-name()="printOptions" or local-name()="pageMargins" or local-name()="pageSetup" or local-name()="headerFooter" or local-name()="rowBreaks" or local-name()="colBreaks" or local-name()="customProperties" or local-name()="cellWatches" or local-name()="ignoredErrors" or local-name()="smartTags" or local-name()="drawing" or local-name()="legacyDrawing" or local-name()="legacyDrawingHF" or local-name()="picture" or local-name()="oleObjects" or local-name()="controls" or local-name()="webPublishItems" or local-name()="tableParts" or local-name()="extLst"]', Anchor) then
            Anchor.AddBeforeSelf(Conditional)
        else
            SheetRoot.Add(Conditional);
    end;

    local procedure ReadZipXml(var Zip: Codeunit "Data Compression"; Path: Text; var Doc: XmlDocument)
    var
        Blob: Codeunit "Temp Blob";
        EntryIn: InStream;
    begin
        Zip.ExtractEntry(Path, Blob);
        Blob.CreateInStream(EntryIn);
        XmlDocument.ReadFrom(EntryIn, Doc);
    end;

    local procedure WriteZipXml(var Zip: Codeunit "Data Compression"; Path: Text; var Doc: XmlDocument)
    var
        Blob: Codeunit "Temp Blob";
        EntryIn: InStream;
        EntryOut: OutStream;
    begin
        Blob.CreateOutStream(EntryOut, TextEncoding::UTF8);
        Doc.WriteTo(EntryOut);
        Blob.CreateInStream(EntryIn);
        Zip.RemoveEntry(Path);
        Zip.AddEntry(EntryIn, Path);
    end;
}
