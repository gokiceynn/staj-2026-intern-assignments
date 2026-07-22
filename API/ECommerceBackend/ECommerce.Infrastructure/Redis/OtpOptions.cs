namespace ECommerce.Infrastructure.Redis;
public sealed class OtpOptions
{
    public const string SectionName = "Otp";
    public int LifetimeMinutes { get; init; } = 5;
    public int MaxAttempts { get; init; } = 5;
    public int ResendCooldownSeconds { get; init; } = 60;
}
