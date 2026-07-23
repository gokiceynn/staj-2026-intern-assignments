using ECommerce.Application.Features.Addresses;
namespace ECommerce.Application.Features.Addresses.ListAddresses;
public sealed record ListAddressesQuery;
public sealed record ListAddressesResult(IReadOnlyList<AddressDto> Items);
