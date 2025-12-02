using System;
using System.Threading.Tasks;
using Khaos.AppLifecycle;
using Khaos.AppLifecycle.Flows;
using Khaos.AppLifecycle.Hosting;
using Khaos.AppLifecycle.Scheduling;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationLifecycleManager(options =>
{
	options.Startup.Flow("Bootstrap")
		.BeginWith<WarmupCacheStep>()
		.EndFlow();

	options.Shutdown.Flow("Cleanup")
		.BeginWith<FlushMetricsStep>()
		.EndFlow();

	options.Scheduled.Flow("Heartbeat")
		.OnSchedule<HalfMinuteTrigger>()
		.NoOverlap()
		.BeginWith<HeartbeatStep>()
		.EndFlow();

		options.Events.Configure(events =>
		{
			events.StartupStepExecuted += args =>
			{
				Console.WriteLine($"[{args.Section}] {args.FlowName}:{args.StepType.Name} => {args.Outcome}");
				return Task.CompletedTask;
			};
		});
});

builder.Services.AddTransient<WarmupCacheStep>();
builder.Services.AddTransient<FlushMetricsStep>();
builder.Services.AddTransient<HeartbeatStep>();
builder.Services.AddTransient<HalfMinuteTrigger>();

var app = builder.Build();

app.UseApplicationLifecycleManager();

app.MapGet("/", () => "Khaos.AppLifecycle sample is running.");

app.Run();

sealed class WarmupCacheStep : IFlowStep<StartupContext>
{
	public Task<FlowOutcome> ExecuteAsync(StartupContext context, CancellationToken cancellationToken)
	{
		// Pretend to warm caches or call remote services.
		return Task.FromResult(FlowOutcome.Success);
	}
}

sealed class FlushMetricsStep : IFlowStep<ShutdownContext>
{
	public Task<FlowOutcome> ExecuteAsync(ShutdownContext context, CancellationToken cancellationToken)
	{
		// Flush metrics/telemetry before shutdown.
		return Task.FromResult(FlowOutcome.Success);
	}
}

sealed class HeartbeatStep : IFlowStep<ScheduledContext>
{
	public Task<FlowOutcome> ExecuteAsync(ScheduledContext context, CancellationToken cancellationToken)
	{
		// Record application heartbeat.
		return Task.FromResult(FlowOutcome.Success);
	}
}

sealed class HalfMinuteTrigger : IScheduleTrigger
{
	public Task<TimeSpan> GetNextDelayAsync(ScheduledContext context, CancellationToken cancellationToken)
		=> Task.FromResult(TimeSpan.FromSeconds(30));
}
