import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final _storage = const FlutterSecureStorage();

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _mailErrorButtonPressed() async {
    final lastErr = await _storage.read(key: "LAST_ERROR");

    if (!mounted) return; // Check if the widget is still in the tree

    if (lastErr != null) {
      final subject = Uri.encodeComponent("Error received");
      final body = Uri.encodeComponent(
        '"$lastErr".\n\nPlease describe what you were doing when you got this error:\n',
      );
      final mailtoUri = Uri.parse(
        'mailto:sofagasbuddy@gmail.com?subject=$subject&body=$body',
      );

      try {
        await launchUrl(mailtoUri);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unable to open email client: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No known error has been logged.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final large = Theme.of(context).textTheme.headlineSmall;
    final medium = Theme.of(context).textTheme.titleMedium;
    final small = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = small?.copyWith(color: Colors.blue);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),
              Text('Settings', style: large),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text('ID Type', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: Text(
                  'Select the ID type that is associated with your account.',
                  style: small,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text('ID', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text('SSN', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: RichText(
                  text: TextSpan(
                    style: small,
                    children: <TextSpan>[
                      const TextSpan(
                        text:
                            'If using your social security number, it has to be the full SSN (not last 4), it\'s what AAFES\' uses to track/manage your account. Dashes or not, it doesn\'t matter. "You want my SSN? Seems kind of sus..." Please see our',
                      ),
                      TextSpan(
                        text: ' Privacy Policy',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL(
                              'https://github.com/SOFAGasBuddy/SOFAGasBuddy/blob/main/privacy.md',
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text('Passport', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: Text(
                  'Input your passport number exactly as it appears on your passport, include any letters.',
                  style: small,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 10),
                child: Text('Driver\'s License/Unit/Other', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: Text(
                  'Honestly, I don\'t know. Input them in the format that you were instructed to use when setting up your account. Please contact AAFES directly for support. Test using your credentials directly on AAFES\' ESSO website to ensure you get them correct.',
                  style: small,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text('VRN', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: Text(
                  'This is the Vehicle Registraion Number (Plate Number) of any car on the account. And it must be exactly as it is written on the registration form, i.e. all caps and a space between the Landkreis and vehicle number.\n\nExample: S XX1234\n\nThe S in the above exmaple is for Stuttgart. If your vehicle was registered in Wiesbaden, then it would be WI instead.',
                  style: small,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Text('More help', style: medium),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 10, bottom: 10),
                child: RichText(
                  text: TextSpan(
                    style: small,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'Sends us an email and we\'ll do what we can.',
                      ),
                      TextSpan(
                        text: ' sofagasbuddy@gmail.com',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _launchURL('mailto:sofagasbuddy@gmail.com');
                          },
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: ElevatedButton(
                    onPressed: _mailErrorButtonPressed,
                    child: const Text(
                      'Click here to send us the last error you received.',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
