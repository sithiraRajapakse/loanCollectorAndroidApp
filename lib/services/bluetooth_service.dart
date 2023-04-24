import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:loan_collection_android/models/loan_installment.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<int>> getGraphicsTicket() async {
  List<int> bytes = [];

  CapabilityProfile profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  // Print QR Code using native function
  bytes += generator.qrcode('https://mybooking.lk');

  bytes += generator.hr();

  // Print Barcode using native function
  final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  bytes += generator.barcode(Barcode.upcA(barData));

  bytes += generator.cut();

  return bytes;
}

Future<List<int>> getTicket() async {
  List<int> bytes = [];
  CapabilityProfile profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm80, profile);

  bytes += generator.text("Payment Receipt",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1);

  bytes += generator.text(
      "18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078",
      styles: const PosStyles(align: PosAlign.center));
  bytes += generator.text('Tel: +919591708470',
      styles: const PosStyles(align: PosAlign.center));

  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(
        text: 'No',
        width: 1,
        styles: const PosStyles(align: PosAlign.left, bold: true)),
    PosColumn(
        text: 'Item',
        width: 5,
        styles: const PosStyles(align: PosAlign.left, bold: true)),
    PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true)),
    PosColumn(
        text: 'Qty',
        width: 2,
        styles: const PosStyles(align: PosAlign.center, bold: true)),
    PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);

  bytes += generator.row([
    PosColumn(text: "1", width: 1),
    PosColumn(
        text: "Tea",
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        )),
    PosColumn(
        text: "10",
        width: 2,
        styles: const PosStyles(
          align: PosAlign.center,
        )),
    PosColumn(
        text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
    PosColumn(
        text: "10", width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.row([
    PosColumn(text: "2", width: 1),
    PosColumn(
        text: "Sada Dosa",
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        )),
    PosColumn(
        text: "30",
        width: 2,
        styles: const PosStyles(
          align: PosAlign.center,
        )),
    PosColumn(
        text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
    PosColumn(
        text: "30", width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.row([
    PosColumn(text: "3", width: 1),
    PosColumn(
        text: "Masala Dosa",
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        )),
    PosColumn(
        text: "50",
        width: 2,
        styles: const PosStyles(
          align: PosAlign.center,
        )),
    PosColumn(
        text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
    PosColumn(
        text: "50", width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.row([
    PosColumn(text: "4", width: 1),
    PosColumn(
        text: "Rova Dosa",
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
        )),
    PosColumn(
        text: "70",
        width: 2,
        styles: const PosStyles(
          align: PosAlign.center,
        )),
    PosColumn(
        text: "1", width: 2, styles: const PosStyles(align: PosAlign.center)),
    PosColumn(
        text: "70", width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.hr();

  bytes += generator.row([
    PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size4,
          width: PosTextSize.size4,
        )),
    PosColumn(
        text: "160",
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size4,
          width: PosTextSize.size4,
        )),
  ]);

  bytes += generator.hr(ch: '=', linesAfter: 1);

  // ticket.feed(2);
  bytes += generator.text('Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true));

  bytes += generator.text("26-11-2020 15:22:45",
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  bytes += generator.text(
      'Note: Goods once sold will not be taken back or exchanged.',
      styles: const PosStyles(align: PosAlign.center, bold: false));
  bytes += generator.cut();
  return bytes;
}

/// print installment ticket
Future<bool> printInstallmentReceipt(
    LoanInstallment loanInstallment, double paidAmount) async {
  print('trying to print the receipt.');
  // try to connect to the stored printer
  String? isConnected = await BluetoothThermalPrinter.connectionStatus;
  if (isConnected == "false") {
    bool printerConnected = await connectPrinter();
    if (!printerConnected) {
      // printer not connected, return false.
      print('printer not connected');
      return false;
    }
  }

  // printer has connected, proceed with the print.
  List<int> installmentTicketData =
      await getInstallmentTicket(loanInstallment, paidAmount);
  final result =
      await BluetoothThermalPrinter.writeBytes(installmentTicketData);
  print('result is $result');
  return result == "true";
}

/// connect to the printer with the saved information
Future<bool> connectPrinter() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("printer_mac")) {
    String? printerName = prefs.getString('printer_name');
    String? printerMac = prefs.getString("printer_mac");
    bool isPrinterFound = false;
    if (printerMac != null) {
      // search if the selected printer is set.
      final List? bluetoothDevices =
          await BluetoothThermalPrinter.getBluetooths;
      if (bluetoothDevices!.isNotEmpty) {
        for (final bluetoothDevice in bluetoothDevices) {
          List list = bluetoothDevice.split("#");
          String name = list[0];
          String mac = list[1];
          isPrinterFound = (mac == printerMac);
        }

        if (isPrinterFound) {
          final String? result =
              await BluetoothThermalPrinter.connect(printerMac);
          if (result == "true") {
            return true;
          }
        }
      }
    }
  }

  return false;
}

/// print installment ticket
Future<List<int>> getInstallmentTicket(
    LoanInstallment loanInstallment, double paidAmount) async {
  List<int> bytes = [];
  NumberFormat numberFormat = NumberFormat("#,##0.00");

  CapabilityProfile profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);

  bytes += generator.text("Payment Receipt",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1);

  // bytes += generator.text("18th Main Road, 2nd Phase, J. P. Nagar, Bengaluru, Karnataka 560078", styles: const PosStyles(align: PosAlign.center));
  // bytes += generator.text('Tel: +919591708470', styles: const PosStyles(align: PosAlign.center));

  bytes += generator.hr();

  bytes += generator.row(getTicketRow("Installment Amount",
      numberFormat.format(double.parse(loanInstallment.installmentAmount!))));
  bytes += generator
      .row(getTicketRow("Paid Amount", numberFormat.format(paidAmount)));

  bytes += generator.hr(ch: '=', linesAfter: 1);

  // ticket.feed(2);
  bytes += generator.text('Thank you for your payment!',
      styles: const PosStyles(align: PosAlign.center, bold: true));

  var currentDateTime = DateTime.now();
  var format = DateFormat('yyyy-MM-dd hh:mm a');
  bytes += generator.text(format.format(currentDateTime),
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  bytes += generator.text(
      'Note: Please make a copy of this receipt as the print can be erased easily.',
      styles: const PosStyles(align: PosAlign.center, bold: false));
  bytes += generator.hr(ch: '=', linesAfter: 1);
  bytes += generator.text('Developed by',
      styles: const PosStyles(align: PosAlign.center, bold: false));
  bytes += generator.text('MyBooking.lk',
      styles: const PosStyles(align: PosAlign.center, bold: false));
  bytes += generator.text('+94 716821573 | +94 114161153',
      styles: const PosStyles(align: PosAlign.center, bold: false));
  bytes += generator.cut();
  return bytes;
}

List<PosColumn> getTicketRow(String column1Text, String column2Text) {
  return [
    PosColumn(
        text: column1Text,
        width: 7,
        styles: const PosStyles(
          align: PosAlign.left,
        )),
    PosColumn(
        text: column2Text,
        width: 5,
        styles: const PosStyles(align: PosAlign.right)),
  ];
}
