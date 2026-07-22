using FluentValidation;
namespace ECommerce.Application.Features.Customers.DeleteMe;
public sealed class DeleteMeValidator : AbstractValidator<DeleteMeCommand>
{
    public DeleteMeValidator() => RuleFor(x => x.Password).NotEmpty().MaximumLength(128);
}
