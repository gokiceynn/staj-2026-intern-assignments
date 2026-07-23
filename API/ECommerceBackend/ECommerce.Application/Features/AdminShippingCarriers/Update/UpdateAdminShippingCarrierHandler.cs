using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Application.Features.Admin;
using FluentValidation;
namespace ECommerce.Application.Features.AdminShippingCarriers.Update;
public sealed class UpdateAdminShippingCarrierHandler(
    IShippingCarrierAdminService service, ICurrentUser user, IValidator<UpdateAdminShippingCarrierCommand> validator)
{
    public async Task<Result<AdminShippingCarrierDto>> HandleAsync(UpdateAdminShippingCarrierCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        ShippingCarrierWriteModel model = new(command.Name, command.Code, command.LogoId, command.FlatFee,
            command.EstimatedDeliveryDays, command.TrackingUrlTemplate, command.IsActive);
        return error is null ? await service.UpdateAsync(command.Id, model, user.AccountId, ct) : Result<AdminShippingCarrierDto>.Failure(error);
    }
}
