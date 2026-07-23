using ECommerce.Application.Common.Models;
namespace ECommerce.Api.Contracts.V1;
public static class ContractMappings
{
    public static PaymentCardInput ToApplication(this PaymentCardRequest x) =>
        new(x.CardHolderName, x.CardNumber, x.ExpireMonth, x.ExpireYear, x.Cvv);
}
