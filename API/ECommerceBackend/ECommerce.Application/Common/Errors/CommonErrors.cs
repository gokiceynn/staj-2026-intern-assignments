using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Errors;

public static class CommonErrors
{
    public static readonly Error Unauthorized = new("UNAUTHORIZED", "Authentication is required.");
    public static readonly Error Forbidden = new("FORBIDDEN", "You are not allowed to perform this operation.");
    public static readonly Error NotFound = new("NOT_FOUND", "The requested resource was not found.");
    public static readonly Error Conflict = new("CONFLICT", "The resource was changed by another operation.");
    public static readonly Error Validation = new("VALIDATION_ERROR", "One or more validation errors occurred.");
}
