import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, base64, ascii;

class HomePage extends StatefulWidget {
  final String jwt;
  final Map<String, dynamic> payload;
  final String portAndHost;

  factory HomePage.fromBase64(String jwt, String portAndHost) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))),
      portAndHost);

  HomePage(this.jwt, this.payload, this.portAndHost);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    Map valueMap = json.decode(widget.jwt);
    String token = valueMap['token'];
    String ipPort = widget.portAndHost;

    _scan() async => await FlutterBarcodeScanner.scanBarcode(
                "#2560f5", "Cancel", true, ScanMode.QR)
            .then((value) {
          setState(() {
            http.post(Uri.http(ipPort, 'ws/sendToUser'),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
                body: json.encode({"tokenQr": value}));
          });
        });

    return Scaffold(
      appBar: AppBar(title: Text("QR-Login-App")),
      body: Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scan(),
        child: Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
