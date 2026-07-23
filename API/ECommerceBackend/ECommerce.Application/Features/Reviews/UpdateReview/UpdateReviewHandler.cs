using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Application.Features.Reviews;
using FluentValidation;

namespace ECommerce.Application.Features.Reviews.UpdateReview;

public sealed class UpdateReviewHandler(IReviewWriter writer, ICurrentUser currentUser, IValidator<UpdateReviewCommand> validator)
{
    public async Task<Result<ReviewDto>> HandleAsync(UpdateReviewCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is not null
            ? Result<ReviewDto>.Failure(error)
            : await writer.UpdateAsync(currentUser.AccountId, command.ProductId, command.ReviewId, command.Rating, command.Comment.Trim(), command.PhotoIds, ct);
    }
}
