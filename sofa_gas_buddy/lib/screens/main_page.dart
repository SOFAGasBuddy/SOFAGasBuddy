import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sofa_gas_buddy/esso_data.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    // Load saved data
    _loadOldData();
    _lastRefreshedTime();
  }

  EssoData ed = EssoData();
  String labelData = "";
  String labelRefreshData = "";
  final storage = const FlutterSecureStorage();

  static String? getPrettyDate(DateTime d) {
    final difference = DateTime.now().difference(d);
    int dayDiff = difference.inDays;
    int secDiff = difference.inSeconds;

    if (dayDiff < 0 || dayDiff >= 31) {
      return null;
    }

    if (dayDiff == 0) {
      if (secDiff < 60) {
        return "Just now";
      }

      if (secDiff < 120) {
        return "1 minute ago";
      }

      if (secDiff < 3600) {
        return "${(secDiff / 60).floor()} minutes ago";
      }

      if (secDiff < 7200) {
        return "1 hour ago";
      }

      if (secDiff < 86400) {
        return "${(secDiff / 3600).floor()} hours ago";
      }
    }

    if (dayDiff == 1) {
      return "Yesterday";
    }
    if (dayDiff < 7) {
      return "$dayDiff days ago";
    }
    if (dayDiff < 31) {
      return "Over ${(dayDiff / 7).floor()} weeks ago";
    }
    return null;
  }

  Future<void> _lastRefreshedTime() async {
    String? lastRefresh = await storage.read(key: "LastRefresh");

    if (lastRefresh != null) {
      DateTime lr = DateTime.parse(lastRefresh);
      setState(() {
        labelRefreshData = "Last Refresh: ${getPrettyDate(lr)}";
      });
    }
  }

  Future<void> _loadOldData() async {
    try {
      String? lastData = await storage.read(key: "LastData");

      if (lastData != null) {
        setState(() {
          labelData = lastData;
        });
      }
    } catch (ex) {
      await storage.write(key: "LAST_ERROR", value: "Unable to load old data");
    }
  }

  Future<void> _refreshData() async {
    try {
      //get vrn, id and idType from storage
      String? vrn = await storage.read(key: "vrn");
      String? id = await storage.read(key: "id");
      String? idType = await storage.read(key: "idType");

      if (idType == null || id == null || vrn == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Please enter a valid ID, VRN and ID Type on the Settings page')));
        return;
      }
      var (balance, cars, success) = await ed.getData(idType, id, vrn);

      if (!success || cars == null) {
        await storage.write(key: "LAST_ERROR", value: "Failed to get data");
        setState(() {
          labelData = "Failed to retrieve data. Please try again.";
        });
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln("Account Balance: $balance\n");
      for (var car in cars) {
        if (car.status == "Active") {
          buffer.writeln("VRN: ${car.vrn}");
          buffer.writeln("Ration Remaining: ${car.rationRemaining}L");
          buffer.writeln("Expiration Date: ${car.expDate}\n");
        }
      }
      setState(() {
        labelData = buffer.toString();
        labelRefreshData = "Last Refresh: ${getPrettyDate(DateTime.now())}";
      });
      await storage.write(key: "LastData", value: buffer.toString());
      await storage.write(key: "LastRefresh", value: DateTime.now().toString());
    } catch (ex) {
      await storage.write(key: "LAST_ERROR", value: "$ex");
      setState(() {
        labelData = "An error occurred while fetching data.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final boldStyle = defaultStyle.copyWith(fontWeight: FontWeight.bold);

    List<InlineSpan> buildSpans(String data) {
      List<InlineSpan> spans = [];
      final lines = data.split('\n');
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.isNotEmpty) {
          final index = line.indexOf(':');
          if (index != -1) {
            spans.add(TextSpan(text: line.substring(0, index + 1)));
            spans.add(TextSpan(
              text: line.substring(index + 1),
              style: boldStyle,
            ));
          } else {
            spans.add(TextSpan(text: line));
          }
        }

        if (i < lines.length - 1) {
          spans.add(const TextSpan(text: '\n'));
        }
      }
      return spans;
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
            child: const Icon(Icons.update),
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: buildSpans(labelData),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: defaultStyle,
            children: buildSpans(labelRefreshData),
          ),
        ),
      ],
    );
  }
}
