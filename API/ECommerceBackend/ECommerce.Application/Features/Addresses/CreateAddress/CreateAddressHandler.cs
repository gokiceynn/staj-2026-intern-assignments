using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Profiles;
using FluentValidation;

namespace ECommerce.Application.Features.Addresses.CreateAddress;

public sealed class CreateAddressHandler(
    IAppDbContext db, ICurrentUser currentUser, IIdGenerator ids, IClock clock, IValidator<CreateAddressCommand> validator)
{
    public async Task<Result<AddressDto>> HandleAsync(CreateAddressCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<AddressDto>.Failure(error);
        Address entity = new()
        {
            Id = ids.NewId("adr"), AccountId = currentUser.AccountId, Title = command.Title.Trim(),
            AddressLine = command.AddressLine.Trim(), City = command.City.Trim(), District = command.District.Trim(),
            ZipCode = command.ZipCode.Trim(), PhoneNumber = command.PhoneNumber.Trim(), IsActive = true, CreatedAtUtc = clock.UtcNow
        };
        db.Addresses.Add(entity);
        await db.SaveChangesAsync(ct);
        return Result<AddressDto>.Success(new(entity.Id, entity.Title, entity.AddressLine, entity.City, entity.District, entity.ZipCode, entity.PhoneNumber));
    }
}
