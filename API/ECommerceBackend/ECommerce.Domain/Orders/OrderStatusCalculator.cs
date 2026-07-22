using ECommerce.Domain.Common.Enums;
namespace ECommerce.Domain.Orders;
public static class OrderStatusCalculator
{
    public static OrderStatus Calculate(IReadOnlyCollection<PackageStatus> states) =>
        states.All(x => x == PackageStatus.Delivered) ? OrderStatus.Delivered
        : states.Any(x => x == PackageStatus.Delivered) ? OrderStatus.PartiallyDelivered
        : states.All(x => x == PackageStatus.Shipped) ? OrderStatus.Shipped
        : states.Any(x => x == PackageStatus.Shipped) ? OrderStatus.PartiallyShipped
        : states.All(x => x == PackageStatus.Cancelled) ? OrderStatus.Cancelled
        : states.Any(x => x == PackageStatus.Cancelled) ? OrderStatus.PartiallyCancelled
        : states.Any(x => x == PackageStatus.Preparing) ? OrderStatus.Preparing : OrderStatus.Paid;
}
