namespace ECommerce.Application.Common.Abstractions;
public interface IEmailSender { Task SendAsync(string to, string subject, string html, CancellationToken ct); }
