using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;

namespace ECommerce.Application.Common.Abstractions;

public interface IAdminQueryService
{
    Task<Result<AdminDashboardDto>> GetDashboardAsync(
        DateTime? from,
        DateTime? to,
        CancellationToken ct
    );
    Task<Result<PagedResult<AdminUserListItem>>> ListUsersAsync(
        int page,
        int size,
        string? q,
        string? role,
        bool? isActive,
        CancellationToken ct
    );
    Task<Result<AdminUserDetail>> GetUserAsync(string id, CancellationToken ct);
    Task<Result<PagedResult<AdminSellerListItem>>> ListSellersAsync(
        int page,
        int size,
        string? q,
        bool? isActive,
        CancellationToken ct
    );
    Task<Result<AdminSellerDetail>> GetSellerAsync(string id, CancellationToken ct);
    Task<Result<PagedResult<AdminOrderListItem>>> ListOrdersAsync(
        int page,
        int size,
        string? status,
        DateTime? from,
        DateTime? to,
        CancellationToken ct
    );
    Task<Result<AdminOrderDetail>> GetOrderAsync(string id, CancellationToken ct);
    Task<Result<IReadOnlyList<AdminShippingCarrierDto>>> ListCarriersAsync(CancellationToken ct);
    Task<Result<AdminShippingCarrierDto>> GetCarrierAsync(string id, CancellationToken ct);
}

