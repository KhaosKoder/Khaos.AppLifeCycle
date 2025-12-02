param(
    [string] $Configuration = 'Release'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $root
try {
    Write-Host "Restoring dependencies..."
    dotnet restore

    Write-Host "Building solution in $Configuration configuration..."
    dotnet build .\Khaos.AppLifecycle.sln -c $Configuration
}
finally {
    Pop-Location
}
