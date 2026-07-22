using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Cart;

namespace ECommerce.Application.Common.Abstractions;

public interface ICartService
{
    Task<Result<CartDto>> GetAsync(string accountId, CancellationToken ct);
    Task<Result<CartDto>> AddAsync(string accountId, string productId, int quantity, CancellationToken ct);
    Task<Result<CartDto>> UpdateAsync(string accountId, string productId, int quantity, CancellationToken ct);
    Task<Result<CartDto>> RemoveAsync(string accountId, string productId, CancellationToken ct);
    Task<Result> ClearAsync(string accountId, CancellationToken ct);
}
