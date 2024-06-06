using CommunityToolkit.Maui.Core;
using CommunityToolkit.Maui.Alerts;
using System.Xml;
using SOFAGasBuddy.Services;
using System.Text.RegularExpressions;
namespace SOFAGasBuddy;


public partial class Settings : ContentPage
{
    private string ssn;
    private string vrn;
    CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();
    ToastDuration duration = ToastDuration.Short;

    LogMe log = new();

    public Settings()
	{
        InitializeComponent();
        Get_Creds();    
    }

    private async void Get_Creds()
    {
        Entry txtVRN = (Entry)FindByName("txtVRN");
        Entry txtSSN = (Entry)FindByName("txtSSN");

        try
        {
            ssn = await SecureStorage.Default.GetAsync("SSN");
            vrn = await SecureStorage.Default.GetAsync("VRN");

            if (ssn != null && vrn != null)
            {
                txtSSN.Text = ssn;
                txtVRN.Text = vrn;
                log.write("Success reading creds from storage");
            }
        }
        catch {
            log.write("No creds");
            txtSSN.Text = "error";
            txtVRN.Text = "error";
        }

    }

    private async void btnSave_Clicked(object sender, EventArgs e)
    {
        Entry txtVRN = (Entry)FindByName("txtVRN");
        Entry txtSSN = (Entry)FindByName("txtSSN");

        try
        {
            if (txtVRN.Text == "" || txtSSN.Text == "")
            {
                var toast = Toast.Make("Creds are blank dipshit", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }
            if (!Regex.Match(txtSSN.Text.Replace("-", ""), "\\d{9}").Success)
                {
                var toast = Toast.Make("Invalid Social Security Number", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }
            await SecureStorage.Default.SetAsync("SSN", txtSSN.Text);
            await SecureStorage.Default.SetAsync("VRN", txtVRN.Text);
            
        }
        catch {
            throw new Exception("Fuck, creds were blank");
        }
    }

    private void btnClear_Clicked(object sender, EventArgs e)
    {


        Entry txtVRN = (Entry)FindByName("txtVRN");
        Entry txtSSN = (Entry)FindByName("txtSSN");

        bool ssn_success = SecureStorage.Default.Remove("SSN");
        bool vrn_success = SecureStorage.Default.Remove("VRN");

        if (ssn_success && vrn_success)
        {
            txtSSN.Text = "";
            txtVRN.Text = "";
            var toast = Toast.Make("All cleared", duration, 14);
            toast.Show(cancellationTokenSource.Token);  

        }


    }
}