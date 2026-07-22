namespace ECommerce.Application.Features.AdminShippingCarriers.Update;
public sealed record UpdateAdminShippingCarrierCommand(string Id, string Name, string Code, string? LogoId, decimal FlatFee,
    int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive);
