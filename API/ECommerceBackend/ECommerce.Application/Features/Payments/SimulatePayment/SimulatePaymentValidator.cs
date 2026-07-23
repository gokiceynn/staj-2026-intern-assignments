using ECommerce.Application.Common.Abstractions;
using FluentValidation;
namespace ECommerce.Application.Features.Payments.SimulatePayment;
public sealed class SimulatePaymentValidator : AbstractValidator<SimulatePaymentCommand>
{
    public SimulatePaymentValidator(IClock clock)
    {
        RuleFor(x => x.Amount).GreaterThan(0).LessThanOrEqualTo(1_000_000);
        RuleFor(x => x.PaymentCard.CardHolderName).NotEmpty().MaximumLength(150);
        RuleFor(x => x.PaymentCard.CardNumber).CreditCard();
        RuleFor(x => x.PaymentCard.ExpiryMonth).InclusiveBetween(1, 12);
        RuleFor(x => x.PaymentCard.ExpiryYear).InclusiveBetween(clock.UtcNow.Year, clock.UtcNow.Year + 20);
        RuleFor(x => x.PaymentCard.Cvv).Matches("^[0-9]{3,4}$");
    }
}
