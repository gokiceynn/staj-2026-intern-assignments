using ECommerce.Domain.Common;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Media;

public sealed class Photo : EntityBase
{
    public string OwnerAccountId { get; set; } = string.Empty;
    public Account OwnerAccount { get; set; } = null!;
    public PhotoPurpose Purpose { get; set; }
    public string StorageProvider { get; set; } = string.Empty;
    public string StorageKey { get; set; } = string.Empty;
    public string OriginalFileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public string Sha256Hash { get; set; } = string.Empty;
    public long FileSizeBytes { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
    public bool IsLinked { get; set; }
    public DateTime? LinkedAtUtc { get; set; }
    public DateTime? DeletedAtUtc { get; set; }
}
