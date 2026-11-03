function Get-AIRIQGSTSourceFile([string]$SourceFolder, [string]$CaseID) {
 if ([guid]$CaseID -ne [guid]'6b464955-261f-4eaf-a749-7807444fc37c') {
  return (Join-Path $SourceFolder (([guid]$CaseID).ToString()+'.json'))
 }
 # Confirmed Sandbox export. Keep the packaged 7.0 baseline intact.
 $path=Join-Path $PSScriptRoot 'GST.json'
 $cases=Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
 if ($cases.Count -ne 1 -or [guid]$cases[0].CaseID -ne [guid]$CaseID -or
     $cases[0].Version -ne 7 -or $cases[0].MinorVersion -ne 1) {
  throw 'Expected the confirmed Sandbox case at version 7.1 in GST.json'
 }
 return $path
}
