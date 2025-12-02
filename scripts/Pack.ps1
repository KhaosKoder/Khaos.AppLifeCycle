param(
    [string] $Configuration = 'Release',
    [string] $OutputDirectory = 'artifacts/nuget'
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$project = Join-Path $root 'src/Khaos.AppLifecycle/Khaos.AppLifecycle.csproj'
$outputPath = Join-Path $root $OutputDirectory

Push-Location $root
try {
    if (-not (Test-Path $outputPath)) {
        New-Item -ItemType Directory -Path $outputPath | Out-Null
    }

    Write-Host "Packing $project in $Configuration configuration to $outputPath"
    dotnet pack $project -c $Configuration -o $outputPath
}
finally {
    Pop-Location
}
