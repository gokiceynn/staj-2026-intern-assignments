using ECommerce.Application.Common.Models;
using Xunit;
namespace ECommerce.UnitTests.Common;
public sealed class ResultTests
{
    [Fact] public void Success_HasValueAndNoError() { var x = Result<int>.Success(42); Assert.True(x.IsSuccess); Assert.Equal(42, x.Value); Assert.Null(x.Error); }
    [Fact] public void Failure_HasErrorAndNoValue() { var x = Result<int>.Failure(new Error("X", "failed")); Assert.False(x.IsSuccess); Assert.Equal("X", x.Error!.Code); }
}
