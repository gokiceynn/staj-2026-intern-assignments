using FluentValidation;
namespace ECommerce.Application.Features.Orders.Checkout;
public sealed class CheckoutValidator : AbstractValidator<CheckoutCommand>
{
    public CheckoutValidator()
    {
        RuleFor(x => x.AddressId).NotEmpty().MaximumLength(40);
        RuleFor(x => x.IdempotencyKey).NotEmpty().MaximumLength(100).Matches("^[A-Za-z0-9_-]+$");
        RuleFor(x => x.PaymentCard.CardHolderName).NotEmpty().MaximumLength(150);
        RuleFor(x => x.PaymentCard.CardNumber).CreditCard();
        RuleFor(x => x.PaymentCard.ExpiryMonth).InclusiveBetween(1, 12);
        RuleFor(x => x.PaymentCard.Cvv).Matches("^[0-9]{3,4}$");
    }
}
