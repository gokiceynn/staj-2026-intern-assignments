using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.AdminShippingCarriers.Delete;
public sealed class DeleteAdminShippingCarrierHandler(IShippingCarrierAdminService service, ICurrentUser user)
{ public Task<Result> HandleAsync(DeleteAdminShippingCarrierCommand command, CancellationToken ct) => service.DeleteAsync(command.Id, user.AccountId, ct); }
