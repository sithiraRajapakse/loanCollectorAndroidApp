import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:loan_collection_android/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getStoredToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  return token;
}

Future<bool> logIn(String emailAddress, String password) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String? deviceId = androidInfo.id;
  var url = Uri.https(domain, loginRoute);
  var credentials = {
    "email": emailAddress,
    "password": password,
    "device_name": deviceId
  };
  var response = await http.post(url, body: credentials);
  if (response.statusCode == 200) {
    var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    var token = jsonResponse['data']['token'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    return true;
  }
  return false;
}
