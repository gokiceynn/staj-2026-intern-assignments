using FluentValidation;
namespace ECommerce.Application.Features.SellerProducts.ListSellerProducts;
public sealed class ListSellerProductsValidator : AbstractValidator<ListSellerProductsQuery>
{ public ListSellerProductsValidator() { RuleFor(x => x.Page).GreaterThan(0); RuleFor(x => x.Size).InclusiveBetween(1, 100); RuleFor(x => x.Q).MaximumLength(200); } }
