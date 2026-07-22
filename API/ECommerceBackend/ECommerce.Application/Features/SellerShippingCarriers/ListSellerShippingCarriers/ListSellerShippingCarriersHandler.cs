using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Application.Features.SellerShippingCarriers.ListSellerShippingCarriers;
public sealed class ListSellerShippingCarriersHandler(IAppDbContext db)
{
    public async Task<Result<IReadOnlyList<ShippingCarrierDto>>> HandleAsync(ListSellerShippingCarriersQuery query, CancellationToken ct)
    {
        var items = await db.ShippingCarriers.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Name)
            .Select(x => new ShippingCarrierDto(x.Id, x.Name, x.Code, x.LogoPhotoId, x.FlatFee, x.EstimatedDeliveryDays, x.IsActive)).ToListAsync(ct);
        return Result<IReadOnlyList<ShippingCarrierDto>>.Success(items);
    }
}
