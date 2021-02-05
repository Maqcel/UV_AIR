import 'dart:typed_data';

import 'package:UV_AIR/value_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

class SensorScreen extends StatefulWidget {
  SensorScreen({Key key}) : super(key: key);
  final String bltAddress = '24:6F:28:2E:7F:BE';
  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  BluetoothConnection connection;

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;
  String value = "";

  void connectToDevice() {
    BluetoothConnection.toAddress(widget.bltAddress).then((_connection) {
      print('Udało się podłączyć do czujnika');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      return showDialog(
        context: context,
        child: AlertDialog(
          title: Text('Nie udało się połączyć'),
          content: Text(
              'Sprawdź czy ESP32 jest włączone lub czy moduł Bluetooth w telefonie działa poprawnie'),
          actions: [
            FlatButton(
              onPressed: () {
                connectToDevice();
                Navigator.of(context).pop();
              },
              child: Text('Spróbuj ponownie'),
            )
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      setState(() {
        connection = null;
      });
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ValueProvider provider = Provider.of<ValueProvider>(context, listen: true);
    print('VALUE TO SHOW: ${provider.value}');
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Color.fromRGBO(29, 60, 169, 1.0),
        title: Center(child: Text('UV APP')),
      ),
      body: Container(
        color: Color.fromRGBO(53, 53, 53, 1.0),
        child: Center(
          child: connection != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(
                      Icons.wb_sunny_rounded,
                      size: 300,
                      color: int.parse(provider.value) >= 11
                          ? Colors.purple
                          : int.parse(provider.value) >= 8 &&
                                  int.parse(provider.value) <= 10
                              ? Colors.red
                              : int.parse(provider.value) >= 6 &&
                                      int.parse(provider.value) <= 7
                                  ? Colors.orange
                                  : int.parse(provider.value) >= 3 &&
                                          int.parse(provider.value) <= 5
                                      ? Colors.yellow
                                      : Colors.green,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromRGBO(29, 60, 169, 1.0),
                      ),
                      width: 220,
                      height: 120,
                      child: Center(
                        child: Text(
                          'UV index: \n${provider.value}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: CircularProgressIndicator(
                        backgroundColor: Color.fromRGBO(0, 22, 99, 1.0),
                      ),
                      height: 200,
                      width: 200,
                    ),
                    Text(
                      'Connecting to device',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 40,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    Provider.of<ValueProvider>(context, listen: false).updateValue(dataString);
    // print("\nODCZYTANO: $dataString\n");
  }
}
