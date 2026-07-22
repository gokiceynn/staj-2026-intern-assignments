namespace ECommerce.Application.Common.Security;

public static class PolicyNames
{
    public const string CustomerOnly = "CustomerOnly";
    public const string SellerOnly = "SellerOnly";
    public const string AdminOnly = "AdminOnly";
    public const string CustomerOrAdmin = "CustomerOrAdmin";
}
