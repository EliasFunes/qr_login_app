import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, base64, ascii;

import 'package:qr_login_app/src/pages/scanner_page.dart';

// const SERVER_IP = '192.168.0.3:8080';

class HomePage extends StatelessWidget {
  HomePage(this.jwt, this.payload, this.portAndHost);

  factory HomePage.fromBase64(String jwt, String portAndHost) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))),
      portAndHost);

  final String jwt;
  final Map<String, dynamic> payload;
  final String portAndHost;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Secret Data Screen")),
        body: Center(
          child: FutureBuilder(
              future: http.read(Uri.http(portAndHost, 'test/jdbc_test'),
                  headers: {
                    "Authorization": 'Bearer $jwt',
                    'Content-Type': 'text/plain'
                  }),
              builder: (context, snapshot) => snapshot.hasData
                  ? Column(
                      children: <Widget>[
                        Text("${payload['username']}, here's the data:"),
                        Text(snapshot.data.toString(),
                            style: Theme.of(context).textTheme.displayMedium)
                      ],
                    )
                  : snapshot.hasError
                      ? Text("An error occurred ${snapshot.error}")
                      : CircularProgressIndicator()),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            var splited = portAndHost.split(":");
            return ScannerPage(splited.first, splited[1], jwt);
          })),
          child: Icon(Icons.qr_code_scanner),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
}
