using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Accounts.UpdateMe;
public sealed record UpdateMeCommand(string FirstName, string LastName, string PhoneNumber);
public sealed record UpdateMeResult(AccountSummary Account);
