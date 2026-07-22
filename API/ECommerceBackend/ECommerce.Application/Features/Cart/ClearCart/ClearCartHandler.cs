using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Cart.ClearCart;
public sealed class ClearCartHandler(ICartService cart, ICurrentUser currentUser)
{ public Task<Result> HandleAsync(ClearCartCommand command, CancellationToken ct) => cart.ClearAsync(currentUser.AccountId, ct); }
