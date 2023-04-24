import 'package:flutter/material.dart';
import 'package:loan_collection_android/models/loan.dart';
import 'package:loan_collection_android/pages/fixed_payments_page.dart';

class CustomerLoansList extends StatelessWidget {
  final List<Loan> loans;

  const CustomerLoansList({Key? key, required this.loans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildListView();
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.asset(
            'images/cash_payment.png',
            width: 75.0,
            height: 75.0,
          ),
          title: Text(loans[index].loanScheme),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return LoanPaymentsPage(loan: loans[index]);
              }),
            );
          },
        );
      },
    );
  }
}
