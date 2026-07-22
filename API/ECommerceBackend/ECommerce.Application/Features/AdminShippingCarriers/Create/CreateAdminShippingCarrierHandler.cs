using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Application.Features.Admin;
using FluentValidation;
namespace ECommerce.Application.Features.AdminShippingCarriers.Create;
public sealed class CreateAdminShippingCarrierHandler(
    IShippingCarrierAdminService service, ICurrentUser user, IValidator<CreateAdminShippingCarrierCommand> validator)
{
    public async Task<Result<AdminShippingCarrierDto>> HandleAsync(CreateAdminShippingCarrierCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        ShippingCarrierWriteModel model = new(command.Name, command.Code, command.LogoId, command.FlatFee,
            command.EstimatedDeliveryDays, command.TrackingUrlTemplate, command.IsActive);
        return error is null ? await service.CreateAsync(model, user.AccountId, ct) : Result<AdminShippingCarrierDto>.Failure(error);
    }
}
