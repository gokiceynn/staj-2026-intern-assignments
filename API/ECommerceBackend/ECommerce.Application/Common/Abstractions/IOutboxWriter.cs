namespace ECommerce.Application.Common.Abstractions;
public interface IOutboxWriter { void Add(string messageType, object payload); }
