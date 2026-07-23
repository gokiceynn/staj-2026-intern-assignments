using System.Text.Json;
namespace ECommerce.Api.Contracts.Common;
public sealed class ApiJsonNamingPolicy : JsonNamingPolicy
{
    public override string ConvertName(string name)
    {
        string withoutUtc = name.EndsWith("Utc", StringComparison.Ordinal) ? name[..^3] : name;
        return JsonNamingPolicy.CamelCase.ConvertName(withoutUtc);
    }
}
