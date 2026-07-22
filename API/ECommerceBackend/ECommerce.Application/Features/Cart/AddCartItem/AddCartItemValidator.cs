using FluentValidation;
namespace ECommerce.Application.Features.Cart.AddCartItem;
public sealed class AddCartItemValidator : AbstractValidator<AddCartItemCommand>
{ public AddCartItemValidator() { RuleFor(x => x.ProductId).NotEmpty().MaximumLength(40); RuleFor(x => x.Quantity).InclusiveBetween(1, 99); } }
