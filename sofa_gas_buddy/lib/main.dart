import 'package:flutter/material.dart';
import 'package:sofa_gas_buddy/screens/main_page.dart';
import 'package:sofa_gas_buddy/screens/about.dart';
import 'package:sofa_gas_buddy/screens/help.dart';
import 'package:sofa_gas_buddy/screens/settings.dart';
import 'package:sofa_gas_buddy/screens/app_license.dart';

void main() {
  runApp(const SGB());
}

class SGB extends StatelessWidget {
  const SGB({super.key});

  // Root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sofa Gas Buddy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const Home(title: 'SOFA Gas Buddy'),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.title});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MainPage(),
    SettingsPage(),
    HelpPage(),
    AboutPage(),
    AppLicensePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: _widgetOptions[_selectedIndex]),
      drawer: Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: Colors.white),
              child: Image.asset(
                'assets/splash_screen.png',
                height: 80,
              ),
            ),
            ListTile(
              title: const Text('Main Page'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              title: const Text('Settings'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              title: const Text('Help'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            ListTile(
              title: const Text('About'),
              selected: _selectedIndex == 3,
              onTap: () => _onItemTapped(3),
            ),
            ListTile(
              title: const Text('License'),
              selected: _selectedIndex == 4,
              onTap: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
