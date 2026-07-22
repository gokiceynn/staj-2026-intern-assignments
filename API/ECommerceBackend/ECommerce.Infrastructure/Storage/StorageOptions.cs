namespace ECommerce.Infrastructure.Storage;
public sealed class StorageOptions
{
    public const string SectionName = "Storage";
    public string LocalRoot { get; init; } = "storage";
    public long MaxPhotoBytes { get; init; } = 5 * 1024 * 1024;
}
