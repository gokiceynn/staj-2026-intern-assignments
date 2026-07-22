namespace ECommerce.Application.Features.Cart;
public sealed record CartProductDto(string Id, string Title, decimal Price, int Stock, string? PhotoId, string SellerId, string SellerName);
public sealed record CartItemDto(string ProductId, int Quantity, decimal LineTotal, CartProductDto Product);
public sealed record CartDto(string Id, IReadOnlyList<CartItemDto> Items, decimal Subtotal, int TotalQuantity);
