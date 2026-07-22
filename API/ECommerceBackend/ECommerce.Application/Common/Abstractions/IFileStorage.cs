using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Abstractions;

public interface IFileStorage
{
    Task<StoredFile> SaveAsync(Stream content, string contentType, CancellationToken ct);
    Task<StoredFileContent?> GetAsync(string key, CancellationToken ct);
    Task DeleteAsync(string key, CancellationToken ct);
}
