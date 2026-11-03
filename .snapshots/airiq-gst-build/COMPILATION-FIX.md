# Full AIRIQ compilation result

Full project rebuild: PASS, compiler 18.1.43.24897, exit code 0.

- AL source files: 123.
- Errors: 0.
- Warnings: 3 (AL1025).
- Warning files: root Info.txt; temporary .NET runtime LICENSE.txt and
  ThirdPartyNotices.txt under .snapshots/airiq-gst-build/dotnet.
- Output: .snapshots/airiq-gst-build/AIRIQ_1.0.0.3.app.
- Compiler log: .snapshots/airiq-gst-build/compile.log.

Seven extracted Microsoft reference files were archived in
AIRIQ-GST-Custom/importer-source/Microsoft-reference-source.zip after verifying
their archived contents against the loose originals. No loose Microsoft AL
copies remain in the project. Merely moving them under .alpackages was tested
and did not exclude them with this compiler; no unsupported .alignore rule is
relied on. The ZIP retains the files for future analysis without making them
compiler source inputs.

AIRIQGSTTreeCheck.al and AIRIQGSTTreeDiagnostic.al both compile unchanged.
Their AL0275 ambiguous SourceTable errors came from the extracted duplicate
Use Case Tree Node table; AL0118 Rec and AL0429 repeater errors were cascading
diagnostics. Removing the duplicate resolved all of these.

The built package was checked for absence of all seven reference AL sources
and for inclusion of both AIRIQ diagnostic pages. Existing project JSON files
were hash-checked before/after and remain byte-identical. No GST CaseIDs,
formulas, execution nodes or posting logic changed. No tenant operation or
publication was performed. The pre-existing root app was not overwritten.

Reproduce from the project root:

```powershell
& ./.snapshots/airiq-gst-build/dotnet/dotnet.exe 'C:/Users/P.C/.vscode/extensions/ms-dynamics-smb.al-18.1.2842859/bin/alc.dll' /project:. /packagecachepath:.alpackages /out:.snapshots/airiq-gst-build/AIRIQ_1.0.0.3.app
```
