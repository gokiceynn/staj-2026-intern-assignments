using FluentValidation;
namespace ECommerce.Application.Features.Photos.UploadPhoto;
public sealed class UploadPhotoValidator : AbstractValidator<UploadPhotoCommand>
{
    private static readonly string[] Allowed = ["image/jpeg", "image/png", "image/webp"];
    public UploadPhotoValidator()
    {
        RuleFor(x => x.FileName).NotEmpty().MaximumLength(255);
        RuleFor(x => x.ContentType).Must(x => Allowed.Contains(x, StringComparer.OrdinalIgnoreCase));
        RuleFor(x => x.Length).GreaterThan(0).LessThanOrEqualTo(5 * 1024 * 1024);
        RuleFor(x => x.Content).NotNull().Must(x => x.CanRead);
    }
}
