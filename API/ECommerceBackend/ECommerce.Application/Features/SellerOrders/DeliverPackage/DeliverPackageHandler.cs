using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.SellerOrders.DeliverPackage;
public sealed class DeliverPackageHandler(ISellerOrderService service, ICurrentUser user)
{ public Task<Result<PackageTransitionResult>> HandleAsync(DeliverPackageCommand command, CancellationToken ct) => service.DeliverAsync(user.AccountId, command.PackageId, ct); }
