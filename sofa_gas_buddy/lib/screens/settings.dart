import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _vrnController = TextEditingController();
  String? idType;
  final storage = const FlutterSecureStorage();

  Map<String, String> menuItems = {
    'Social Security Number': 'S',
    'Passport Number': 'P',
    'Driving License Number': 'D',
    'Unit': 'U',
    'Other': 'I',
  };

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  void _loadCredentials() async {
    final storedVrn = await storage.read(key: "vrn");
    final storedId = await storage.read(key: "id");
    final storedIdType = await storage.read(key: "idType");

    if (mounted) {
      setState(() {
        _idController.text = storedId ?? '';
        _vrnController.text = storedVrn ?? '';
        if (storedIdType != null && menuItems.containsValue(storedIdType)) {
          idType = storedIdType;
        } else {
          idType = null;
        }
      });
    }
  }

  void _saveCredentials() async {
    String idValue = _idController.text;
    String vrnValue = _vrnController.text.toUpperCase();

    if (idType == null || idType == '') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select an ID Type.',
              selectionColor: Colors.black,),
            backgroundColor: Colors.yellowAccent,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }

    if (idType == 'S') {
      idValue = idValue.replaceAll('-', '');

      // Verify SSN with regex
      final ssnRegex = RegExp(r'^\d{9}$');
      if (!ssnRegex.hasMatch(idValue)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Social Security Number is invalid. Please re-enter it.',
                selectionColor: Colors.black,),
              backgroundColor: Colors.yellowAccent,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    }
    if (vrnValue == '' ) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enter a Vehicle Registration Number.',
              selectionColor: Colors.black,),
            backgroundColor: Colors.yellowAccent,
            duration: Duration(seconds: 5),
          ),
        );
      }
      return;
    }
    await storage.write(key: "vrn", value: _vrnController.text);
    await storage.write(key: "id", value: idValue);
    await storage.write(key: "idType", value: idType);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credentials saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _vrnController.dispose();
    super.dispose();
  }

  Future<void> _deleteCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete all credentials?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await storage.deleteAll();
      _loadCredentials();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Credentials deleted.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: _idController,
            obscureText: true,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your ID',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: DropdownMenu(
            initialSelection: idType,
            onSelected: (String? value) {
              setState(() {
                idType = value;
              });
            },
            dropdownMenuEntries:
                menuItems.entries.map<DropdownMenuEntry<String>>((
              MapEntry<String, String> entry,
            ) {
              return DropdownMenuEntry<String>(
                value: entry.value,
                label: entry.key,
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextFormField(
            controller: _vrnController,
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'Enter your Vehicle Registration Number',
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: _saveCredentials,
                tooltip: 'Save Data',
                child: const Icon(Icons.save, color: Colors.green),
              ),
              FloatingActionButton(
                onPressed: _deleteCredentials,
                tooltip: 'Delete All Data',
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
