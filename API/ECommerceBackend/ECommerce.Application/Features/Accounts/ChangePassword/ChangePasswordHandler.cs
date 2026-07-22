using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Accounts.ChangePassword;

public sealed class ChangePasswordHandler(
    IAccountCredentialService credentials, ICurrentUser currentUser, IValidator<ChangePasswordCommand> validator)
{
    public async Task<Result> HandleAsync(ChangePasswordCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is not null
            ? Result.Failure(error)
            : await credentials.ChangePasswordAsync(currentUser.AccountId, command.CurrentPassword, command.NewPassword, currentUser.IpAddress, ct);
    }
}
