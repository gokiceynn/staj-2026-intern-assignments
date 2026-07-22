using System.Security.Claims;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Security;

namespace ECommerce.Api.Authentication;

public sealed class HttpCurrentUser(IHttpContextAccessor accessor) : ICurrentUser
{
    private HttpContext Context =>
        accessor.HttpContext ?? throw new InvalidOperationException("No active HTTP context.");
    public bool IsAuthenticated => Context.User.Identity?.IsAuthenticated == true;
    public string AccountId => Context.User.FindFirstValue(ClaimNames.Subject) ?? string.Empty;
    public string Role => Context.User.FindFirstValue(ClaimNames.Role) ?? string.Empty;
    public string Jti => Context.User.FindFirstValue(ClaimNames.JwtId) ?? string.Empty;
    public string SessionId => Context.User.FindFirstValue(ClaimNames.SessionId) ?? string.Empty;
    public int SecurityVersion =>
        int.TryParse(Context.User.FindFirstValue(ClaimNames.SecurityVersion), out int value)
            ? value
            : -1;
    public string IpAddress => Context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    public string UserAgent =>
        Context.Request.Headers.UserAgent.ToString()[
            ..Math.Min(Context.Request.Headers.UserAgent.ToString().Length, 1000)
        ];
}

