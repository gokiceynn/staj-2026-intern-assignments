using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.SellerOrders.ShipPackage;
public sealed class ShipPackageHandler(ISellerOrderService service, ICurrentUser user, IValidator<ShipPackageCommand> validator)
{
    public async Task<Result<PackageTransitionResult>> HandleAsync(ShipPackageCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is null ? await service.ShipAsync(user.AccountId, command.PackageId, command.CarrierId, command.TrackingNumber, ct) : Result<PackageTransitionResult>.Failure(error);
    }
}
