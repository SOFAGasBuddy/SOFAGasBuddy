using System.Windows.Input;

namespace SOFAGasBuddy;

public partial class About : ContentPage
{
    public About()
	{
		InitializeComponent();
		string version = AppInfo.Current.VersionString;
		lblVersion.Text = $"Version: {version}";
	}
}