
$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$projectFolder = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($projectFolder)) {
    $projectFolder = (Get-Location).Path
}

$packageFolder = Join-Path $projectFolder ".alpackages"
$outputFolder = Join-Path $projectFolder "AIRIQ-GST-Source"

$caseIds = @(
    "6b464955-261f-4eaf-a749-7807444fc37c",
    "9b72fc90-6211-4e8d-8ea3-3bc5d1c7601b",
    "b61cb389-28bd-4569-bf95-284b62972b23",
    "cfe77ace-1f20-4126-98d9-8d14b18088ee",
    "11160e03-89d0-481d-b2ea-24898f3db4ab",
    "a8bf5ad2-5132-40e7-9df1-893b3940f6ee",
    "364eaba8-df5d-4174-951e-9c9b375830d6"
)

if (-not (Test-Path $packageFolder)) {
    throw ".alpackages folder not found."
}

New-Item -ItemType Directory -Path $outputFolder -Force |
    Out-Null

$app = Get-Content (Join-Path $projectFolder 'app.json') -Raw | ConvertFrom-Json
$dependency = @($app.dependencies | Where-Object { $_.name -eq 'India GST' -and $_.publisher -eq 'Microsoft' })
if ($dependency.Count -ne 1) { throw 'Expected one Microsoft India GST dependency.' }
$packages = @(Get-Item -LiteralPath (Join-Path $packageFolder ("Microsoft_India GST_" + $dependency[0].version + '.app')))

if (-not $packages) {
    throw "India GST package not found."
}

foreach ($package in $packages) {

    Write-Host "Inspecting $($package.Name)"

    $bytes = [System.IO.File]::ReadAllBytes($package.FullName)

    # Locate ZIP header inside BC .app package
    $zipOffset = -1

    for ($i = 0; $i -lt ($bytes.Length - 4); $i++) {

        if (
            $bytes[$i] -eq 0x50 -and
            $bytes[$i + 1] -eq 0x4B -and
            $bytes[$i + 2] -eq 0x03 -and
            $bytes[$i + 3] -eq 0x04
        ) {
            $zipOffset = $i
            break
        }
    }

    if ($zipOffset -lt 0) {
        throw "ZIP content not found inside .app package."
    }

    Write-Host "ZIP content starts at offset $zipOffset"

    $memoryStream = New-Object System.IO.MemoryStream

    try {

        $memoryStream.Write(
            $bytes,
            $zipOffset,
            $bytes.Length - $zipOffset
        )

        $memoryStream.Position = 0

        $archive = New-Object System.IO.Compression.ZipArchive(
            $memoryStream,
            [System.IO.Compression.ZipArchiveMode]::Read,
            $true
        )

        try {

            foreach ($caseId in $caseIds) {

                $entry = $archive.Entries |
                    Where-Object {
                        $_.FullName.ToLower().EndsWith(
                            "$caseId.json"
                        )
                    } |
                    Select-Object -First 1

                if ($null -eq $entry) {
                    throw "Case not found: $caseId"
                }

                $outputFile = Join-Path `
                    $outputFolder `
                    "$caseId.json"

                $entryStream = $entry.Open()

                try {
                    $fileStream = [System.IO.File]::Create(
                        $outputFile
                    )

                    try {
                        $entryStream.CopyTo($fileStream)
                    }
                    finally {
                        $fileStream.Dispose()
                    }
                }
                finally {
                    $entryStream.Dispose()
                }

                Write-Host "Extracted: $outputFile"
            }
        }
        finally {
            $archive.Dispose()
        }
    }
    finally {
        $memoryStream.Dispose()
    }
}

Write-Host ""
Write-Host "GST extraction completed."
Write-Host "Output: $outputFolder"
