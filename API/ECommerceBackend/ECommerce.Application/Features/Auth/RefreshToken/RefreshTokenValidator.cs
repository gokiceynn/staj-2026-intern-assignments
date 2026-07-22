using FluentValidation;
namespace ECommerce.Application.Features.Auth.RefreshToken;
public sealed class RefreshTokenValidator : AbstractValidator<RefreshTokenCommand>
{
    public RefreshTokenValidator()
    {
        RuleFor(x => x.RefreshToken).NotEmpty().MaximumLength(512);
        RuleFor(x => x.ExpiredAccessToken).NotEmpty().MaximumLength(8192);
    }
}
