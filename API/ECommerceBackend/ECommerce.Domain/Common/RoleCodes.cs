namespace ECommerce.Domain.Common;

public static class RoleCodes
{
    public const string Customer = "Customer";
    public const string Seller = "Seller";
    public const string Admin = "Admin";

    public static readonly string[] All = [Customer, Seller, Admin];
}
