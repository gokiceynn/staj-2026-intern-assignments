using System.Reflection;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Routing;
using Xunit;
namespace ECommerce.ContractTests;
public sealed class RouteContractTests
{
    [Fact]
    public void ControllerRoutes_ExactlyMatchDocumentedRoutes()
    {
        HashSet<string> actual = [];
        Type[] controllers = typeof(ECommerce.Api.Controllers.V1.AuthController).Assembly.GetTypes()
            .Where(x => !x.IsAbstract && typeof(ControllerBase).IsAssignableFrom(x) && x.Namespace == "ECommerce.Api.Controllers.V1").ToArray();
        foreach (Type controller in controllers)
        {
            string prefix = controller.GetCustomAttribute<RouteAttribute>()?.Template ?? string.Empty;
            prefix = prefix.Replace("api/v1/", string.Empty, StringComparison.OrdinalIgnoreCase).Trim('/');
            foreach (MethodInfo method in controller.GetMethods(BindingFlags.Instance | BindingFlags.Public | BindingFlags.DeclaredOnly))
            foreach (HttpMethodAttribute route in method.GetCustomAttributes<HttpMethodAttribute>())
            foreach (string verb in route.HttpMethods)
            {
                string path = string.Join('/', new[] { prefix, route.Template?.Trim('/') }.Where(x => !string.IsNullOrWhiteSpace(x)));
                actual.Add($"{verb} /{path}");
            }
        }
        Assert.Equal(ExpectedRoutes.All.Order(), actual.Order());
    }
}
