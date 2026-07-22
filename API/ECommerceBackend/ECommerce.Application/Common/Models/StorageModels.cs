namespace ECommerce.Application.Common.Models;

public sealed record StoredFile(string Key, string Sha256Hash, long SizeBytes, int Width, int Height);
public sealed record StoredFileContent(Stream Content, string ContentType, long SizeBytes);
