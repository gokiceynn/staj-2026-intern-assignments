using ECommerce.Application.Common.Abstractions;
namespace ECommerce.Infrastructure.Time;
public sealed class SystemClock : IClock { public DateTime UtcNow => DateTime.UtcNow; }
