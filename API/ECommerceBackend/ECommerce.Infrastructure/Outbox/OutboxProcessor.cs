using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
namespace ECommerce.Infrastructure.Outbox;
public sealed class OutboxProcessor(IServiceScopeFactory scopes, ILogger<OutboxProcessor> logger) : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using PeriodicTimer timer = new(TimeSpan.FromSeconds(2));
        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try { await ProcessBatchAsync(stoppingToken); }
            catch (Exception ex) { logger.LogError(ex, "Outbox batch failed."); }
        }
    }

    private async Task ProcessBatchAsync(CancellationToken ct)
    {
        using IServiceScope scope = scopes.CreateScope();
        AppDbContext db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        IOutboxMessageDispatcher dispatcher = scope.ServiceProvider.GetRequiredService<IOutboxMessageDispatcher>();
        DateTime now = DateTime.UtcNow; string lockId = Guid.NewGuid().ToString("N");
        // EnableRetryOnFailure devrede olduğu için elle açılan transaction'lar execution
        // strategy'nin içinden çalıştırılmalı; aksi halde EF InvalidOperationException atar.
        // Aynı desen EfTransactionRunner'da da kullanılıyor.
        var strategy = db.Database.CreateExecutionStrategy();
        List<OutboxMessage> batch = await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await db.Database.BeginTransactionAsync(ct);
            List<OutboxMessage> claimed = await db.OutboxMessages.FromSqlInterpolated($@"
                SELECT * FROM outbox_messages
                WHERE (status = {(int)OutboxStatus.Pending} AND (next_attempt_at_utc IS NULL OR next_attempt_at_utc <= {now}))
                   OR (status = {(int)OutboxStatus.Processing} AND locked_until_utc < {now})
                ORDER BY created_at_utc LIMIT 20 FOR UPDATE SKIP LOCKED").ToListAsync(ct);
            foreach (OutboxMessage item in claimed)
            { item.Status = OutboxStatus.Processing; item.LockId = lockId; item.LockedUntilUtc = now.AddMinutes(2); }
            await db.SaveChangesAsync(ct); await tx.CommitAsync(ct);
            return claimed;
        });

        foreach (OutboxMessage item in batch)
        {
            try
            {
                await dispatcher.DispatchAsync(item, ct);
                item.Status = OutboxStatus.Completed;
                item.ProcessedAtUtc = DateTime.UtcNow;
                item.LockId = null;
                item.LockedUntilUtc = null;
            }
            catch (Exception ex)
            {
                item.AttemptCount++;
                item.LastError = ex.GetType().Name;
                item.Status = item.AttemptCount >= 10 ? OutboxStatus.DeadLetter : OutboxStatus.Pending;
                item.NextAttemptAtUtc = DateTime.UtcNow.AddSeconds(Math.Min(3600, Math.Pow(2, item.AttemptCount)));
                item.LockId = null;
                item.LockedUntilUtc = null;
            }
            await db.SaveChangesAsync(ct);
        }
    }
}
