# Khaos.AppLifecycle

Opinionated lifecycle manager for ASP.NET Core and generic host applications.

## Features

- Startup and shutdown flows that wrap the host lifecycle
- Outcome-driven flow engine shared by startup, shutdown, and scheduled flows
- Lightweight in-process scheduler with conditional flows and optional overlap guards
- Async lifecycle events for visibility and telemetry
- NuGet content files that scaffold `AppLifecycle/*` folders in consuming projects

## Getting Started

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationLifecycleManager(options =>
{
    options.Startup.Flow("DefaultStartup")
        .BeginWith<WarmupServicesStep>()
        .EndFlow();

    options.Shutdown.Flow("DefaultShutdown")
        .BeginWith<FlushMetricsStep>()
        .EndFlow();

    options.Scheduled.Flow("HealthCheck")
        .OnSchedule<EvergreenTrigger>()
        .NoOverlap()
        .BeginWith<HealthProbeStep>()
        .EndFlow();
});

builder.Services.AddTransient<WarmupServicesStep>();
builder.Services.AddTransient<FlushMetricsStep>();
builder.Services.AddTransient<HealthProbeStep>();
builder.Services.AddTransient<EvergreenTrigger>();

var app = builder.Build();
app.UseApplicationLifecycleManager();
app.Run();
```

Implement steps by inheriting `IFlowStep<TContext>` (`StartupContext`, `ShutdownContext`, or `ScheduledContext`). Implement triggers by inheriting `IScheduleTrigger` and returning the desired delay between runs.

## Repository Layout

- `src/Khaos.AppLifecycle` – library implementation
- `tests/Khaos.AppLifecycle.Tests` – xUnit test suite for engine, DSL, scheduler, and integration scenarios
- `samples/Khaos.AppLifecycle.SampleWebApp` – minimal ASP.NET Core app showcasing startup/shutdown/scheduled flows
- `docs/Specification.md` – high-level design document

## Documentation

- [Specification](docs/Specification.md) – product goals, architecture, and flow diagrams
- [Usage Guide](docs/UsageGuide.md) – walkthrough for configuring flows, triggers, and events
- [Development Guide](docs/DevelopmentGuide.md) – conventions, tooling, and local workflows
- [Build & Release](docs/BuildAndRelease.md) – build, test, coverage, packaging, and publishing steps
- [Versioning Guide](docs/versioning-guide.md) – semantic versioning rules and MinVer tag strategy

## License

MIT
