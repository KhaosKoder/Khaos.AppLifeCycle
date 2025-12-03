# Build, Test, Coverage, and Release Guide

Everything below assumes execution from the repository root (`C:\My\Code\POC\Khaos.AppLifeCycle`). Test artifacts continue to live under `TestResults/`, while NuGet packages are written to `artifacts/`.

## Prerequisites

- .NET SDK 8.0 (or newer) for multi-target builds.
- PowerShell 5.1+ (the default shell) for helper scripts under `scripts/`.
- Local dotnet tools restored (`dotnet tool restore`).

## Helper Scripts

The `scripts/` folder contains wrappers that set the correct working directory so each script can be run in-place:

| Task | Command | Output |
| --- | --- | --- |
| Deep clean bin/obj/.vs/TestResults/artifacts | `powershell -ExecutionPolicy Bypass -File .\scripts\Clean-All.ps1` | Removes `bin/`, `obj/`, `.vs/`, `TestResults/`, `artifacts/` |
| Build solution | `powershell -ExecutionPolicy Bypass -File .\scripts\Build.ps1 [-Configuration Release]` | Standard MSBuild output in `bin/obj` |
| Run tests + emit TRX | `powershell -ExecutionPolicy Bypass -File .\scripts\Test.ps1 [-Configuration Release]` | `TestResults/trx/Tests.trx` |
| Coverage run | `powershell -ExecutionPolicy Bypass -File .\scripts\GenerateCoverage.ps1 [-Open]` | `TestResults/raw`, `TestResults/coverage` |
| Pack NuGet | `powershell -ExecutionPolicy Bypass -File .\scripts\Pack.ps1 [-Configuration Release] [-UseLocalKhaosTime]` | `artifacts/nuget/*.nupkg` |
| Publish package | `powershell -ExecutionPolicy Bypass -File .\scripts\Publish.ps1 -ApiKey <KEY> [-Source <feed>]` | Pushes latest `artifacts/nuget/*.nupkg` |

### Khaos.Time Dependency Toggle

`Khaos.AppLifecycle` depends on `Khaos.Time`. During local development we normally build both repos side-by-side, so the library defaults to referencing the project at `src/Khaos.Time`. Set the MSBuild property `UseLocalKhaosTime=false` (or run `Pack.ps1` without the `-UseLocalKhaosTime` switch) to consume the published `KhaosCode.Time` NuGet package instead—this is what CI and release builds use. You can pass the property via CLI (`dotnet build /p:UseLocalKhaosTime=false`) or environment variable `UseLocalKhaosTime=false`.

## Cleaning the Workspace

| Task | Command |
| --- | --- |
| Standard clean | `dotnet clean` |
| Release clean | `dotnet clean -c Release` |
| Deep clean (bin/obj/.vs/TestResults) | `powershell -ExecutionPolicy Bypass -File .\scripts\Clean-All.ps1` |
| Git hard clean (removes ALL untracked files) | `git clean -xdf` |
| Remove only prior test results | `Remove-Item .\TestResults -Recurse -Force` |

## Building

| Scenario | Command |
| --- | --- |
| Restore dependencies | `dotnet restore` |
| Build everything (Debug) | `dotnet build` |
| Build everything (Release) | `dotnet build -c Release` |
| Build the solution explicitly | `dotnet build Khaos.AppLifecycle.sln -c Release` |
| Build only the library | `dotnet build src/Khaos.AppLifecycle/Khaos.AppLifecycle.csproj` |
| Build the sample web app | `dotnet build samples/Khaos.AppLifecycle.SampleWebApp/Khaos.AppLifecycle.SampleWebApp.csproj` |
| Publish the sample to `publish/SampleWebApp` | `dotnet publish samples/Khaos.AppLifecycle.SampleWebApp/Khaos.AppLifecycle.SampleWebApp.csproj -c Release -o publish/SampleWebApp` |

### Front-end Builds

This repo does not include a standalone front-end yet, but if you introduce one under `samples/Frontend`, a typical workflow would be:

```powershell
cd samples/Frontend
npm install
npm run build                # outputs dist/
Copy-Item dist/* ..\Khaos.AppLifecycle.SampleWebApp\wwwroot -Recurse -Force
```

## Testing

| Goal | Command |
| --- | --- |
| Default unit tests | `dotnet test` |
| Release-config tests | `dotnet test -c Release` |
| Emit TRX test log | `dotnet test --logger:"trx;LogFileName=TestResults.trx" --results-directory TestResults\trx` |
| View TRX in browser/editor | `Start-Process (Resolve-Path .\TestResults\trx\TestResults.trx)` |
| Generate HTML test log | `dotnet test --logger:"html;LogFileName=TestResults.html" --results-directory TestResults\html` |
| Open HTML test log | `Start-Process (Resolve-Path .\TestResults\html\TestResults.html)` |

## Code Coverage

### One-liner Script

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\GenerateCoverage.ps1 -Open
```

The script:

1. Wipes `TestResults/raw` and `TestResults/coverage`.
2. Runs `dotnet test --collect:"XPlat Code Coverage" --results-directory TestResults/raw`.
3. Restores tools and executes `dotnet tool run reportgenerator -reports:"TestResults/raw/**/coverage.cobertura.xml" -targetdir:"TestResults/coverage" -reporttypes:"Html;Cobertura"`.
4. Opens `TestResults/coverage/index.html` when `-Open` is supplied.

### Manual Commands

```powershell
dotnet test --collect:"XPlat Code Coverage" --results-directory TestResults/raw
dotnet tool restore
dotnet tool run reportgenerator `
    -reports:"TestResults/raw/**/coverage.cobertura.xml" `
    -targetdir:"TestResults/coverage" `
    -reporttypes:"Html;Cobertura"
Start-Process (Resolve-Path .\TestResults\coverage\index.html)
```

## Packaging & Publishing

| Task | Command |
| --- | --- |
| Build Release bits | `dotnet build -c Release` |
| Pack NuGet (drops into `artifacts/nuget`) | `dotnet pack src/Khaos.AppLifecycle/Khaos.AppLifecycle.csproj -c Release -p:UseLocalKhaosTime=false -o artifacts/nuget` |
| Inspect `.nupkg` | `tar -tf artifacts/nuget/KhaosCode.AppLifecycle.<version>.nupkg` |
| Push to NuGet.org | `dotnet nuget push artifacts/nuget/KhaosCode.AppLifecycle.<version>.nupkg --api-key <KEY> --source https://api.nuget.org/v3/index.json --skip-duplicate` |

> Tip: `Pack.ps1` (run without `-UseLocalKhaosTime`) sets `UseLocalKhaosTime=false` for you, and `Publish.ps1` simply pushes whatever is under `artifacts/nuget`.

## Useful Extras

- Format code: `dotnet format`.
- List installed tools: `dotnet tool list`.
- Update tools: `dotnet tool restore` (already part of coverage script).
- Rebuild everything after cleaning: `dotnet clean && dotnet build`.
- Build + test + pack (Release) in one go:

  ```powershell
  dotnet restore
  dotnet build -c Release
  dotnet test -c Release
  dotnet pack src/Khaos.AppLifecycle/Khaos.AppLifecycle.csproj -c Release -p:UseLocalKhaosTime=false -o artifacts/nuget
  ```

## Viewing Results in a Browser

- Coverage: `Start-Process (Resolve-Path .\TestResults\coverage\index.html)`.
- HTML test log (if generated): `Start-Process (Resolve-Path .\TestResults\html\TestResults.html)`.

## Automation Checklist

1. `dotnet restore`
2. `dotnet build -c Release`
3. `dotnet test --collect:"XPlat Code Coverage" --results-directory TestResults/raw`
4. `dotnet tool run reportgenerator ...`
5. `dotnet pack src/Khaos.AppLifecycle/Khaos.AppLifecycle.csproj -c Release -p:UseLocalKhaosTime=false -o artifacts/nuget`
6. Optional: `dotnet nuget push artifacts/nuget/KhaosCode.AppLifecycle.<version>.nupkg ...`

Cache `~/.nuget/packages`, `.config/dotnet-tools.json`, and the `TestResults` folder if CI artifacts are retained between runs.
