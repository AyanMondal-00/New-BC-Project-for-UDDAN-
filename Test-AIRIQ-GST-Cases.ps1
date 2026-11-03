param([string]$SourceFolder = (Join-Path $PSScriptRoot 'AIRIQ-GST-Source'),
      [string]$OutputFolder = (Join-Path $PSScriptRoot 'AIRIQ-GST-Custom'))
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'Resolve-AIRIQ-GST-Source.ps1')
$script:checks = 0
function Assert($ok, $message) {
 $script:checks++
 if (-not $ok) {throw "Validation failed: $message"}
}
function Json($value) {ConvertTo-Json -InputObject $value -Depth 100 -Compress}
# Mirrors the installed Script Data Type Mgmt. EvaluateExpression operator scan.
function Evaluate-Formula([string]$expr, $values) {
 foreach ($op in @('+','-','*','/','^')) {
  $depth=0
  for ($i=$expr.Length-1; $i -ge 0; $i--) {
   if ($expr[$i] -eq '(') {$depth++}
   if ($expr[$i] -eq ')') {$depth--}
   if ($depth -eq 0 -and $expr[$i] -eq $op) {
    $left=Evaluate-Formula $expr.Substring(0,$i) $values
    $right=Evaluate-Formula $expr.Substring($i+1) $values
    switch ($op) {
     '+' {return $left+$right}; '-' {return $left-$right}; '*' {return $left*$right}
     '/' {if ($right -eq 0) {return [decimal]0}; return $left/$right}
     '^' {return [decimal][math]::Pow($left,$right)}
    }
   }
  }
 }
 if ($expr.Length -eq 0) {return [decimal]0}
 if ($values.ContainsKey($expr)) {return [decimal]$values[$expr]}
 return [decimal]::Parse($expr,[Globalization.CultureInfo]::InvariantCulture)
}
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$app=Get-Content (Join-Path $PSScriptRoot 'app.json') -Raw|ConvertFrom-Json
$dep=@($app.dependencies|Where-Object {$_.name -eq 'India GST'})[0]
$package=Join-Path $PSScriptRoot ('.alpackages/Microsoft_India GST_'+$dep.version+'.app')
$bytes=[IO.File]::ReadAllBytes($package)
$offset=-1
for ($i=0;$i -lt $bytes.Length-3;$i++) {
 if ($bytes[$i] -eq 80 -and $bytes[$i+1] -eq 75 -and $bytes[$i+2] -eq 3 -and $bytes[$i+3] -eq 4) {$offset=$i;break}
}
Assert ($offset -ge 0) 'package ZIP header'
$stream=[IO.MemoryStream]::new($bytes,$offset,$bytes.Length-$offset)
$zip=[IO.Compression.ZipArchive]::new($stream)
$numeric=0
$all=@()
try {
 $manifest=Get-Content (Join-Path $OutputFolder 'case-manifest.json') -Raw|ConvertFrom-Json
 Assert ($manifest.Count -eq 12) 'manifest contains 12 cases'
 foreach ($flight in @('Domestic','International')) {
  $path=Join-Path $OutputFolder "AIRIQ-GST-$flight.json"
  $raw=Get-Content $path -Raw
  Assert ($raw.TrimStart().StartsWith('[')) 'import file is an array'
  $cases=$raw|ConvertFrom-Json
  Assert ($cases.Count -eq 6) "$flight six branches"
  foreach ($c in $cases) {
   $all+=$c
   $m=@($manifest|Where-Object {$_.CaseID -eq $c.CaseID})
   Assert ($m.Count -eq 1) 'unique manifest mapping'
   $sourceFile=Get-AIRIQGSTSourceFile $SourceFolder $m[0].SourceCaseID
   Assert ((Get-FileHash $sourceFile -Algorithm SHA256).Hash -eq $m[0].SourceSHA256) 'source hash'
   $s=(Get-Content $sourceFile -Raw|ConvertFrom-Json)[0]
   $entry=@($zip.Entries|Where-Object {$_.FullName.EndsWith(([guid]$s.CaseID).ToString()+'.json')})
   Assert ($entry.Count -eq 1) 'source exists in pinned Microsoft package'
   $reader=[IO.StreamReader]::new($entry[0].Open())
   try {$installed=($reader.ReadToEnd()|ConvertFrom-Json)[0]} finally {$reader.Dispose()}
   $baselineFile=Join-Path $SourceFolder (([guid]$m[0].SourceCaseID).ToString()+'.json')
   $baseline=(Get-Content $baselineFile -Raw|ConvertFrom-Json)[0]
   Assert ((Json $baseline) -ceq (Json $installed)) 'packaged Microsoft baseline unchanged'
   Assert ($m[0].SourceVersion -eq "$($s.Version).$($s.MinorVersion)") 'manifest effective source version'
   if ([guid]$s.CaseID -eq [guid]'6b464955-261f-4eaf-a749-7807444fc37c') {
    Assert ($s.Version -eq 7 -and $s.MinorVersion -eq 1) 'confirmed Sandbox source 7.1'
   } else {Assert ((Json $s) -ceq (Json $installed)) 'other Microsoft sources unchanged'}
   Assert ($c.CaseID -ne $s.CaseID -and $c.ChangedBy -eq 'AIRIQ' -and [guid]$c.CaseID -ne [guid]::Empty) 'custom identity'
   $minor=if ([guid]$s.CaseID -eq [guid]'6b464955-261f-4eaf-a749-7807444fc37c') {2} else {1}
   Assert ($c.Version -eq 1 -and $c.MinorVersion -eq $minor) 'custom version 1.2 for updated cases; otherwise 1.1'
   Assert ($c.Description.Length -le 250) 'description fits schema'
   Assert ((Json @($c.PSObject.Properties.Name)) -ceq (Json @($s.PSObject.Properties.Name))) 'same schema properties'
   foreach ($p in $s.PSObject.Properties.Name) {
    if ($p -notin @('CaseID','Description','ChangedBy','Version','MinorVersion','Condition','Components')) {
     Assert ((Json $c.$p) -ceq (Json $s.$p)) "preserved $p (including posting and rate inheritance)"
    }
   }
   $expected=@($s.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -eq 'Document Type' -and $_.RHS.Value -eq 'Invoice'})
   $expected[0].Operator=' '
   $expected+=@($s.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -ne 'Document Type'})
   $retained=@($c.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -ne 'FlightType'})
   $hadInclusive=@($s.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -eq 'Price Inclusive of Tax'}).Count -gt 0
   if (-not $hadInclusive) {
    $inc=@($c.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -eq 'Price Inclusive of Tax'})
    Assert ($inc.Count -eq 1 -and $inc[0].Operator -eq 'and' -and $inc[0].RHS.Value -eq 'false') 'unregistered tax-exclusive guard'
   }
   if (-not $hadInclusive) {$retained=@($retained|Where-Object {$_.LHS.Lookup.FieldName -ne 'Price Inclusive of Tax'})}
   Assert ((Json $retained) -ceq (Json $expected)) 'original business guards retained; only Invoice document'
   Assert (@($c.Condition.Body|Where-Object {$_.Operator -eq 'or'}).Count -eq 0) 'no document OR precedence leak'
   $fc=@($c.Condition.Body|Where-Object {$_.LHS.Lookup.FieldName -eq 'FlightType'})
   Assert ($fc.Count -eq 1 -and $fc[0].RHS.Value -ceq $flight -and $fc[0].LHS.Lookup.SourceType -eq 'Current Record' -and $fc[0].LHS.Lookup.TableName -eq 'Sales Line') 'FlightType direct record lookup'
   Assert ($c.Components.Count -eq $s.Components.Count) 'same posting components'
   foreach ($comp in $c.Components) {
    $sc=@($s.Components|Where-Object {$_.ComponentName -eq $comp.ComponentName})[0]
    foreach ($p in $sc.PSObject.Properties.Name) {
     if ($p -ne 'Formula') {Assert ((Json $comp.$p) -ceq (Json $sc.$p)) "preserved component $p"}
    }
    $formula=$comp.Formula
    Assert ($formula.Expression.Length -le 250) 'formula schema length'
    $names=@($formula.Tokens.TokenName)
    $used=@([regex]::Matches($formula.Expression,'\{[^}]+\}')|ForEach-Object {$_.Value})
    Assert ((Json @($names|Sort-Object)) -ceq (Json @($used|Sort-Object))) 'all tokens defined exactly once'
    $amount=@($formula.Tokens|Where-Object {$_.TokenName -eq '{AIRIQAmount}'})[0].TokenValue
    Assert ($amount.Type -eq 'Lookup' -and $amount.Lookup.SourceType -eq 'Current Record' -and $amount.Lookup.TableName -eq 'Sales Line' -and $amount.Lookup.FieldName -eq 'Amount') 'original Amount token; no reduced component lookup'
    if ($comp.ComponentName -ne 'GST Base Amount') {
     $rate=@($formula.Tokens|Where-Object {$_.TokenName -eq '{AIRIQRate}'})[0].TokenValue
     Assert ($rate.Type -eq 'Lookup' -and $rate.Lookup.SourceType -eq 'Component Percent' -and $rate.Lookup.ComponentName -eq $comp.ComponentName) 'configured component rate'
    }
    foreach ($a in @([decimal]0,[decimal]1,[decimal]10000,[decimal]-10000,[decimal]1234.56)) {
     foreach ($r in @([decimal]0,[decimal]2.5,[decimal]9,[decimal]18)) {
      $factor=if ($flight -eq 'Domestic') {[decimal]0.05} else {[decimal]0.10}
      $want=$a*$factor
      if ($comp.ComponentName -ne 'GST Base Amount') {$want=$want*$r/100}
      $got=Evaluate-Formula $formula.Expression @{'{AIRIQAmount}'=$a;'{AIRIQRate}'=$r}
      Assert ([math]::Abs($got-$want) -lt [decimal]0.0000000001) 'numeric base/rate consistency without double scaling'
      $numeric++
     }
    }
   }
  }
 }
 Assert (@($all.CaseID|Sort-Object -Unique).Count -eq 12) 'no duplicate custom IDs'
 Assert ($all.CaseID -contains '{A1D10001-7B10-4A10-9010-000000000001}' -and $all.CaseID -contains '{A1D10002-7B10-4A10-9010-000000000002}') 'previous custom IDs preserved'
 $report=[ordered]@{Result='PASS';Checks=$script:checks;Cases=$all.Count;NumericScenarios=$numeric;
  IndiaGSTPackage=$dep.version;PackageSHA256=(Get-FileHash $package -Algorithm SHA256).Hash;
  Scope='Item, Invoice, registered/unregistered, intra/inter, non-FOC, tax-exclusive; Kerala cess source guards preserved';
  TenantVersion71='VERIFIED: confirmed GST.json export for 6B464955-261F-4EAF-A749-7807444FC37C; other active tenant cases/parent not supplied';TreePriority='UNVERIFIED: no active tenant tree export supplied';
  RuntimeImportAndPosting='NOT RUN: offline validation only'}
 $report['ALCompile']='Not run by this JSON validator. See compile-results.json for the separate complete-project build evidence.'
 $report|ConvertTo-Json|Set-Content (Join-Path $OutputFolder 'validation-results.json') -Encoding UTF8
 $report|ConvertTo-Json
} finally {$zip.Dispose();$stream.Dispose()}
