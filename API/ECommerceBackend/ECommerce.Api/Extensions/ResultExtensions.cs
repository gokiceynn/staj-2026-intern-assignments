using ECommerce.Api.Contracts.Common;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.AspNetCore.Mvc;

namespace ECommerce.Api.Extensions;

public static class ResultExtensions
{
    public static IActionResult ToActionResult<T>(
        this Result<T> result,
        ControllerBase controller,
        IClock clock,
        string successMessage,
        int successStatus = StatusCodes.Status200OK
    )
    {
        if (result.IsSuccess)
            return controller.StatusCode(
                successStatus,
                ApiResponse<T>.Success(result.Value, successMessage, successStatus, clock.UtcNow)
            );
        return Failure(controller, clock, result.Error!);
    }

    public static IActionResult ToActionResult(
        this Result result,
        ControllerBase controller,
        IClock clock,
        string successMessage
    )
    {
        if (result.IsSuccess)
            return controller.Ok(
                ApiResponse<object?>.Success(null, successMessage, 200, clock.UtcNow)
            );
        return Failure(controller, clock, result.Error!);
    }

    private static IActionResult Failure(ControllerBase controller, IClock clock, Error error)
    {
        int status = error.Code switch
        {
            "UNAUTHORIZED"
            or "INVALID_CREDENTIALS"
            or "INVALID_REFRESH_TOKEN"
            or "REFRESH_TOKEN_REUSE" => 401,
            "FORBIDDEN" => 403,
            "NOT_FOUND" => 404,
            "CONFLICT"
            or "EMAIL_ALREADY_EXISTS"
            or "REVIEW_ALREADY_EXISTS"
            or "IDEMPOTENCY_KEY_REUSED" => 409,
            "PAYMENT_DECLINED" => 422,
            "OTP_COOLDOWN" or "RATE_LIMITED" => 429,
            _ when error.Code.Contains("VALIDATION", StringComparison.Ordinal) => 400,
            _ => 400,
        };
        var details =
            error.Details ?? new Dictionary<string, string[]> { [error.Code] = [error.Message] };
        return controller.StatusCode(
            status,
            ApiResponse<object?>.Failure(error.Message, status, details, clock.UtcNow)
        );
    }
}

