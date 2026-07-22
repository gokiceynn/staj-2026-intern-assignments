namespace ECommerce.Application.Features.Cart.UpdateCartItem;
public sealed record UpdateCartItemCommand(string ProductId, int Quantity);
