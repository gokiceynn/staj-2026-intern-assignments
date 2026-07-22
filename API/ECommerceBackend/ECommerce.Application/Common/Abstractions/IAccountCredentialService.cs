using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Common.Abstractions;

public interface IAccountCredentialService
{
    Task<Result> ChangePasswordAsync(
        string accountId,
        string currentPassword,
        string newPassword,
        string ipAddress,
        CancellationToken ct
    );
    Task<Result> ResetPasswordAsync(
        string accountId,
        string newPassword,
        string ipAddress,
        CancellationToken ct
    );
    Task<Result> ChangeEmailAsync(
        string accountId,
        string newEmail,
        string ipAddress,
        CancellationToken ct
    );
    Task<Result> DeleteCustomerAsync(
        string accountId,
        string password,
        string ipAddress,
        CancellationToken ct
    );
}

