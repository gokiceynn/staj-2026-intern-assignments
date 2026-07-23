using FluentValidation;
namespace ECommerce.Application.Features.Orders.CancelOrder;
public sealed class CancelOrderValidator : AbstractValidator<CancelOrderCommand>
{ public CancelOrderValidator() { RuleFor(x => x.Id).NotEmpty(); RuleFor(x => x.CancelReason).NotEmpty().MaximumLength(500); } }
