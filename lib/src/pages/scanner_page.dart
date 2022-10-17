import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

class ScannerPage extends StatefulWidget {
  final String ip;
  final String port;
  final String token;
  ScannerPage(this.ip, this.port, this.token);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _data = "";

  @override
  Widget build(BuildContext context) {
    Map valueMap = json.decode(widget.token);
    String token = valueMap['token'];

    print(' PUERTOO => ${widget.port}');
    String ipPort = "${widget.ip}:${widget.port}";

    print(' IP PORT ENVIADO $ipPort');

    print("ENVIANDO TOKEN $token");

    _scan() async => await FlutterBarcodeScanner.scanBarcode(
                "#000000", "Cancel", true, ScanMode.QR)
            .then((value) {
          print("ID QR A ENVIAR => $value");

          setState(() {
            _data = value;
            http.post(Uri.http(ipPort, 'test/sendToUser'),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
                body: json.encode({"tokenQr": value}));
          });
        });

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(_data)],
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () => _scan(),
        child: Text('Scan Qr'),
      ),
    );
  }
}
