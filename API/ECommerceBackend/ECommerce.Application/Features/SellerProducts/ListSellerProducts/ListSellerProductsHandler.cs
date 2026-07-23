using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.SellerProducts.ListSellerProducts;
public sealed class ListSellerProductsHandler(ISellerProductService service, ICurrentUser user, IValidator<ListSellerProductsQuery> validator)
{
    public async Task<Result<SellerProductPage>> HandleAsync(ListSellerProductsQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        return error is null ? await service.ListAsync(user.AccountId, query.Page, query.Size, query.Q, query.IsActive, ct) : Result<SellerProductPage>.Failure(error);
    }
}
