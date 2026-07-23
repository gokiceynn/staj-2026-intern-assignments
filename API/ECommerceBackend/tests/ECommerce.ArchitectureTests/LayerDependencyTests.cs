using NetArchTest.Rules;
using Xunit;
namespace ECommerce.ArchitectureTests;
public sealed class LayerDependencyTests
{
    [Fact] public void Domain_DoesNotDependOnOtherLayers() => Assert.True(Types.InAssembly(typeof(ECommerce.Domain.Common.EntityBase).Assembly)
        .ShouldNot().HaveDependencyOnAny("ECommerce.Application", "ECommerce.Infrastructure", "ECommerce.Api").GetResult().IsSuccessful);
    [Fact] public void Application_DoesNotDependOnOuterLayers() => Assert.True(Types.InAssembly(typeof(ECommerce.Application.DependencyInjection).Assembly)
        .ShouldNot().HaveDependencyOnAny("ECommerce.Infrastructure", "ECommerce.Api").GetResult().IsSuccessful);
    [Fact] public void Infrastructure_DoesNotDependOnApi() => Assert.True(Types.InAssembly(typeof(ECommerce.Infrastructure.DependencyInjection).Assembly)
        .ShouldNot().HaveDependencyOn("ECommerce.Api").GetResult().IsSuccessful);
    [Fact] public void Controllers_DoNotDependOnEfOrRedis() => Assert.True(Types.InAssembly(typeof(ECommerce.Api.Controllers.V1.AuthController).Assembly)
        .That().ResideInNamespace("ECommerce.Api.Controllers.V1").ShouldNot()
        .HaveDependencyOnAny("Microsoft.EntityFrameworkCore", "StackExchange.Redis").GetResult().IsSuccessful);
}
