namespace ECommerce.Api.Contracts.V1;
public sealed record PaymentCardRequest(string CardHolderName, string CardNumber, int ExpireMonth, int ExpireYear, string Cvv);
public sealed record SimulatePaymentRequest(decimal Amount, PaymentCardRequest PaymentCard);
public sealed record CheckoutRequest(string AddressId, PaymentCardRequest PaymentCard);
public sealed record CancelOrderRequest(string CancelReason);
