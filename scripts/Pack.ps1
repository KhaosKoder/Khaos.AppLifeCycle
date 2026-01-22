<#
.SYNOPSIS
    Creates NuGet packages for the Khaos.AppLifecycle solution.

.DESCRIPTION
    Builds and packs the Khaos.AppLifecycle project into a NuGet package.

.PARAMETER Configuration
    Build configuration. Default is 'Release'.

.PARAMETER NoBuild
    Skip building and pack existing binaries.

.PARAMETER OutputDirectory
    Custom output directory for packages. Default is 'artifacts/nuget'.

.PARAMETER UseLocalKhaosTime
    Use local Khaos.Time source instead of NuGet package.

.EXAMPLE
    .\Pack.ps1
    .\Pack.ps1 -Configuration Debug
    .\Pack.ps1 -UseLocalKhaosTime
#>

[CmdletBinding()]
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',

    [switch]$NoBuild,

    [string]$OutputDirectory,

    [switch]$UseLocalKhaosTime
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not $OutputDirectory) {
    $OutputDirectory = Join-Path $repoRoot 'artifacts\nuget'
}
elseif (-not [System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory = Join-Path $repoRoot $OutputDirectory
}

if (-not (Test-Path $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
}

Write-Host ""
Write-Host "Packing Khaos.AppLifecycle to $OutputDirectory" -ForegroundColor Cyan
Write-Host ""

$project = Join-Path $repoRoot 'src\Khaos.AppLifecycle\Khaos.AppLifecycle.csproj'

Push-Location $repoRoot
try {
    $packArgs = @(
        'pack'
        $project
        '--configuration', $Configuration
        '--output', $OutputDirectory
        '--nologo'
        "-p:UseLocalKhaosTime=$($UseLocalKhaosTime.IsPresent)"
    )

    if ($NoBuild) {
        $packArgs += '--no-build'
    }

    dotnet @packArgs

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet pack failed with exit code $LASTEXITCODE"
    }

    Write-Host ""
    Write-Host "Package created in: $OutputDirectory" -ForegroundColor Green
}
finally {
    Pop-Location
}
