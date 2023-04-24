import 'dart:convert';

Loan loanFromJson(String str) => Loan.fromJson(json.decode(str));

String loanToJson(Loan data) => json.encode(data.toJson());

class Loan {
  final int id;
  final int customerId;
  final String customerName;
  final String loanNumber;
  final String startDate;
  final String endDate;
  final String loanAmount;
  final String loanScheme;
  final String loanType;
  final String totalArrears;

  Loan(
      {required this.id,
      required this.customerId,
      required this.customerName,
      required this.loanNumber,
      required this.startDate,
      required this.endDate,
      required this.loanAmount,
      required this.loanScheme,
      required this.loanType,
      required this.totalArrears});

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      loanNumber: json['loan_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      loanAmount: json['loan_amount'],
      loanScheme: json['loan_scheme'],
      loanType: json['loan_type'],
      totalArrears: json['total_arrears']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "customer_id": customerId,
        "customer_name": customerName,
        "loan_number": loanNumber,
        "start_date": startDate,
        "end_date": endDate,
        "loan_amount": loanAmount,
        "loan_scheme": loanScheme,
        "loan_type": loanType,
        "total_arrears": totalArrears,
      };
}
