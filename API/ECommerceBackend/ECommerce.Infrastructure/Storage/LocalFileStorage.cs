using System.Security.Cryptography;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.Extensions.Options;
using SixLabors.ImageSharp;

namespace ECommerce.Infrastructure.Storage;

public sealed class LocalFileStorage(IOptions<StorageOptions> options, IIdGenerator ids) : IFileStorage
{
    private readonly string _root = Path.GetFullPath(options.Value.LocalRoot);
    private readonly long _maxBytes = options.Value.MaxPhotoBytes;

    public async Task<StoredFile> SaveAsync(Stream content, string contentType, CancellationToken ct)
    {
        using MemoryStream buffer = new();
        await content.CopyToAsync(buffer, ct);
        if (buffer.Length > _maxBytes) throw new InvalidDataException("Photo exceeds the configured size limit.");
        using Image image = Image.Load(buffer.ToArray());
        string extension = contentType switch { "image/jpeg" => ".jpg", "image/png" => ".png", "image/webp" => ".webp", _ => throw new InvalidDataException() };
        image.Metadata.ExifProfile = null; image.Metadata.XmpProfile = null; image.Metadata.IptcProfile = null;
        using MemoryStream sanitized = new();
        if (contentType == "image/jpeg") await image.SaveAsJpegAsync(sanitized, ct);
        else if (contentType == "image/png") await image.SaveAsPngAsync(sanitized, ct);
        else await image.SaveAsWebpAsync(sanitized, ct);
        byte[] bytes = sanitized.ToArray();
        string relative = Path.Combine(DateTime.UtcNow.ToString("yyyy/MM/dd"), ids.NewId("file") + extension);
        string full = SafePath(relative);
        Directory.CreateDirectory(Path.GetDirectoryName(full)!);
        await File.WriteAllBytesAsync(full, bytes, ct);
        return new(relative.Replace('\\', '/'), Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant(), bytes.LongLength, image.Width, image.Height);
    }

    public async Task<StoredFileContent?> GetAsync(string key, CancellationToken ct)
    {
        string path = SafePath(key);
        if (!File.Exists(path)) return null;
        FileStream stream = new(path, FileMode.Open, FileAccess.Read, FileShare.Read, 64 * 1024, FileOptions.Asynchronous | FileOptions.SequentialScan);
        string type = Path.GetExtension(path).ToLowerInvariant() switch { ".jpg" => "image/jpeg", ".png" => "image/png", ".webp" => "image/webp", _ => "application/octet-stream" };
        return await Task.FromResult(new StoredFileContent(stream, type, stream.Length));
    }

    public Task DeleteAsync(string key, CancellationToken ct)
    {
        string path = SafePath(key); if (File.Exists(path)) File.Delete(path); return Task.CompletedTask;
    }

    private string SafePath(string relative)
    {
        string full = Path.GetFullPath(Path.Combine(_root, relative.Replace('/', Path.DirectorySeparatorChar)));
        if (!full.StartsWith(_root + Path.DirectorySeparatorChar, StringComparison.OrdinalIgnoreCase)) throw new InvalidOperationException("Invalid storage key.");
        return full;
    }
}
