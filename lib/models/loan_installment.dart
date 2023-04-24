/*{
        "id": 3592,
        "loan_id": 35,
        "index_number": 3,
        "due_date": "2021-03-05",
        "installment_amount": "1000.00",
        "interest_amount": "100.00",
        "paid_at": null,
        "arrears_amount": "0.00",
        "collector_id": null,
        "created_at": "2021-04-05T09:33:05.000000Z",
        "updated_at": "2021-04-05T09:33:05.000000Z",
        "deleted_at": null,
        "paid_amount": "0.00"
    }*/

class LoanInstallment {
  int? id;
  int? loanId;
  int? indexNumber;
  String? dueDate;
  String? installmentAmount;
  String? interestAmount;
  DateTime? paidAt;
  String? arrearsAmount;
  int? collectorId;
  String? createdAt;
  String? updatedAt;
  DateTime? deletedAt;
  String? paidAmount;

  LoanInstallment(
      {required this.id,
      required this.loanId,
      required this.indexNumber,
      required this.dueDate,
      required this.installmentAmount,
      required this.interestAmount,
      required this.paidAt,
      required this.arrearsAmount,
      required this.collectorId,
      required this.createdAt,
      required this.updatedAt,
      required this.deletedAt,
      required this.paidAmount});

  factory LoanInstallment.fromJson(Map<String, dynamic> json) =>
      LoanInstallment(
        id: json['id'],
        loanId: json['loan_id'],
        indexNumber: json['indexid_number'],
        dueDate: json['due_date'],
        installmentAmount: json['installment_amount'],
        interestAmount: json['interest_amount'],
        paidAt: json['paid_at'],
        arrearsAmount: json['arrears_amount'],
        collectorId: json['collector_id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        deletedAt: json['deleted_at'],
        paidAmount: json['paid_amount'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['loan_id'] = loanId;
    data['index_number'] = indexNumber;
    data['due_date'] = dueDate;
    data['installment_amount'] = installmentAmount;
    data['interest_amount'] = interestAmount;
    data['paid_at'] = paidAt;
    data['arrears_amount'] = arrearsAmount;
    data['collector_id'] = collectorId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['paid_amount'] = paidAmount;
    return data;
  }
}
