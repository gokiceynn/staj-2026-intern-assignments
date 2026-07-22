namespace ECommerce.Application.Features.Metadata.GetStatuses;
public sealed record GetStatusesQuery;
public sealed record StatusItem(string Code, string Label, string? IconId);
public sealed record StatusGroup(string Name, IReadOnlyList<StatusItem> Items);
