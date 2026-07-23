using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.SellerProducts.UpdateSellerProduct;
public sealed class UpdateSellerProductHandler(ISellerProductService service, ICurrentUser user, IValidator<UpdateSellerProductCommand> validator)
{
    public async Task<Result<SellerProductDetail>> HandleAsync(UpdateSellerProductCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        ProductWriteModel model = new(command.Title, command.Description, command.Price, command.Stock, command.CategoryId, command.PhotoIds, command.Features, command.IsActive);
        return error is null ? await service.UpdateAsync(user.AccountId, command.Id, model, ct) : Result<SellerProductDetail>.Failure(error);
    }
}
