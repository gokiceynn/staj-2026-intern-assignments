namespace ECommerce.Application.Features.Addresses.CreateAddress;
public sealed record CreateAddressCommand(string Title, string AddressLine, string City, string District, string ZipCode, string PhoneNumber);
