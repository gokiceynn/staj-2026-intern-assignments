namespace ECommerce.Application.Features.Addresses.UpdateAddress;
public sealed record UpdateAddressCommand(string Id, string Title, string AddressLine, string City, string District, string ZipCode, string PhoneNumber);
