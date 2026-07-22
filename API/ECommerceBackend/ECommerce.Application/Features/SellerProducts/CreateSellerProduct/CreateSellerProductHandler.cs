using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
namespace ECommerce.Application.Features.SellerProducts.CreateSellerProduct;
public sealed class CreateSellerProductHandler(ISellerProductService service, ICurrentUser user, IValidator<CreateSellerProductCommand> validator)
{
    public async Task<Result<SellerProductDetail>> HandleAsync(CreateSellerProductCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        ProductWriteModel model = new(command.Title, command.Description, command.Price, command.Stock, command.CategoryId, command.PhotoIds, command.Features, command.IsActive);
        return error is null ? await service.CreateAsync(user.AccountId, model, ct) : Result<SellerProductDetail>.Failure(error);
    }
}
