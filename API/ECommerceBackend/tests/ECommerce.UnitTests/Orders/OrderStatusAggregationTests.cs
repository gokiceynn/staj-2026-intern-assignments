using ECommerce.Domain.Common.Enums;
using Xunit;
namespace ECommerce.UnitTests.Orders;
public sealed class OrderStatusAggregationTests
{
    [Theory]
    [InlineData(PackageStatus.Paid, PackageStatus.Paid, OrderStatus.Paid)]
    [InlineData(PackageStatus.Preparing, PackageStatus.Paid, OrderStatus.Preparing)]
    [InlineData(PackageStatus.Shipped, PackageStatus.Paid, OrderStatus.PartiallyShipped)]
    [InlineData(PackageStatus.Shipped, PackageStatus.Shipped, OrderStatus.Shipped)]
    [InlineData(PackageStatus.Delivered, PackageStatus.Shipped, OrderStatus.PartiallyDelivered)]
    [InlineData(PackageStatus.Delivered, PackageStatus.Delivered, OrderStatus.Delivered)]
    [InlineData(PackageStatus.Cancelled, PackageStatus.Paid, OrderStatus.PartiallyCancelled)]
    [InlineData(PackageStatus.Cancelled, PackageStatus.Cancelled, OrderStatus.Cancelled)]
    public void Aggregate_IsDeterministic(PackageStatus first, PackageStatus second, OrderStatus expected) =>
        Assert.Equal(expected, ECommerce.Domain.Orders.OrderStatusCalculator.Calculate([first, second]));
}
