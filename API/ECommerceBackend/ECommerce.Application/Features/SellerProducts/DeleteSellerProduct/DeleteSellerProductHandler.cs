using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.SellerProducts.DeleteSellerProduct;
public sealed class DeleteSellerProductHandler(ISellerProductService service, ICurrentUser user)
{ public Task<Result> HandleAsync(DeleteSellerProductCommand command, CancellationToken ct) => service.DeleteAsync(user.AccountId, command.Id, ct); }
