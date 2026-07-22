namespace ECommerce.Infrastructure.Security;
public sealed class PasswordHashOptions
{
    public const string SectionName = "PasswordHash";
    public int MemorySizeKb { get; init; } = 65_536;
    public int Iterations { get; init; } = 3;
    public int DegreeOfParallelism { get; init; } = 2;
    public int SaltSizeBytes { get; init; } = 16;
    public int HashSizeBytes { get; init; } = 32;
}
