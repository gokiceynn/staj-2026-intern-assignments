using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.SellerOrders.PreparePackage;
public sealed class PreparePackageHandler(ISellerOrderService service, ICurrentUser user)
{ public Task<Result<PackageTransitionResult>> HandleAsync(PreparePackageCommand command, CancellationToken ct) => service.PrepareAsync(user.AccountId, command.PackageId, ct); }
