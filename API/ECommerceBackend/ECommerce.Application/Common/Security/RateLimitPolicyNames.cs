namespace ECommerce.Application.Common.Security;

public static class RateLimitPolicyNames
{
    public const string Login = "login";
    public const string OtpVerify = "otp-verify";
    public const string OtpResend = "otp-resend";
    public const string ForgotPassword = "forgot-password";
    public const string Refresh = "refresh";
    public const string Upload = "upload";
    public const string Checkout = "checkout";
    public const string Mutation = "mutation";
}
