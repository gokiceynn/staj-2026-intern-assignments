using FluentValidation;
namespace ECommerce.Application.Features.Orders.ListMyOrders;
public sealed class ListMyOrdersValidator : AbstractValidator<ListMyOrdersQuery>
{
    public ListMyOrdersValidator() { RuleFor(x => x.Page).GreaterThan(0); RuleFor(x => x.Size).InclusiveBetween(1, 100); RuleFor(x => x.Status).MaximumLength(40); }
}
