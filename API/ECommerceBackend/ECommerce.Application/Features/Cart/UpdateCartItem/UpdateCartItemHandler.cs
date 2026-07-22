using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.Cart.UpdateCartItem;
public sealed class UpdateCartItemHandler(ICartService cart, ICurrentUser currentUser, IValidator<UpdateCartItemCommand> validator)
{
    public async Task<Result<CartDto>> HandleAsync(UpdateCartItemCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is null ? await cart.UpdateAsync(currentUser.AccountId, command.ProductId, command.Quantity, ct) : Result<CartDto>.Failure(error);
    }
}
