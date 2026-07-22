using FluentValidation;
namespace ECommerce.Application.Features.SellerProfile.GetSellerDashboard;
public sealed class GetSellerDashboardValidator : AbstractValidator<GetSellerDashboardQuery>
{ public GetSellerDashboardValidator() => RuleFor(x => x.To).GreaterThanOrEqualTo(x => x.From).When(x => x.From.HasValue && x.To.HasValue); }
