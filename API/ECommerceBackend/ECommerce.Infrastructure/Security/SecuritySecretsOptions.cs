namespace ECommerce.Infrastructure.Security;
public sealed class SecuritySecretsOptions
{
    public const string SectionName = "SecuritySecrets";
    public string HmacPepperBase64 { get; init; } = string.Empty;
    public string EncryptionKeyBase64 { get; init; } = string.Empty;
}
