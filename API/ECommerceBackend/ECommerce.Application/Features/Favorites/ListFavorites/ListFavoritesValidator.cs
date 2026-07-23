using FluentValidation;
namespace ECommerce.Application.Features.Favorites.ListFavorites;
public sealed class ListFavoritesValidator : AbstractValidator<ListFavoritesQuery>
{
    public ListFavoritesValidator() { RuleFor(x => x.Page).GreaterThan(0); RuleFor(x => x.Size).InclusiveBetween(1, 100); }
}
