using System.Data;

namespace ECommerce.Application.Common.Abstractions;

public interface ITransactionRunner
{
    Task<T> ExecuteAsync<T>(
        Func<CancellationToken, Task<T>> operation,
        IsolationLevel isolationLevel,
        CancellationToken cancellationToken);
}
