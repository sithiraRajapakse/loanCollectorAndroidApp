import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:loan_collection_android/models/customer.dart';
import 'package:loan_collection_android/models/loan.dart';
import 'package:loan_collection_android/models/loan_installment.dart';
import 'package:loan_collection_android/models/loan_summary.dart';
import 'package:loan_collection_android/services/login_service.dart';
import 'package:loan_collection_android/util/constants.dart';
import 'package:sprintf/sprintf.dart';

Future<List<Loan>> fetchCustomerLoans(
    Customer customer, http.Client client) async {
  String? token = await getStoredToken();
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
    "Content-type": "application/json",
  };
  var _loansRoute = sprintf(customerLoansRoute, [customer.id]);
  var url = Uri.https(domain, _loansRoute);
  final response = await client.get(url, headers: headers);
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch loans for customer. : " + response.body);
  }

  // process customers list in an isolate
  return compute(parseLoans, response.body);
}

List<Loan> parseLoans(String responseBody) {
  final parsed = jsonDecode(responseBody)['data'];
  final mapped = parsed.cast<Map<String, dynamic>>();
  return mapped.map<Loan>((json) => Loan.fromJson(json)).toList();
}

Future<LoanSummary> getSelectedLoanSummary(
    Loan loan, http.Client client) async {
  String? token = await getStoredToken();
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
    "Content-type": "application/json",
  };

  var _loanSummaryRoute = sprintf(loanSummaryRoute, [loan.id]);
  var url = Uri.https(domain, _loanSummaryRoute);
  final response = await client.get(url, headers: headers);
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch summary for loan : " + response.body);
  }

  final parsed = jsonDecode(response.body)['data'] as Map<String, dynamic>;
  return LoanSummary.fromJson(parsed);
}

Future<LoanInstallment?> getNextPayableInstallment(
    Loan loan, http.Client client) async {
  String? token = await getStoredToken();
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
    "Content-type": "application/json",
  };
  var _nextInstallmentRoute = sprintf(loanNextInstallmentRoute, [loan.id]);
  var url = Uri.https(domain, _nextInstallmentRoute);
  final response = await client.get(url, headers: headers);
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch next installment : " + response.body);
  }

  var decodedBody = jsonDecode(response.body);
  print(decodedBody);
  if (decodedBody['data'] == null) {
    return null;
  }

  final Map<String, dynamic> parsed =
      jsonDecode(response.body)['data'] as Map<String, dynamic>;
  return LoanInstallment.fromJson(parsed);
}

Future<Map<String, dynamic>> sendInstallmentPayment(http.Client client,
    LoanInstallment loanInstallment, double paymentAmount) async {
  String? token = await getStoredToken();
  Map<String, String> headers = {
    "Authorization": "Bearer $token",
    "Accept": "application/json"
  };
  Map<String, dynamic> payload = {
    "paid_amount": '$paymentAmount',
  };
  var _nextInstallmentRoute = sprintf(loanPaymentRoute, [loanInstallment.id]);
  var url = Uri.https(domain, _nextInstallmentRoute);
  final response = await client.post(url, headers: headers, body: payload);
  if (response.statusCode != 200) {
    throw Exception("Failed to fetch next installment : " + response.body);
  }

  var jsonResponse = json.decode(response.body) as Map<String, dynamic>;
  print(jsonResponse);
  return jsonResponse;
}
