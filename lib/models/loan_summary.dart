/*
{
  "loan_id": 35,
  "loan_number": "202133",
  "customer_id": 47,
  "customer_name": "adum kade",
  "customer_telephone": "0714576340",
  "start_date": "2021-03-03",
  "end_date": "2021-06-17",
  "interest_rate": "10.0",
  "loan_amount": "70,000.00",
  "interest_total": "28,000.00",
  "loan_total": "98,000.00",
  "total_paid": "9,000.00",
  "total_arrears": "20,100.00",
  "total_due_amount": "89,000.00"
}
*/

import 'dart:convert';

LoanSummary loanSummaryFromJson(String str) =>
    LoanSummary.fromJson(json.decode(str));

String loanSummaryToJson(LoanSummary data) => json.encode(data.toJson());

class LoanSummary {
  int loanId;
  String loanNumber;
  int customerId;
  String customerName;
  String customerTelephone;
  String startDate;
  String endDate;
  String interestRate;
  String loanAmount;
  String interestTotal;
  String loanTotal;
  String totalPaid;
  String totalArrears;
  String totalDueAmount;

  LoanSummary(
      {required this.loanId,
      required this.loanNumber,
      required this.customerId,
      required this.customerName,
      required this.customerTelephone,
      required this.startDate,
      required this.endDate,
      required this.interestRate,
      required this.loanAmount,
      required this.interestTotal,
      required this.loanTotal,
      required this.totalPaid,
      required this.totalArrears,
      required this.totalDueAmount});

  factory LoanSummary.fromJson(Map<String, dynamic> json) => LoanSummary(
      loanId: json['loan_id'],
      loanNumber: json['loan_number'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      customerTelephone: json['customer_telephone'] ?? '-',
      startDate: json['start_date'],
      endDate: json['end_date'],
      interestRate: json['interest_rate'],
      loanAmount: json['loan_amount'],
      interestTotal: json['interest_total'],
      loanTotal: json['loan_total'],
      totalPaid: json['total_paid'],
      totalArrears: json['total_arrears'],
      totalDueAmount: json['total_due_amount']);

  Map<String, dynamic> toJson() => {
        'loan_id': loanId,
        'loan_number': loanNumber,
        'customer_id': customerId,
        'customer_name': customerName,
        'customer_telephone': customerTelephone,
        'start_date': startDate,
        'end_date': endDate,
        'interest_rate': interestRate,
        'loan_amount': loanAmount,
        'interest_total': interestTotal,
        'loan_total': loanTotal,
        'total_paid': totalPaid,
        'total_arrears': totalArrears,
        'total_due_amount': totalDueAmount,
      };
}
