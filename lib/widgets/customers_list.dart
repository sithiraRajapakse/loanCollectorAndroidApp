import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loan_collection_android/models/customer.dart';
import 'package:loan_collection_android/pages/customer_loans_page.dart';

class CustomersList extends StatelessWidget {
  final List<Customer> customers;

  const CustomersList({Key? key, required this.customers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildListView();
  }

  ListView buildListView() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return buildListTile(index, context);
      },
    );
  }

  Widget buildListTile(int index, BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(16.0),
      leading: Image.asset(
        'images/user_loan.png',
        width: 75.0,
        height: 75.0,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customers[index].name.toUpperCase()),
          Text('Telephone: ${customers[index].telephone ?? '-'}'),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return CustomerLoansPage(customer: customers[index]);
            },
          ),
        );
      },
    );
  }
}
