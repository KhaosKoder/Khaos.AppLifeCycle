param(
    [switch] $Open
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$resultsRoot = Join-Path $root 'TestResults'
$rawDir = Join-Path $resultsRoot 'raw'
$coverageDir = Join-Path $resultsRoot 'coverage'

Push-Location $root
try {
    Write-Host "Cleaning previous coverage artifacts..."
    if (Test-Path $rawDir) { Remove-Item $rawDir -Recurse -Force }
    if (Test-Path $coverageDir) { Remove-Item $coverageDir -Recurse -Force }

    Write-Host "Running tests with coverage into $rawDir"
    dotnet test --collect:"XPlat Code Coverage" --results-directory $rawDir

    Write-Host "Restoring dotnet tools"
    dotnet tool restore

    Write-Host "Generating HTML + Cobertura reports into $coverageDir"
    dotnet tool run reportgenerator `
        -reports:"$rawDir/**/coverage.cobertura.xml" `
        -targetdir:"$coverageDir" `
        -reporttypes:"Html;Cobertura"

    if ($Open) {
        $indexPath = Join-Path $coverageDir 'index.html'
        if (Test-Path $indexPath) {
            Write-Host "Opening coverage report: $indexPath"
            Start-Process $indexPath
        }
        else {
            Write-Warning "Coverage index not found at $indexPath"
        }
    }
}
finally {
    Pop-Location
}
