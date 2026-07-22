using ECommerce.Application.Common.Models;
using FluentValidation;

namespace ECommerce.Application.Common.Validation;

public static class ValidationExtensions
{
    public static async Task<Error?> ValidateAsErrorAsync<T>(this IValidator<T> validator, T model, CancellationToken ct)
    {
        FluentValidation.Results.ValidationResult result = await validator.ValidateAsync(model, ct);
        if (result.IsValid) return null;

        Dictionary<string, string[]> details = result.Errors
            .GroupBy(x => x.PropertyName)
            .ToDictionary(x => x.Key, x => x.Select(y => y.ErrorMessage).Distinct().ToArray());

        return new Error("VALIDATION_ERROR", "One or more validation errors occurred.", details);
    }
}
