param(
    [string] $Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resultsDir = Join-Path $root 'TestResults/trx'

Push-Location $root
try {
    if (-not (Test-Path $resultsDir)) {
        New-Item -ItemType Directory -Path $resultsDir | Out-Null
    }

    Write-Host "Running tests in $Configuration configuration..."
    dotnet test .\Khaos.AppLifecycle.sln -c $Configuration --logger:"trx;LogFileName=Tests.trx" --results-directory $resultsDir
}
finally {
    Pop-Location
}
