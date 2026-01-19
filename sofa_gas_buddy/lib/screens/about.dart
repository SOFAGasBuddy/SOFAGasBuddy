import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sofa_gas_buddy/screens/app_license.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontSize: 12);
    final linkStyle = textStyle?.copyWith(color: Colors.blue);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 25),
              Image.asset(
                'assets/appicon.png',
                height: 120,
                fit: BoxFit.contain,
                semanticLabel: 'SOFA Gas Buddy logo',
              ),
              const SizedBox(height: 25),
              Text(
                'SOFA Gas Buddy',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Text(
                'Copyright 2026 CyberAustin',
                style: textStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Version: $_version',
                style: textStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: linkStyle,
                  text: 'Privacy Policy',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchURL(
                        'https://github.com/SOFAGasBuddy/SOFAGasBuddy/blob/main/privacy.md',
                      );
                    },
                ),
              ),
              const SizedBox(height: 25),
              RichText(
                text: TextSpan(
                  style: textStyle,
                  children: <TextSpan>[
                    const TextSpan(
                      text:
                          'Really? The app is just free, no ads? Yes. I think ads are gross, and they don\'t make sense here because this app is just a wrapper for the AAFES website to make your life easier. That is, it\'s free for you. I, CyberAustin, do have costs that I incur to publish this app for everyone, so if you appreciate my work and want to throw me a few bones, consider',
                    ),
                    TextSpan(
                      text: ' buying me a cup of coffee.',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL(
                            'https://www.buymeacoffee.com/cyberaustin',
                          );
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Text(
                'The app is intended for U.S. person assigned to official duties in Germany. This app, nor its creators, are sponsored or endorsed by the DOD or AAFES.',
                style: textStyle,
              ),
              const SizedBox(height: 25),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: linkStyle,
                  text: 'View License',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppLicensePage(),
                        ),
                      );
                    },
                ),
              ),
              const SizedBox(height: 25),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textStyle,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Source Code (GitHub)',
                      style: linkStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          _launchURL('https://github.com/SOFAGasBuddy');
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
