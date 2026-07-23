using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.SellerProducts.GetSellerProduct;
public sealed class GetSellerProductHandler(ISellerProductService service, ICurrentUser user)
{ public Task<Result<SellerProductDetail>> HandleAsync(GetSellerProductQuery query, CancellationToken ct) => service.GetAsync(user.AccountId, query.Id, ct); }
