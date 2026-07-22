using ECommerce.Application.Common.Models;
using ECommerce.Domain.Common.Enums;
namespace ECommerce.Application.Features.Metadata.GetStatuses;
public sealed class GetStatusesHandler
{
    public Task<Result<IReadOnlyList<StatusGroup>>> HandleAsync(GetStatusesQuery query, CancellationToken ct)
    {
        static IReadOnlyList<StatusItem> Map<T>() where T : struct, Enum => Enum.GetNames<T>()
            .Select(x => new StatusItem(x, x, null)).ToList();
        IReadOnlyList<StatusGroup> groups =
        [
            new("orders", Map<OrderStatus>()),
            new("packages", Map<PackageStatus>()),
            new("shipments", Map<ShipmentStatus>()),
            new("payments", Map<PaymentStatus>())
        ];
        return Task.FromResult(Result<IReadOnlyList<StatusGroup>>.Success(groups));
    }
}
