import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loan_collection_android/models/loan.dart';
import 'package:loan_collection_android/models/loan_installment.dart';
import 'package:loan_collection_android/models/loan_summary.dart';
import 'package:loan_collection_android/pages/settings_page.dart';
import 'package:loan_collection_android/services/bluetooth_service.dart';
import 'package:loan_collection_android/services/loans_service.dart';

class LoanPaymentsPage extends StatefulWidget {
  final Loan loan;

  const LoanPaymentsPage({Key? key, required this.loan}) : super(key: key);

  @override
  _LoanPaymentsPageState createState() => _LoanPaymentsPageState();
}

class _LoanPaymentsPageState extends State<LoanPaymentsPage> {
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();

  String? _paymentAmount;
  bool isPaymentSuccess = false;
  late Future<LoanSummary> futureLoanSummary;
  late Future<LoanInstallment> futureLoanInstallment;
  bool isLoading = false;
  bool isPrinted = false;
  String loadingMessage = 'Please wait..';
  late LoanInstallment? payingLoanInstallment;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // load the selected printer by mac saved in shared preferences
    // if no printer, show message to set the printer in settings.
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const SettingsPage();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(
              onPressed: () {
                _openSettings();
              },
              icon: const Icon(Icons.print)),
        ],
      ),
      body: isLoading ? _getLoadingScreen() : _getPaymentScreen(),
    );
  }

  /// Show a snackbar at the bottom of the screen with the text 'value' set.
  /// A type can be supplied of either 'ordinary'/'', 'info', 'success' or 'error"
  /// and the colors will change accordingly.
  void showInSnackBar(String value, {String type = ''}) {
    var successMessageStyle =
        const TextStyle(color: Colors.green, fontSize: 16.0);
    var errorMessageStyle = const TextStyle(color: Colors.red, fontSize: 16.0);
    var infoMessageStyle = const TextStyle(color: Colors.blue, fontSize: 16.0);
    var ordinaryStyle = const TextStyle(fontSize: 16.0);

    TextStyle selectedStyle = infoMessageStyle;
    switch (type) {
      case 'success':
        selectedStyle = successMessageStyle;
        break;
      case 'error':
        selectedStyle = errorMessageStyle;
        break;
      case 'info':
        selectedStyle = infoMessageStyle;
        break;
      default:
        selectedStyle = ordinaryStyle;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value,
          style: selectedStyle,
        ),
      ),
    );
  }

  void reprintReceipt(LoanInstallment loanInstallment) async {
    double paymentAmount =
        _paymentAmount! != '' ? double.parse(_paymentAmount!) : 0.0;
    bool printed =
        await printInstallmentReceipt(loanInstallment, paymentAmount);
    if (printed) {
      setState(() {
        isPrinted = true;
        loadingMessage = 'Please wait...';
        isLoading = false;
      });
      showInSnackBar('Receipt printed successfully.');
    } else {
      setState(() {
        isPrinted = false;
        loadingMessage = 'Please wait...';
        isLoading = false;
      });
      showInSnackBar('Failed to print the receipt.');
    }
  }

  /// handle the payment process and print receipt
  void _handlePaymentSubmitted(LoanInstallment loanInstallment) async {
    final FormState? form = _paymentFormKey.currentState;
    if (!form!.validate()) {
      showInSnackBar('Please enter the payment amount');
      setState(() {
        loadingMessage = 'Please wait..';
        isLoading = false;
      });
    } else {
      setState(() {
        loadingMessage = 'Trying to create payment..\nPlease wait..';
        isLoading = true;
      });
      form.save();

      double paymentAmount =
          _paymentAmount! != '' ? double.parse(_paymentAmount!) : 0.0;

      Future<Map<String, dynamic>> paymentResponse =
          sendInstallmentPayment(http.Client(), loanInstallment, paymentAmount);
      paymentResponse.then(
        (res) async {
          if (res['status'] == 'success') {
            // payment went successfully
            showInSnackBar(
                'Payment completed successfully. Your receipt will be printed shortly.');
            setState(() {
              isPaymentSuccess = true;
              loadingMessage = 'Printing receipt..';
              isLoading = true;
            });
            // show message
            // create and print receipt
            bool printed =
                await printInstallmentReceipt(loanInstallment, paymentAmount);
            if (printed) {
              setState(() {
                isPrinted = true;
                loadingMessage = 'Please wait...';
                isLoading = false;
              });
              showInSnackBar('Receipt printed successfully.');
            } else {
              setState(() {
                isPrinted = false;
                loadingMessage = 'Please wait...';
                isLoading = false;
              });
              showInSnackBar('Failed to print the receipt.');
            }
          } else {
            // payment failed to send
            setState(() {
              isPaymentSuccess = false;
              loadingMessage = 'Please wait..';
              isLoading = false;
            });
            // show message
            showInSnackBar('Payment failed. Please retry in a few seconds..');
          }
        },
      );
    }
  }

  /// build and return the payment screen structure
  Widget _getPaymentScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Loan Summary',
                  style: TextStyle(color: Colors.purple, fontSize: 24.0),
                ),
                const SizedBox(height: 16.0),
                FutureBuilder<LoanSummary>(
                  future: getSelectedLoanSummary(widget.loan, http.Client()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return buildSummaryTable(snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return _getLoadingScreen();
                  },
                ),
              ],
            ),
          ),
          Form(
            key: _paymentFormKey,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Installment Details',
                    style: TextStyle(color: Colors.purple, fontSize: 24.0),
                  ),
                  FutureBuilder<LoanInstallment?>(
                    future:
                        getNextPayableInstallment(widget.loan, http.Client()),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return const Text('No installment details available');
                      }

                      if (snapshot.hasData) {
                        return buildInstallmentTable(snapshot.data!);
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      return _getLoadingScreen();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// returns a table row with the data filled and colored if an odd row
  TableRow _buildTableRow(String column1Text, dynamic column2Text,
      {bool isOddRow = false}) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        TableCell(
          child: Container(
            color: (isOddRow ? Colors.purple.shade50 : Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                column1Text,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: (isOddRow ? Colors.purple.shade50 : Colors.white),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$column2Text',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 12.0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// returns the loading widget with the loading message set currently.
  Widget _getLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          Text(
            loadingMessage,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// returns the structure for the summary table, filled with the data form the loan summary details
  Widget buildSummaryTable(LoanSummary loanSummary) {
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.purple.shade200),
      children: [
        _buildTableRow("Loan Number", loanSummary.loanNumber, isOddRow: true),
        _buildTableRow(
            "Duration", '${loanSummary.startDate} - ${loanSummary.endDate}'),
        _buildTableRow('Interest Rate', '${loanSummary.interestRate}%',
            isOddRow: true),
        _buildTableRow('Loan Amount', 'Rs. ${loanSummary.loanAmount}'),
        _buildTableRow('Interest Amount', 'Rs. ${loanSummary.interestTotal}',
            isOddRow: true),
        _buildTableRow('Total Loan Amount', 'Rs. ${loanSummary.loanTotal}'),
        _buildTableRow('Total Paid', 'Rs. ${loanSummary.totalPaid}',
            isOddRow: true),
        _buildTableRow('Total Arrears', 'Rs. ${loanSummary.totalArrears}'),
        _buildTableRow(
            'Total Loan Due Amount', 'Rs. ${loanSummary.totalDueAmount}',
            isOddRow: true),
      ],
    );
  }

  /// returns the installment table structure with the loan installment details filled
  Widget buildInstallmentTable(LoanInstallment loanInstallment) {
    return Column(
      children: [
        Table(
          children: [
            _buildTableRow('Due Date', loanInstallment.dueDate, isOddRow: true),
            _buildTableRow('Installment Amount',
                'Rs. ${loanInstallment.installmentAmount}'),
          ],
          border: TableBorder.all(width: 1.0, color: Colors.purple.shade200),
        ),
        const SizedBox(height: 8.0),
        const Text(
          'Payment',
          style: TextStyle(color: Colors.purple, fontSize: 24.0),
        ),
        isPaymentSuccess
            ? Column(
                children: [
                  const Card(
                    color: Colors.green,
                    margin: EdgeInsets.all(16.0),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Payment completed successfully.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isPaymentSuccess
                        ? () => {reprintReceipt(loanInstallment)}
                        : null,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Receipt'),
                  ),
                ],
              )
            : Column(
                children: [
                  TextFormField(
                    key: const Key("_paymentAmount"),
                    decoration: const InputDecoration(
                        labelText: "Enter the payment amount here..."),
                    keyboardType: TextInputType.number,
                    onSaved: (String? value) {
                      _paymentAmount = value;
                    },
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        return 'Payment amount is required';
                      } else if (double.parse(value) <= 0) {
                        return 'Payment amount must be greater than zero';
                      }
                    },
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: !isPaymentSuccess
                            ? () {
                                _handlePaymentSubmitted(loanInstallment);
                              }
                            : null,
                        icon: const Icon(Icons.payment),
                        label: const Text('Make Payment & Print Receipt'),
                      ),
                    ],
                  ),
                ],
              ),
      ],
    );
  }
}
