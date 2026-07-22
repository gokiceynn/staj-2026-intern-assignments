using ECommerce.Application.Common.Models;
namespace ECommerce.Application.Features.Accounts.GetMe;
public sealed record GetMeQuery;
public sealed record GetMeResult(AccountSummary Account);
