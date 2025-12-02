$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

Push-Location $root
try {
    Write-Host "Cleaning solution via dotnet clean"
    dotnet clean .\Khaos.AppLifecycle.sln

    function Remove-Directories([string]$pattern) {
        Get-ChildItem -Path $root -Include $pattern -Recurse -Directory -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-Host "Removing" $_.FullName
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
    }

    Remove-Directories 'bin'
    Remove-Directories 'obj'

    $vsFolder = Join-Path $root '.vs'
    if (Test-Path $vsFolder) {
        Write-Host "Removing $vsFolder"
        Remove-Item $vsFolder -Recurse -Force
    }

    $testResults = Join-Path $root 'TestResults'
    if (Test-Path $testResults) {
        Write-Host "Removing $testResults"
        Remove-Item $testResults -Recurse -Force
    }

    $artifacts = Join-Path $root 'artifacts'
    if (Test-Path $artifacts) {
        Write-Host "Removing $artifacts"
        Remove-Item $artifacts -Recurse -Force
    }

    Write-Host "Clean complete."
}
finally {
    Pop-Location
}