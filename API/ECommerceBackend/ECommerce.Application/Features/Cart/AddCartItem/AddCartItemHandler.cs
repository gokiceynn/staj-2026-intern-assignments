using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.Cart.AddCartItem;
public sealed class AddCartItemHandler(ICartService cart, ICurrentUser currentUser, IValidator<AddCartItemCommand> validator)
{
    public async Task<Result<CartDto>> HandleAsync(AddCartItemCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is null ? await cart.AddAsync(currentUser.AccountId, command.ProductId, command.Quantity, ct) : Result<CartDto>.Failure(error);
    }
}
