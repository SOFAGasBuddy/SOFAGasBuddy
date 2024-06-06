using SOFAGasBuddy.Services;
using Microsoft.Maui.Controls;
using System.Runtime.Intrinsics.X86;
using CommunityToolkit.Maui.Alerts;
using CommunityToolkit.Maui.Core;
using System.Threading.Tasks.Dataflow;
using System.Linq.Expressions;

namespace SOFAGasBuddy
{
    public partial class Main : ContentPage
    {
        CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();
        ToastDuration duration = ToastDuration.Short;
        LogMe log = new();

        public Main()
        {
            InitializeComponent();
            Title = "Main Page";
            LoadOldData();
            //OnRefreshClicked();
        }

        private async void LoadOldData()
        {
            Label datalabel = (Label)FindByName("lblData");
            try
            {
                string lastdata = await SecureStorage.Default.GetAsync("LastData");
                if (lastdata != null)
                {
                    datalabel.Text = lastdata;
                    datalabel.HorizontalTextAlignment = TextAlignment.Start;
                }
            }
            catch (Exception ex)
            {
                log.write(ex.ToString());
            }
        }

        private async void OnRefreshClicked(object sender, EventArgs e)
        {
            string ssn = string.Empty;
            string vrn = string.Empty;

            try
            {
                ssn = await SecureStorage.Default.GetAsync("SSN");
                vrn = await SecureStorage.Default.GetAsync("VRN");

                if (ssn == null || vrn == null)
                {
                    var toast = Toast.Make("Please enter a SSN and VRN on the Settings tab", duration, 14);
                    await toast.Show(cancellationTokenSource.Token);
                    return;
                }
            }
            catch (Exception ex) 
            {
                var toast = Toast.Make(ex.ToString(), duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }

            EssoData gas = new();
            Label datalabel = (Label)FindByName("lblData");
            var (balance, cars) = await gas.RefreshData(ssn, vrn);
            string lblText = $"Account Balance: {balance}\n\n";

            foreach (var car in cars)
            {
                {
                    if (car.status != "Active")
                    {
                        continue;
                    }
                    lblText += $"VRN: {car.vrn}\nRation Remaining: {car.ration_remaining}L\nExpiration Date: {car.exp_date}\n\n";
                }
            }

            DateTime now = DateTime.Now;
            lblText += $"Last Refresh: {now}";
            datalabel.Text = lblText;
            datalabel.HorizontalTextAlignment = TextAlignment.Start;
            await SecureStorage.Default.SetAsync("LastData", lblText);
        }

    }
}
