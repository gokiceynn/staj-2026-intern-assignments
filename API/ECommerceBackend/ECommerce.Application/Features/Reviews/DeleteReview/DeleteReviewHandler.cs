using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;

namespace ECommerce.Application.Features.Reviews.DeleteReview;

public sealed class DeleteReviewHandler(IReviewWriter writer, ICurrentUser currentUser)
{
    public Task<Result> HandleAsync(DeleteReviewCommand command, CancellationToken ct) =>
        writer.DeleteAsync(currentUser.AccountId, command.ProductId, command.ReviewId, ct);
}
