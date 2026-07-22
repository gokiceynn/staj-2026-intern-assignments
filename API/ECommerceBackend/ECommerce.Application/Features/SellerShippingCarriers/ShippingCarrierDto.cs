namespace ECommerce.Application.Features.SellerShippingCarriers;
public sealed record ShippingCarrierDto(string Id, string Name, string Code, string? LogoId, decimal FlatFee, int EstimatedDeliveryDays, bool IsActive);
