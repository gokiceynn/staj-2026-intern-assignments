namespace ECommerce.Application.Common.Abstractions;

public interface ICurrentUser
{
    bool IsAuthenticated { get; }
    string AccountId { get; }
    string Role { get; }
    string Jti { get; }
    string SessionId { get; }
    int SecurityVersion { get; }
    string IpAddress { get; }
    string UserAgent { get; }
}
