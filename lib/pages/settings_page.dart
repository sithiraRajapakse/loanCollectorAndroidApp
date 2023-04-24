import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  String selectedPrinterName = '';
  String selectedPrinterAddress = '';

  bool connected = false;
  List? availableBluetoothDevices = [];

  Future<void> getBluetooth() async {
    final List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
    print("Print $bluetooths");
    setState(() {
      availableBluetoothDevices = bluetooths;
    });
  }

  Future<void> setConnect(String mac) async {
    final String? result = await BluetoothThermalPrinter.connect(mac);
    print("state conneected $result");
    if (result == "true") {
      setState(() {
        connected = true;
      });
    }
  }

  void showSelectedPrinterAtInit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPrinterName = prefs.getString('printer_name') ?? '';
      selectedPrinterAddress = prefs.getString('printer_mac') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();

    showSelectedPrinterAtInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: const [
                  Icon(Icons.settings_bluetooth_sharp),
                  Text(
                    'Search Paired Bluetooth Devices',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlue[400],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'Please Note:\nThe printer must be powered on and paired with the phone at the moment in order to be listed.',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(width: double.infinity, child: getSelectedPrinterWidget()),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: () {
                  getBluetooth();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.bluetooth_searching_sharp),
                    Text('Search for Bluetooth devices'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: availableBluetoothDevices!.isNotEmpty
                    ? availableBluetoothDevices!.length
                    : 0,
                itemBuilder: (context, index) {
                  String select = availableBluetoothDevices![index];
                  return ListTile(
                    onTap: () async {
                      List list = select.split("#");
                      String name = list[0];
                      String mac = list[1];
                      setConnect(mac);
                      SharedPreferences preferences =
                          await SharedPreferences.getInstance();
                      preferences.setString("printer_name", name);
                      preferences.setString("printer_mac", mac);
                      setState(() {
                        selectedPrinterName = name;
                        selectedPrinterAddress = mac;
                      });
                      showMessage("Device $name selected successfully.");
                      // printTicket();
                    },
                    title: Text('${availableBluetoothDevices![index]}'),
                    subtitle: const Text("Click to select the printer"),
                    leading: Icon(Icons.print),
                    minLeadingWidth: 16.0,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget getSelectedPrinterWidget() {
    if (selectedPrinterAddress == '') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blueGrey[400],
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: const Text(
          'No printer selected.',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[600],
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Printer',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedPrinterName,
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                Text(
                  selectedPrinterAddress,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
