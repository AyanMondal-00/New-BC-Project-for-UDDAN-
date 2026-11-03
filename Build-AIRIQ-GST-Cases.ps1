param([string]$SourceFolder = (Join-Path $PSScriptRoot 'AIRIQ-GST-Source'),
      [string]$OutputFolder = (Join-Path $PSScriptRoot 'AIRIQ-GST-Custom'))
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Resolve-AIRIQ-GST-Source.ps1')
# Only ordinary Item invoices used by AIRIQ. Source IDs are never imported.
$templates = @(
 '6b464955-261f-4eaf-a749-7807444fc37c', # registered intra
 'b61cb389-28bd-4569-bf95-284b62972b23', # registered inter
 'cfe77ace-1f20-4126-98d9-8d14b18088ee', # unregistered intra
 '11160e03-89d0-481d-b2ea-24898f3db4ab', # unregistered inter
 'a8bf5ad2-5132-40e7-9df1-893b3940f6ee', # registered Kerala
 '364eaba8-df5d-4174-951e-9c9b375830d6'  # unregistered Kerala
)
function New-Condition($field, $value) {
 [pscustomobject]@{Operator='and';ConditionType='Equals';
 LHS=@{Lookup=@{SourceType='Current Record';TableName='Sales Line';FieldName=$field}};
 RHS=@{Type='Constant';Value=$value}}
}
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
$manifest = @()
foreach ($flight in @('Domestic','International')) {
 # Integer ratios avoid decimal-literal culture dependence.
 $divisor = if ($flight -eq 'Domestic') {'20'} else {'10'}
 $flightIndex = if ($flight -eq 'Domestic') {1} else {2}
 $result = @()
 for ($i=0; $i -lt $templates.Count; $i++) {
  $sourceFile = Get-AIRIQGSTSourceFile $SourceFolder $templates[$i]
  $sourceCases = Get-Content -LiteralPath $sourceFile -Raw | ConvertFrom-Json
  if ($sourceCases.Count -ne 1) {throw "Expected one source case: $sourceFile"}
  $original = $sourceCases[0]
  if ([guid]$original.CaseID -ne [guid]$templates[$i] -or $original.TaxEntity -ne 'Sales Line' -or
      $original.ParentCaseId -ne '{9B72FC90-6211-4E8D-8EA3-3BC5D1C7601B}') {throw "Unexpected source identity: $sourceFile"}
  $clone = $original | ConvertTo-Json -Depth 100 | ConvertFrom-Json
  # First IDs remain compatible with the previous two custom files.
  $suffix = if ($i -eq 0) {$flightIndex} else {100+$i}
  $clone.CaseID = '{A1D1000'+$flightIndex+'-7B10-4A10-9010-'+([int]$suffix).ToString('D12')+'}'
  $clone.Description = "AIRIQ $flight - $($original.Description)"
  $clone.ChangedBy = 'AIRIQ'
  $clone.Version = 1
  $clone.MinorVersion = if ($i -eq 0) {2} else {1}
  # Preserve parent rate inheritance. PresentationOrder does not set execution priority.
  $invoice = @($clone.Condition.Body | Where-Object { $_.LHS.Lookup.FieldName -eq 'Document Type' -and $_.RHS.Value -eq 'Invoice' })
  $item = @($clone.Condition.Body | Where-Object { $_.LHS.Lookup.FieldName -eq 'Type' -and $_.RHS.Value -eq 'Item' })
  if ($invoice.Count -ne 1 -or $item.Count -ne 1) {throw "Unexpected source conditions: $sourceFile"}
  $invoice[0].Operator = ' '
  $clone.Condition.Body = @($invoice[0]) + @($clone.Condition.Body | Where-Object { $_.LHS.Lookup.FieldName -ne 'Document Type' })
  $clone.Condition.Body += (New-Condition 'FlightType' $flight)
  # Unregistered templates include inclusive pricing: keep that separate standard path.
  $inclusive = @($clone.Condition.Body | Where-Object { $_.LHS.Lookup.FieldName -eq 'Price Inclusive of Tax' })
  if ($inclusive.Count -eq 0) {$clone.Condition.Body += (New-Condition 'Price Inclusive of Tax' 'false')}
  foreach ($component in $clone.Components) {
   $name = $component.ComponentName
   if ($name -notin @('GST Base Amount','CGST','SGST','IGST','KFloodCess')) {throw "Unexpected component $name"}
   $tokens = @([pscustomobject]@{TokenName='{AIRIQAmount}';TokenValue=@{Type='Lookup';Lookup=@{SourceType='Current Record';TableName='Sales Line';FieldName='Amount'}}})
   $expression = "{AIRIQAmount}/$divisor"
   if ($name -ne 'GST Base Amount') {
    $expression += '*{AIRIQRate}/100'
    $tokens += [pscustomobject]@{TokenName='{AIRIQRate}';TokenValue=@{Type='Lookup';Lookup=@{SourceType='Component Percent';ComponentName=$name}}}
   }
   # Each formula reads ORIGINAL Amount; each reduction occurs once.
   $component.Formula.Expression = $expression
   $component.Formula.Tokens = $tokens
  }
  $result += $clone
  $manifest += [pscustomobject]@{FlightType=$flight;CaseID=$clone.CaseID;SourceCaseID=$original.CaseID;
   SourceVersion="$($original.Version).$($original.MinorVersion)";SourceSHA256=(Get-FileHash $sourceFile -Algorithm SHA256).Hash;
   SourceOrigin=$(if ($i -eq 0) {'Confirmed Sandbox export: GST.json'} else {'Pinned Microsoft package'});Description=$clone.Description}
 }
 # Windows PowerShell Set-Content -Encoding UTF8 emits a BOM. The Tax Engine
 # upload path reads text without explicitly selecting UTF-8 or stripping a BOM.
 # Match Microsoft's export: compact JSON array, UTF-8 without BOM.
 $json = ConvertTo-Json -InputObject @($result) -Depth 100 -Compress
 [IO.File]::WriteAllText((Join-Path $OutputFolder "AIRIQ-GST-$flight.json"), $json, [Text.UTF8Encoding]::new($false))
}
ConvertTo-Json -InputObject @($manifest) -Depth 10 | Set-Content -LiteralPath (Join-Path $OutputFolder 'case-manifest.json') -Encoding UTF8
Write-Output 'Generated 12 custom cases in two import files; tenant configuration untouched.'
