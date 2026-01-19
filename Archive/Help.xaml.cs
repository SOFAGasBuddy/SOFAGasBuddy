using CommunityToolkit.Maui.Alerts;
using CommunityToolkit.Maui.Core;

namespace SOFAGasBuddy;

public partial class Help : ContentPage
{
	public Help()
	{
		InitializeComponent();
	}

    private async void MailErrorButton_Clicked(object sender, EventArgs e)
    {
		CancellationTokenSource cancellationTokenSource = new();
        ToastDuration duration = ToastDuration.Short;

        string? last_err = await SecureStorage.Default.GetAsync("LAST_ERR");

		if (last_err != null)
		{
			try
			{
				string[] recipient = new[] { "sofagasbuddy@gmail.com" };
				var message = new EmailMessage
				{
					Subject = "Error received",
					Body = $"\"{last_err}\".\n\n Please describe what you were doing when you got this error:\n",
					BodyFormat = EmailBodyFormat.PlainText,
					To = new List<string>(recipient)
				};
				await Email.Default.ComposeAsync(message);
			}
			catch (Exception ex)
			{
                var toast = Toast.Make($"Unable to send email: {ex.ToString()}.", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
            }
		}
		else
		{
            var toast = Toast.Make("No known error has been logged.", duration, 14);
            await toast.Show(cancellationTokenSource.Token);
        }
    }
}