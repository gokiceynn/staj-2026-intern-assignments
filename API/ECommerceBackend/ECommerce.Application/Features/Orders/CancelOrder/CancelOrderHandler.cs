using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.Orders.CancelOrder;
public sealed class CancelOrderHandler(IOrderService orders, ICurrentUser currentUser, IValidator<CancelOrderCommand> validator)
{
    public async Task<Result<CancelOrderResult>> HandleAsync(CancelOrderCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is null ? await orders.CancelAsync(currentUser.AccountId, command.Id, command.CancelReason.Trim(), ct) : Result<CancelOrderResult>.Failure(error);
    }
}
