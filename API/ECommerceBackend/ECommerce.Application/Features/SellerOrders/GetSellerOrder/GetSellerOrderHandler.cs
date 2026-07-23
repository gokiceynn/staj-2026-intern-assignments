using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.SellerOrders.GetSellerOrder;
public sealed class GetSellerOrderHandler(ISellerOrderService service, ICurrentUser user)
{ public Task<Result<SellerPackageDetail>> HandleAsync(GetSellerOrderQuery query, CancellationToken ct) => service.GetAsync(user.AccountId, query.PackageId, ct); }
