using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.SellerOrders.ListSellerOrders;
public sealed class ListSellerOrdersHandler(ISellerOrderService service, ICurrentUser user, IValidator<ListSellerOrdersQuery> validator)
{
    public async Task<Result<SellerPackagePage>> HandleAsync(ListSellerOrdersQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        return error is null ? await service.ListAsync(user.AccountId, query.Page, query.Size, query.Status, query.From, query.To, ct) : Result<SellerPackagePage>.Failure(error);
    }
}
