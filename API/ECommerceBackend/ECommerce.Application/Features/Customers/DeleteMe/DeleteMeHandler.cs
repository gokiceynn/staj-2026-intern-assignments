using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Customers.DeleteMe;

public sealed class DeleteMeHandler(
    IAccountCredentialService credentials, ICurrentUser currentUser, IValidator<DeleteMeCommand> validator)
{
    public async Task<Result> HandleAsync(DeleteMeCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is not null
            ? Result.Failure(error)
            : await credentials.DeleteCustomerAsync(currentUser.AccountId, command.Password, currentUser.IpAddress, ct);
    }
}
