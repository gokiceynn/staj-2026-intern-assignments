using ECommerce.Application.Common.Abstractions;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Options;
using MimeKit;
namespace ECommerce.Infrastructure.Email;
public sealed class MailKitEmailSender(IOptions<SmtpOptions> options) : IEmailSender
{
    private readonly SmtpOptions _options = options.Value;
    public async Task SendAsync(string to, string subject, string html, CancellationToken ct)
    {
        MimeMessage message = new();
        message.From.Add(new MailboxAddress(_options.FromName, _options.FromAddress));
        message.To.Add(MailboxAddress.Parse(to)); message.Subject = subject;
        message.Body = new BodyBuilder { HtmlBody = html }.ToMessageBody();
        using SmtpClient client = new();
        await client.ConnectAsync(_options.Host, _options.Port, _options.UseTls ? SecureSocketOptions.StartTls : SecureSocketOptions.None, ct);
        if (!string.IsNullOrWhiteSpace(_options.UserName)) await client.AuthenticateAsync(_options.UserName, _options.Password, ct);
        await client.SendAsync(message, ct); await client.DisconnectAsync(true, ct);
    }
}
