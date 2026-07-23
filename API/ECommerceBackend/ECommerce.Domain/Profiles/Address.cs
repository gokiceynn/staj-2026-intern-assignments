using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Profiles;

public sealed class Address : EntityBase
{
    public string AccountId { get; set; } = string.Empty;
    public Account Account { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string AddressLine { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string District { get; set; } = string.Empty;
    public string ZipCode { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime? DeletedAtUtc { get; set; }
}
