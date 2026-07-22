using FluentValidation;
namespace ECommerce.Application.Features.Cart.UpdateCartItem;
public sealed class UpdateCartItemValidator : AbstractValidator<UpdateCartItemCommand>
{ public UpdateCartItemValidator() { RuleFor(x => x.ProductId).NotEmpty().MaximumLength(40); RuleFor(x => x.Quantity).InclusiveBetween(1, 99); } }
