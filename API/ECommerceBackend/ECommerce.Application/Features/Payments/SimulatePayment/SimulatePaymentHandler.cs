using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Payments.SimulatePayment;

public sealed class SimulatePaymentHandler(IPaymentGateway gateway, IClock clock, IValidator<SimulatePaymentCommand> validator)
{
    public async Task<Result<SimulatePaymentResult>> HandleAsync(SimulatePaymentCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<SimulatePaymentResult>.Failure(error);
        PaymentGatewayResult payment = await gateway.ProcessAsync(command.Amount, "TRY", command.PaymentCard, ct);
        return payment.IsSuccess
            ? Result<SimulatePaymentResult>.Success(new(payment.TransactionId, "Success", clock.UtcNow))
            : Result<SimulatePaymentResult>.Failure(new Error("PAYMENT_DECLINED", "The payment was declined."));
    }
}
