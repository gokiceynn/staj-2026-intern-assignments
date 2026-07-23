using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Domain.Common.Enums;
using FluentValidation;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Application.Features.SellerProfile.GetSellerDashboard;
public sealed class GetSellerDashboardHandler(IAppDbContext db, ICurrentUser currentUser, IValidator<GetSellerDashboardQuery> validator)
{
    public async Task<Result<SellerDashboardDto>> HandleAsync(GetSellerDashboardQuery query, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(query, ct);
        if (error is not null) return Result<SellerDashboardDto>.Failure(error);
        string? sellerId = await db.SellerProfiles.Where(x => x.AccountId == currentUser.AccountId).Select(x => x.Id).SingleOrDefaultAsync(ct);
        if (sellerId is null) return Result<SellerDashboardDto>.Failure(CommonErrors.NotFound);
        var products = db.Products.AsNoTracking().Where(x => x.SellerProfileId == sellerId);
        var packages = db.OrderPackages.AsNoTracking().Where(x => x.SellerProfileId == sellerId);
        if (query.From.HasValue) packages = packages.Where(x => x.CreatedAtUtc >= query.From.Value);
        if (query.To.HasValue) packages = packages.Where(x => x.CreatedAtUtc < query.To.Value.AddDays(1));
        SellerDashboardDto dto = new(
            await products.CountAsync(ct), await products.CountAsync(x => x.IsActive, ct), await products.CountAsync(x => x.IsActive && x.Stock <= 5, ct),
            await packages.Select(x => x.OrderId).Distinct().CountAsync(ct), await packages.CountAsync(x => x.Status == PackageStatus.Paid, ct),
            await packages.CountAsync(x => x.Status == PackageStatus.Preparing, ct), await packages.CountAsync(x => x.Status == PackageStatus.Shipped, ct),
            await packages.CountAsync(x => x.Status == PackageStatus.Delivered, ct), await packages.CountAsync(x => x.Status == PackageStatus.Cancelled, ct),
            await packages.Where(x => x.Status != PackageStatus.Cancelled).SumAsync(x => x.Subtotal, ct), "TRY");
        return Result<SellerDashboardDto>.Success(dto);
    }
}
