namespace ECommerce.Infrastructure.Persistence.Seed;

/// <summary>
/// İlk admin hesabının ortam değişkenlerinden okunan bilgileri (Seed__Admin__*).
/// Email boşsa admin seed'i hiç çalışmaz.
/// </summary>
public sealed class AdminSeedOptions
{
    public const string SectionName = "Seed:Admin";
    public string Email { get; init; } = string.Empty;
    public string Password { get; init; } = string.Empty;
    public string FirstName { get; init; } = "System";
    public string LastName { get; init; } = "Admin";
    public string PhoneNumber { get; init; } = "0000000000";

    public bool IsConfigured => !string.IsNullOrWhiteSpace(Email);
}
