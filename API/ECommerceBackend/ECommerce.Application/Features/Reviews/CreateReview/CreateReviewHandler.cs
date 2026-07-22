using ECommerce.Application.Common.Abstractions;
using ECommerce.Application.Common.Models;
using ECommerce.Application.Common.Validation;
using ECommerce.Application.Features.Reviews;
using FluentValidation;

namespace ECommerce.Application.Features.Reviews.CreateReview;

public sealed class CreateReviewHandler(IReviewWriter writer, ICurrentUser currentUser, IValidator<CreateReviewCommand> validator)
{
    public async Task<Result<ReviewDto>> HandleAsync(CreateReviewCommand command, CancellationToken ct)
    {
        Error? error = await validator.ValidateAsErrorAsync(command, ct);
        return error is not null
            ? Result<ReviewDto>.Failure(error)
            : await writer.CreateAsync(currentUser.AccountId, command.ProductId, command.Rating, command.Comment.Trim(), command.PhotoIds, ct);
    }
}
