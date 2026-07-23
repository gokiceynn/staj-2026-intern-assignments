using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;

namespace ECommerce.Application.Features.Auth.RefreshToken;

public sealed class RefreshTokenHandler(
    IAuthenticationSessionService sessions, ICurrentUser requestContext, IValidator<RefreshTokenCommand> validator)
{
    public async Task<Result<RefreshTokenResult>> HandleAsync(RefreshTokenCommand command, CancellationToken ct)
    {
        Error? validationError = await validator.ValidateAsErrorAsync(command, ct);
        if (validationError is not null) return Result<RefreshTokenResult>.Failure(validationError);
        Result<TokenPair> result = await sessions.RotateAsync(
            command.RefreshToken, command.ExpiredAccessToken, requestContext.IpAddress, requestContext.UserAgent, ct);
        return result.IsSuccess
            ? Result<RefreshTokenResult>.Success(new(result.Value!.AccessToken, result.Value.AccessTokenExpiresAtUtc,
                result.Value.RefreshToken, result.Value.RefreshTokenExpiresAtUtc))
            : Result<RefreshTokenResult>.Failure(result.Error!);
    }
}
