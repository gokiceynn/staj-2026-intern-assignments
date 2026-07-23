using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Orders.Checkout;

public sealed class CheckoutHandler(IOrderService orders, ICurrentUser currentUser, IValidator<CheckoutCommand> validator)
{
    public async Task<Result<OrderDetailDto>> HandleAsync(CheckoutCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is null
            ? await orders.CheckoutAsync(currentUser.AccountId, command.AddressId, command.PaymentCard, command.IdempotencyKey, ct)
            : Result<OrderDetailDto>.Failure(error);
    }
}
