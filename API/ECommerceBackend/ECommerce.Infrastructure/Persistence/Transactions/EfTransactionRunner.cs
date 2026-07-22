using System.Data;
using ECommerce.Application.Common.Abstractions;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Infrastructure.Persistence.Transactions;

public sealed class EfTransactionRunner(AppDbContext db) : ITransactionRunner
{
    public Task<T> ExecuteAsync<T>(Func<CancellationToken, Task<T>> operation, IsolationLevel isolationLevel, CancellationToken cancellationToken)
    {
        var strategy = db.Database.CreateExecutionStrategy();
        return strategy.ExecuteAsync(async () =>
        {
            await using var transaction = await db.Database.BeginTransactionAsync(isolationLevel, cancellationToken);
            try
            {
                T result = await operation(cancellationToken);
                await transaction.CommitAsync(cancellationToken);
                return result;
            }
            catch
            {
                await transaction.RollbackAsync(CancellationToken.None);
                throw;
            }
        });
    }
}
