using ECommerce.Domain.Operations;
namespace ECommerce.Infrastructure.Outbox;
public interface IOutboxMessageDispatcher { Task DispatchAsync(OutboxMessage message, CancellationToken ct); }
