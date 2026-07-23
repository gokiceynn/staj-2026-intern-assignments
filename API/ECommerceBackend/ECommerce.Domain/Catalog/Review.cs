using ECommerce.Domain.Common;
using ECommerce.Domain.Identity;

namespace ECommerce.Domain.Catalog;

public sealed class Review : EntityBase
{
    public string ProductId { get; set; } = string.Empty;
    public Product Product { get; set; } = null!;
    public string CustomerAccountId { get; set; } = string.Empty;
    public Account CustomerAccount { get; set; } = null!;
    public int Rating { get; set; }
    public string Comment { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime? DeletedAtUtc { get; set; }
    public ICollection<ReviewPhoto> Photos { get; set; } = new List<ReviewPhoto>();
}
