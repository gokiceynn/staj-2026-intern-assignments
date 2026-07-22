namespace ECommerce.Application.Common.Models;
public sealed record Error(string Code, string Message, IReadOnlyDictionary<string, string[]>? Details = null);
