namespace ECommerce.ContractTests;
internal static class ExpectedRoutes
{
    public static readonly string[] All =
    [
        "DELETE /admin/shipping-carriers/{id}", "DELETE /cart", "DELETE /cart/items/{productId}", "DELETE /customer/me",
        "DELETE /customer/me/addresses/{id}", "DELETE /favorites/{productId}", "DELETE /products/{productId}/reviews/{reviewId}", "DELETE /seller/products/{id}",
        "GET /account/me", "GET /admin/dashboard", "GET /admin/orders", "GET /admin/orders/{id}", "GET /admin/sellers", "GET /admin/sellers/{id}",
        "GET /admin/shipping-carriers", "GET /admin/shipping-carriers/{id}", "GET /admin/users", "GET /admin/users/{id}", "GET /cart", "GET /categories",
        "GET /customer/me/addresses", "GET /customer/me/addresses/{id}", "GET /favorites", "GET /metadata/statuses", "GET /orders", "GET /orders/{id}",
        "GET /photos/{id}", "GET /products", "GET /products/{id}", "GET /products/{id}/reviews", "GET /seller/dashboard", "GET /seller/orders",
        "GET /seller/orders/{packageId}", "GET /seller/products", "GET /seller/products/{id}", "GET /seller/profile", "GET /seller/shipping-carriers",
        "POST /account/me/email/resend", "POST /account/me/email/verify", "POST /admin/shipping-carriers", "POST /auth/customer/register", "POST /auth/email/resend",
        "POST /auth/email/verify", "POST /auth/forgot-password", "POST /auth/login", "POST /auth/logout", "POST /auth/refresh-token", "POST /auth/reset-password",
        "POST /auth/seller/register", "POST /cart/items", "POST /customer/me/addresses", "POST /favorites/{productId}", "POST /orders/{id}/cancel",
        "POST /orders/checkout", "POST /payments/simulate", "POST /photos", "POST /products/{id}/reviews", "POST /seller/orders/{packageId}/deliver",
        "POST /seller/orders/{packageId}/prepare", "POST /seller/orders/{packageId}/ship", "POST /seller/products", "PUT /account/me", "PUT /account/me/email",
        "PUT /account/me/password", "PUT /admin/shipping-carriers/{id}", "PUT /cart/items/{productId}", "PUT /customer/me/addresses/{id}",
        "PUT /products/{productId}/reviews/{reviewId}", "PUT /seller/products/{id}", "PUT /seller/profile"
    ];
}
