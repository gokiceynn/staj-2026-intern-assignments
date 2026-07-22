namespace ECommerce.Application.Common.Models;

public class Result
{
    protected Result(bool isSuccess, Error? error)
    {
        if (isSuccess == (error is not null)) throw new ArgumentException("Success and error state conflict.");
        IsSuccess = isSuccess;
        Error = error;
    }

    public bool IsSuccess { get; }
    public Error? Error { get; }
    public static Result Success() => new(true, null);
    public static Result Failure(Error error) => new(false, error);
}

public sealed class Result<T> : Result
{
    private Result(T? value, bool isSuccess, Error? error) : base(isSuccess, error) => Value = value;
    public T? Value { get; }
    public static Result<T> Success(T value) => new(value, true, null);
    public new static Result<T> Failure(Error error) => new(default, false, error);
}
