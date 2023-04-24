import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:loan_collection_android/models/customer.dart';
import 'package:loan_collection_android/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Customer>> fetchCustomers(http.Client client) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
    "Content-type": "application/json",
  };
  var url = Uri.https(domain, customersListRoute);
  final response = await client.get(url, headers: headers);
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch customers. : " + response.body);
  }

  // process customers list in an isolate
  return compute(parseCustomers, response.body);
}

List<Customer> parseCustomers(String responseBody) {
  final parsed = jsonDecode(responseBody)['data'];
  final mapped = parsed.cast<Map<String, dynamic>>();
  return mapped.map<Customer>((json) => Customer.fromJson(json)).toList();
}
