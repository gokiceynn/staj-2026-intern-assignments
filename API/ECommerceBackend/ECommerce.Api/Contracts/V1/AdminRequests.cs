namespace ECommerce.Api.Contracts.V1;
public sealed record ShippingCarrierWriteRequest(string Name, string Code, string? LogoId, decimal FlatFee,
    int EstimatedDeliveryDays, string TrackingUrlTemplate, bool IsActive);
