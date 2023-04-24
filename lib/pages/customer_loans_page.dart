import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loan_collection_android/models/customer.dart';
import 'package:loan_collection_android/models/loan.dart';
import 'package:loan_collection_android/services/loans_service.dart';
import 'package:loan_collection_android/widgets/customer_loans_list.dart';

class CustomerLoansPage extends StatefulWidget {
  final Customer customer;

  const CustomerLoansPage({Key? key, required this.customer}) : super(key: key);

  @override
  _CustomerLoansPageState createState() => _CustomerLoansPageState();
}

class _CustomerLoansPageState extends State<CustomerLoansPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans List'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Loans for ${widget.customer.name}',
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Loan>>(
                future: fetchCustomerLoans(widget.customer, http.Client()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return snapshot.data!.isNotEmpty
                        ? CustomerLoansList(loans: snapshot.data!)
                        : Text('No loans available');
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
