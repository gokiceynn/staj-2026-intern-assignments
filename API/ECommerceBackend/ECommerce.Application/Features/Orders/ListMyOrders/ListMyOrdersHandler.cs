using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Orders.ListMyOrders;

public sealed class ListMyOrdersHandler(IAppDbContext db, ICurrentUser currentUser, IValidator<ListMyOrdersQuery> validator)
{
    public async Task<Result<ListMyOrdersResult>> HandleAsync(ListMyOrdersQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        if (error is not null) return Result<ListMyOrdersResult>.Failure(error);
        var source = db.Orders.AsNoTracking().Where(x => x.CustomerAccountId == currentUser.AccountId);
        if (!string.IsNullOrWhiteSpace(query.Status) && Enum.TryParse(query.Status, true, out OrderStatus status)) source = source.Where(x => x.Status == status);
        long total = await source.LongCountAsync(ct);
        var items = await source.OrderByDescending(x => x.CreatedAtUtc).Skip((query.Page - 1) * query.Size).Take(query.Size)
            .Select(x => new OrderListItemDto(x.Id, x.OrderNumber, x.TotalAmount, x.Currency, x.Status.ToString(), x.CreatedAtUtc, x.Items.Count, x.Packages.Count))
            .ToListAsync(ct);
        return Result<ListMyOrdersResult>.Success(new(new PagedResult<OrderListItemDto>(items, query.Page, query.Size, total)));
    }
}
