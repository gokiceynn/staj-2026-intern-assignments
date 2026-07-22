namespace ECommerce.Api.Contracts.Common;

public sealed record ApiResponse<T>(T? Data, bool IsSuccess, string Message, int Code,
    IReadOnlyDictionary<string, string[]>? Errors, DateTime Timestamp)
{
    public static ApiResponse<T> Success(T? data, string message, int code, DateTime now) => new(data, true, message, code, null, now);
    public static ApiResponse<T> Failure(string message, int code, IReadOnlyDictionary<string, string[]>? errors, DateTime now) => new(default, false, message, code, errors, now);
}
