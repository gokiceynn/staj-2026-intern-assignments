using System.Text.Json;
using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Errors;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Features.Admin;
using ECommerce.Domain.Common.Enums;
using ECommerce.Domain.Fulfillment;
using ECommerce.Domain.Operations;
using ECommerce.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
namespace ECommerce.Infrastructure.Admin;
public sealed class ShippingCarrierAdminService(AppDbContext db, ITransactionRunner transactions, IIdGenerator ids, IClock clock) : IShippingCarrierAdminService
{
    public Task<Result<AdminShippingCarrierDto>> CreateAsync(ShippingCarrierWriteModel model, string actorId, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            if (await db.ShippingCarriers.AnyAsync(x => x.Code == model.Code, token)) return Result<AdminShippingCarrierDto>.Failure(CommonErrors.Conflict);
            ShippingCarrier x = new() { Id = ids.NewId("car"), Name = model.Name.Trim(), Code = model.Code.Trim(), LogoPhotoId = model.LogoId,
                FlatFee = model.FlatFee, EstimatedDeliveryDays = model.EstimatedDeliveryDays, TrackingUrlTemplate = model.TrackingUrlTemplate,
                IsActive = model.IsActive, CreatedAtUtc = clock.UtcNow }; db.ShippingCarriers.Add(x); Audit(actorId, "carrier.create", x.Id);
            await db.SaveChangesAsync(token); return Result<AdminShippingCarrierDto>.Success(Map(x));
        }, System.Data.IsolationLevel.ReadCommitted, ct);
    public Task<Result<AdminShippingCarrierDto>> UpdateAsync(string id, ShippingCarrierWriteModel model, string actorId, CancellationToken ct) =>
        transactions.ExecuteAsync(async token =>
        {
            ShippingCarrier? x = await db.ShippingCarriers.SingleOrDefaultAsync(x => x.Id == id, token); if (x is null) return Result<AdminShippingCarrierDto>.Failure(CommonErrors.NotFound);
            if (await db.ShippingCarriers.AnyAsync(y => y.Code == model.Code && y.Id != id, token)) return Result<AdminShippingCarrierDto>.Failure(CommonErrors.Conflict);
            x.Name = model.Name.Trim(); x.Code = model.Code.Trim(); x.LogoPhotoId = model.LogoId; x.FlatFee = model.FlatFee;
            x.EstimatedDeliveryDays = model.EstimatedDeliveryDays; x.TrackingUrlTemplate = model.TrackingUrlTemplate; x.IsActive = model.IsActive;
            x.DeactivatedAtUtc = model.IsActive ? null : clock.UtcNow; x.UpdatedAtUtc = clock.UtcNow; Audit(actorId, "carrier.update", x.Id);
            await db.SaveChangesAsync(token); return Result<AdminShippingCarrierDto>.Success(Map(x));
        }, System.Data.IsolationLevel.ReadCommitted, ct);
    public async Task<Result> DeleteAsync(string id, string actorId, CancellationToken ct)
    {
        ShippingCarrier? x = await db.ShippingCarriers.SingleOrDefaultAsync(x => x.Id == id, ct); if (x is null) return Result.Failure(CommonErrors.NotFound);
        x.IsActive = false; x.DeactivatedAtUtc = clock.UtcNow; x.UpdatedAtUtc = clock.UtcNow; Audit(actorId, "carrier.delete", id); await db.SaveChangesAsync(ct); return Result.Success();
    }
    private void Audit(string actor, string action, string id) => db.AuditLogs.Add(new AuditLog { Id = ids.NewId("aud"), ActorAccountId = actor,
        Action = action, EntityType = "ShippingCarrier", EntityId = id, CorrelationId = ids.NewId("cor"), IpAddress = string.Empty,
        UserAgentHash = string.Empty, MetadataJson = "{}", CreatedAtUtc = clock.UtcNow });
    private static AdminShippingCarrierDto Map(ShippingCarrier x) => new(x.Id, x.Name, x.Code, x.LogoPhotoId, x.FlatFee,
        x.EstimatedDeliveryDays, x.TrackingUrlTemplate, x.IsActive, x.CreatedAtUtc, x.UpdatedAtUtc);
}
