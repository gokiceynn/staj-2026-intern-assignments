namespace ECommerce.Application.Common.Abstractions;
public interface ICategoryHierarchyReader { Task<IReadOnlyCollection<string>> GetSelfAndDescendantIdsAsync(string categoryId, CancellationToken ct); }
