using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace ECommerce.Application.Features.Addresses.UpdateAddress;

public sealed class UpdateAddressHandler(IAppDbContext db, ICurrentUser currentUser, IClock clock, IValidator<UpdateAddressCommand> validator)
{
    public async Task<Result<AddressDto>> HandleAsync(UpdateAddressCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        if (error is not null) return Result<AddressDto>.Failure(error);
        var entity = await db.Addresses.SingleOrDefaultAsync(x => x.Id == command.Id && x.AccountId == currentUser.AccountId && x.IsActive, ct);
        if (entity is null) return Result<AddressDto>.Failure(CommonErrors.NotFound);
        entity.Title = command.Title.Trim(); entity.AddressLine = command.AddressLine.Trim();
        entity.City = command.City.Trim(); entity.District = command.District.Trim();
        entity.ZipCode = command.ZipCode.Trim(); entity.PhoneNumber = command.PhoneNumber.Trim(); entity.UpdatedAtUtc = clock.UtcNow;
        await db.SaveChangesAsync(ct);
        return Result<AddressDto>.Success(new(entity.Id, entity.Title, entity.AddressLine, entity.City, entity.District, entity.ZipCode, entity.PhoneNumber));
    }
}
