using CommunityToolkit.Maui.Core;
using CommunityToolkit.Maui.Alerts;
using System.Xml;
using SOFAGasBuddy.Services;
using System.Text.RegularExpressions;
using System.Threading.Tasks;


namespace SOFAGasBuddy;


public partial class Settings : ContentPage
{
    private string? id;
    private string? vrn;
    private string? id_type;

    readonly CancellationTokenSource cancellationTokenSource = new();
    readonly ToastDuration duration = ToastDuration.Short;

    public Settings()
	{
        InitializeComponent();
        Get_Creds();
        lblErrors.Text = "";
    }

    private async void Get_Creds()
    {
        try
        {
            id = await SecureStorage.Default.GetAsync("ID");
            vrn = await SecureStorage.Default.GetAsync("VRN");
            id_type = await SecureStorage.Default.GetAsync("ID_TYPE");

            if (id != null && vrn != null && id_type != null)
            {
                txtID.Text = id;
                txtVRN.Text = vrn;

                switch (id_type)
                {
                    case "S":
                        pkrID_Type.SelectedIndex = 0;
                        break;

                    case "P":
                        pkrID_Type.SelectedIndex = 1;
                        break;

                    case "D":
                        pkrID_Type.SelectedIndex = 2;
                        break;

                    case "U":
                        pkrID_Type.SelectedIndex = 3;
                        break;

                    case "I":
                        pkrID_Type.SelectedIndex = 4;
                        break;
                }
            }
        }
        catch {
            await SecureStorage.Default.SetAsync("LAST_ERR", "Error retreiving credentials");
            throw new Exception("Error retrieving credentials");
        }
    }

    private async void BtnSave_Clicked(object sender, EventArgs e)
    {
        lblErrors.Text = "";
        int id_type_index = pkrID_Type.SelectedIndex;
        string id_type = "";

        try
        {
            var toast = Toast.Make("", duration, 14);
            
            if (pkrID_Type.SelectedIndex == -1)
            {
                toast = Toast.Make("Please select an ID type", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }

            if (txtID.Text == null)
            {
                toast = Toast.Make("ID is blank", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }
            
            //Only validates SSNs for the moment
            if (id_type_index == 0)
            {
                if (!Regex.Match(txtID.Text.Replace("-", ""), "^(\\d{9})$").Success)
                {
                    toast = Toast.Make("Invalid Social Security Number, see Help tab for more information", duration, 14);
                    await toast.Show(cancellationTokenSource.Token);
                    return;
                }
            }

            if (txtVRN.Text == null)
            {
                toast = Toast.Make("VRN is blank", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }

            if (!Regex.Match(txtVRN.Text.ToUpper(), "^([A-Z]{1,3}\\s[A-Z]{2}\\d{1,4})$").Success && !Regex.Match(txtVRN.Text.ToUpper(), "^([A-Z]{1,3}\\s\\d{1,4})$").Success)
            {
                toast = Toast.Make("VRN Formatted Incorrectly, see Help tab for more information", duration, 14);
                await toast.Show(cancellationTokenSource.Token);
                return;
            }

            switch(pkrID_Type.SelectedIndex)
            {
                case 0:
                    id_type = "S";
                    break;
                 
                case 1:
                    id_type = "P";
                    break;

                case 2:
                    id_type = "D";
                    break;

                case 3:
                    id_type = "U";
                    break;

                case 4:
                    id_type = "I";
                    break;
        }

            await SecureStorage.Default.SetAsync("ID", txtID.Text.ToUpper());
            await SecureStorage.Default.SetAsync("VRN", txtVRN.Text.ToUpper());
            await SecureStorage.Default.SetAsync("ID_TYPE", id_type);
            
            toast = Toast.Make("Saved", duration, 14);
            await toast.Show(cancellationTokenSource.Token);
        }

        catch (Exception ex)
        {
            lblErrors.Text = ex.ToString();
            await SecureStorage.Default.SetAsync("LAST_ERR", ex.ToString());
        }
    }

    private void BtnClear_Clicked(object sender, EventArgs e)
    {
        bool id_type_success = SecureStorage.Default.Remove("ID_TYPE");
        bool id_success = SecureStorage.Default.Remove("ID");
        bool vrn_success = SecureStorage.Default.Remove("VRN");

        if (id_success && vrn_success && id_type_success)
        {
            pkrID_Type.SelectedIndex = -1;
            txtID.Text = null;
            txtVRN.Text = null;

            var toast = Toast.Make("All data cleared", duration, 14);
            toast.Show(cancellationTokenSource.Token);  
        }
        else
        {
            var toast = Toast.Make("Error clearing data, please try again", duration, 14);
            toast.Show(cancellationTokenSource.Token);
        }
    }
}