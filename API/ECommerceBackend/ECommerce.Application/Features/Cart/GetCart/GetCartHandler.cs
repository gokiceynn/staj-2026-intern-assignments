using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Cart.GetCart;
public sealed class GetCartHandler(ICartService cart, ICurrentUser currentUser)
{ public Task<Result<CartDto>> HandleAsync(GetCartQuery query, CancellationToken ct) => cart.GetAsync(currentUser.AccountId, ct); }
