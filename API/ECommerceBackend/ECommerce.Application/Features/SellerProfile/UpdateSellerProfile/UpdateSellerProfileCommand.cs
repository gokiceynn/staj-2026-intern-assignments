namespace ECommerce.Application.Features.SellerProfile.UpdateSellerProfile;
public sealed record UpdateSellerProfileCommand(string StoreName, string Description, string? LogoId, string TaxOffice);
