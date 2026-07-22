using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Catalog;
namespace ECommerce.Application.Features.Favorites.ListFavorites;
public sealed record ListFavoritesQuery(int Page = 1, int Size = 20);
public sealed record ListFavoritesResult(PagedResult<ProductCard> Page);
