namespace ECommerce.Api.Contracts.V1;
public sealed record AddressWriteRequest(string Title, string AddressLine, string City, string District, string ZipCode, string PhoneNumber);
