using SOFAGasBuddy.Services;
using Microsoft.Maui.Controls;
using System.Runtime.Intrinsics.X86;
using CommunityToolkit.Maui.Alerts;
using CommunityToolkit.Maui.Core;
using System.Threading.Tasks.Dataflow;
using System.Linq.Expressions;
using Microsoft.Extensions.Logging;



namespace SOFAGasBuddy
{
    public partial class Main : ContentPage
    {

        CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();
        ToastDuration duration = ToastDuration.Long;

        public Main()
        {
            InitializeComponent();

            Title = "Main Page";
            LoadOldData();
            RefreshData();


            var timer = Application.Current.Dispatcher.CreateTimer();
            timer.Interval = TimeSpan.FromMinutes(30);
            timer.Tick += (s, e) => UpdateRefreshedTime();
            timer.Start();
        }


        public async void UpdateRefreshedTime()
        {
            string lastrefresh = await SecureStorage.Default.GetAsync("LastRefresh");

            if (lastrefresh != null)
            {
                DateTime lr = DateTime.Parse(lastrefresh);
                lblRefresh.Text = String.Format("Last Refresh: {0}", GetPrettyDate(lr));
            }
        }

        static string GetPrettyDate(DateTime d)
        {

            TimeSpan s = DateTime.Now.Subtract(d);
            int dayDiff = (int)s.TotalDays;
            int secDiff = (int)s.TotalSeconds;

            if (dayDiff < 0 || dayDiff >= 31)
            {
                return null;
            }

            if (dayDiff == 0)
            {
                if (secDiff < 60)
                {
                    return "Just now";
                }

                if (secDiff < 120)
                {
                    return "1 minute ago";
                }

                if (secDiff < 3600)
                {
                    return string.Format("{0} minutes ago", Math.Floor((double)secDiff / 60));
                }

                if (secDiff < 7200)
                {
                    return "1 hour ago";
                }

                if (secDiff < 86400)
                {
                    return string.Format("{0} hours ago", Math.Floor((double)secDiff / 3600));
                }
            }

            if (dayDiff == 1)
            {
                return "Yesterday";
            }
            if (dayDiff < 7)
            {
                return string.Format("{0} days ago", dayDiff);
            }
            if (dayDiff < 31)
            {
                return string.Format("{0} weeks ago", Math.Ceiling((double)dayDiff / 7));
            }
            return null;
        }

        private async void RefreshData()
        {
            string id_type = string.Empty;
            string id = string.Empty;
            string vrn = string.Empty;

            try
            {
                id_type = await SecureStorage.Default.GetAsync("ID_TYPE");
                id = await SecureStorage.Default.GetAsync("ID");
                vrn = await SecureStorage.Default.GetAsync("VRN");

                if (id == null || vrn == null || id_type == null)
                {
                    var toast = Toast.Make("Please enter a valid ID, VRN and ID Type on the Settings page", duration, 14);
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

            var (balance, cars, success) = await gas.RefreshData(id_type, id, vrn);

            if (!success)
            {
                var toast = Toast.Make(balance, duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }
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
            lblRefresh.Text = String.Format("Last Refresh: {0}", GetPrettyDate(now));
            lblData.Text = lblText;
            lblData.HorizontalTextAlignment = TextAlignment.Start;
            await SecureStorage.Default.SetAsync("LastData", lblText);
            await SecureStorage.Default.SetAsync("LastRefresh", now.ToString());
        }

        private async void LoadOldData()
        {
            try
            {
                string lastdata = await SecureStorage.Default.GetAsync("LastData");
                string lastrefresh = await SecureStorage.Default.GetAsync("LastRefresh");
                if (lastdata != null)
                {
                    lblData.Text = lastdata;
                    lblData.HorizontalTextAlignment = TextAlignment.Start;
                }

                if (lastrefresh != null)
                {
                    DateTime lr = DateTime.Parse(lastrefresh);
                    lblRefresh.Text = String.Format("Last Refresh: {0}", GetPrettyDate(lr));
                }
            }
            catch
            {
                throw new Exception("Unable to load old data");
            }
        }

        private void OnRefreshClicked(object sender, EventArgs e)
        {
            RefreshData();
        }

    }
}
