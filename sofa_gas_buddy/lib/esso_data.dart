import 'package:sofa_gas_buddy/car.dart';
import 'package:requests/requests.dart';
import 'package:html/parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EssoData {
  final storage = const FlutterSecureStorage();

  static String idField =
      "_ctl0:ContentPlaceHolder1:ucAuthenticate:tbxSponsorID";
  static String idTypeField =
      "_ctl0:ContentPlaceHolder1:ucAuthenticate:ddlSponsorType";
  static String vrnField = "_ctl0:ContentPlaceHolder1:ucAuthenticate:tbxVRN";
  static String submitID = "_ctl0:ContentPlaceHolder1:ucAuthenticate:btnLogIn";
  static String balanceID =
      "_ctl0_ContentPlaceHolder1_ucESSOPanel_lblAccountBalance";
  static String vehicleTableID =
      "_ctl0_ContentPlaceHolder1_ucESSOPanel_dgridVehicleList";

  // ignore: non_constant_identifier_names
  static String URL = "https://odin.aafes.com/esso/";

  Future<(String, List?, bool)> getData(
    String idType,
    String id,
    String vrn,
  ) async {
    //Get the first page so we can the most current cookies and other random strings that appear necessary validating the request
    var initialResponse = await Requests.get(URL);
    initialResponse.raiseForStatus();
    var initialResponseContent = parse(initialResponse.content());
    String? eventTarget = initialResponseContent
        .querySelector("input[name='__VIEWSTATE']")
        ?.attributes['value'];
    String? eventArgument = initialResponseContent
        .querySelector("input[name='__EVENTARGUMENT']")
        ?.attributes['value'];
    String? viewState = initialResponseContent
        .querySelector("input[name='__VIEWSTATE']")
        ?.attributes['value'];
    String? viewStateGen = initialResponseContent
        .querySelector("input[name='__VIEWSTATEGENERATOR']")
        ?.attributes['value'];
    String? eventValidation = initialResponseContent
        .querySelector("input[name='__EVENTVALIDATION']")
        ?.attributes['value'];
    try {
      var accountDataRequest = await Requests.post(
        URL,
        body: {
          '__EVENTTARGET': eventTarget,
          '__EVENTARGUMENT': eventArgument,
          '__VIEWSTATE': viewState,
          '__VIEWSTATEGENERATOR': viewStateGen,
          '__EVENTVALIDATION': eventValidation,
          idField: id,
          idTypeField: idType,
          vrnField: vrn,
          submitID: 'Log In',
        },
        bodyEncoding: RequestBodyEncoding.FormURLEncoded,
      );
      accountDataRequest.raiseForStatus();
      var accountDataContent = parse(accountDataRequest.content());

      bool first = true;
      bool success = false;
      if (accountDataRequest.statusCode == 200) {
        success = true;
      } else {
        await storage.write(
          key: "LAST_ERROR",
          value: "Got something other than 200 from Esso server",
        );
        return ("bad response", null, success);
      }
      List cars = [];
      String balance = accountDataContent.getElementById(balanceID)?.text ??
          "Unable to read balance";
      await storage.write(
        key: "LAST_ERROR",
        value: "Balance was empty or null",
      );

      var vehicles = accountDataContent
          .getElementById(vehicleTableID)
          ?.getElementsByTagName('tr');
      if (vehicles == null) {
        await storage.write(key: "LAST_ERROR", value: "Vehicles was null");
        return ("bad response", null, success);
      }
      for (var vehicle in vehicles) {
        //Skip the first row, as it is just the table headers
        if (first) {
          first = false;
          continue;
        }
        var cols = vehicle.getElementsByTagName('td');
        Car car = Car();
        car.vrn = cols[0].text.trim();
        car.type = cols[1].text.trim();
        car.status = cols[2].text.trim();
        car.ration = cols[3].text.trim();
        car.rationRemaining = cols[4].text.trim();
        car.expDate = cols[5].text.trim();

        //Only add active cars, otherwise the screen is cluttered with garbage
        if (car.status == 'Active') {
          cars.add(car);
        }
      }
      return (balance, cars, success);
    } catch (ex) {
      await storage.write(key: "LAST_ERROR", value: "$ex");
      return ("Last error: $ex", null, false);
    }
  }
}
