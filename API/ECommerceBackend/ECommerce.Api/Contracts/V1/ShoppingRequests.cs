namespace ECommerce.Api.Contracts.V1;
public sealed record ReviewWriteRequest(int Rating, string Comment, IReadOnlyList<string> PhotoIds);
public sealed record CartItemRequest(string ProductId, int Quantity);
public sealed record UpdateCartItemRequest(int Quantity);
