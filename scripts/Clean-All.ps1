$ErrorActionPreference = 'Stop'
$root = Resolve-Path (Join-Path $PSScriptRoot '..')

Write-Host "Cleaning solution via dotnet clean"
dotnet clean $root

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

Write-Host "Clean complete."