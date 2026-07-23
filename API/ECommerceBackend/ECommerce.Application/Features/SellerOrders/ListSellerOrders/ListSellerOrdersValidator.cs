using FluentValidation;
namespace ECommerce.Application.Features.SellerOrders.ListSellerOrders;
public sealed class ListSellerOrdersValidator : AbstractValidator<ListSellerOrdersQuery>
{
    public ListSellerOrdersValidator()
    {
        RuleFor(x => x.Page).GreaterThan(0); RuleFor(x => x.Size).InclusiveBetween(1, 100);
        RuleFor(x => x.To).GreaterThanOrEqualTo(x => x.From).When(x => x.From.HasValue && x.To.HasValue);
    }
}
