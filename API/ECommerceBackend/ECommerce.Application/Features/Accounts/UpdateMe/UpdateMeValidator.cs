using FluentValidation;
namespace ECommerce.Application.Features.Accounts.UpdateMe;
public sealed class UpdateMeValidator : AbstractValidator<UpdateMeCommand>
{
    public UpdateMeValidator()
    {
        RuleFor(x => x.FirstName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.LastName).NotEmpty().MaximumLength(100);
        RuleFor(x => x.PhoneNumber).Matches("^\\+[1-9][0-9]{7,14}$");
    }
}
