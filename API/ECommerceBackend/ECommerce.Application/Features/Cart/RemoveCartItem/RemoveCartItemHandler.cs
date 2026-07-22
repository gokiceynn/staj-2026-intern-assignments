using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Cart.RemoveCartItem;
public sealed class RemoveCartItemHandler(ICartService cart, ICurrentUser currentUser)
{ public Task<Result<CartDto>> HandleAsync(RemoveCartItemCommand command, CancellationToken ct) => cart.RemoveAsync(currentUser.AccountId, command.ProductId, ct); }
