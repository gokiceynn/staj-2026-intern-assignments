namespace ECommerce.Application.Features.AdminShippingCarriers.Create;
public sealed record CreateAdminShippingCarrierCommand(string Name, string Code, string? LogoId, decimal FlatFee,
    int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive);
