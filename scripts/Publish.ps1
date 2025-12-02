param(
    [string] $PackagePath,
    [string] $ApiKey,
    [string] $Source = 'https://api.nuget.org/v3/index.json',
    [string] $OutputDirectory = 'artifacts/nuget'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$outputPath = Join-Path $root $OutputDirectory

function Get-FullPath([string] $path) {
    if (-not $path) { return $null }
    $resolved = Resolve-Path -Path $path -ErrorAction SilentlyContinue
    if ($resolved) { return $resolved.Path }
    $combined = Join-Path $root $path
    $resolved = Resolve-Path -Path $combined -ErrorAction SilentlyContinue
    return $resolved?.Path
}

if (-not $PackagePath) {
    if (-not (Test-Path $outputPath)) {
        throw "No package path supplied and '$outputPath' does not exist. Run Pack.ps1 first."
    }

    $latest = Get-ChildItem -Path $outputPath -Filter '*.nupkg' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) {
        throw "No .nupkg files found under '$outputPath'."
    }

    $PackagePath = $latest.FullName
}
else {
    $resolvedPackage = Get-FullPath $PackagePath
    if (-not $resolvedPackage) {
        throw "Unable to locate package at '$PackagePath'."
    }
    $PackagePath = $resolvedPackage
}

if (-not $ApiKey) {
    $ApiKey = $env:NUGET_API_KEY
}

if (-not $ApiKey) {
    throw "Provide -ApiKey or set the NUGET_API_KEY environment variable."
}

function Resolve-Source([string] $source) {
    if (-not $source) { return $null }
    if ($source -match '^[a-zA-Z]+://') { return $source }

    $maybePath = Resolve-Path -Path $source -ErrorAction SilentlyContinue
    if ($maybePath) { return $maybePath.Path }

    $combined = Resolve-Path -Path (Join-Path $root $source) -ErrorAction SilentlyContinue
    if ($combined) { return $combined.Path }

    return $source
}

$resolvedSource = Resolve-Source $Source

Push-Location $root
try {
    Write-Host "Publishing package $PackagePath to $resolvedSource"
    dotnet nuget push $PackagePath --api-key $ApiKey --source $resolvedSource --skip-duplicate
}
finally {
    Pop-Location
}
