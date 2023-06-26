import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:qr_login_app/src/pages/tenant_list_page.dart';
import 'log_list_page.dart';

final storage = FlutterSecureStorage();

class HomePage extends StatefulWidget {
  final String portAndHost;

  HomePage(this.portAndHost);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    String ipPort = widget.portAndHost;

    _scan() async => await FlutterBarcodeScanner.scanBarcode(
                "#2560f5", "Cancel", true, ScanMode.QR)
            .then((value) {
          setState(() async {
            String? jwt = await storage.read(key: "jwt");
            Map valueMap = json.decode(jwt!);
            String token = valueMap['token'];

            http.post(Uri.http(ipPort, 'ws/sendToUser'),
                headers: {
                  "Content-Type": "application/json",
                  "Authorization": "Bearer $token",
                },
                body: json.encode({"tokenQr": value}));
          });
        });

    List<Widget> _listaItems(BuildContext context) => [
          Column(
            children: [
              ListTile(
                title: Text("Servicios/Apps Relacionadas"),
                leading: Icon(
                  Icons.people_alt_outlined,
                  color: Colors.blue,
                ),
                trailing: Icon(Icons.keyboard_arrow_right, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TenantListPage(widget.portAndHost)));
                },
              ),
              Divider()
            ],
          ),
          Column(
            children: [
              ListTile(
                title: Text("Lista de lecturas QR"),
                leading: Icon(
                  Icons.list,
                  color: Colors.blue,
                ),
                trailing: Icon(Icons.keyboard_arrow_right, color: Colors.blue),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              LogListPage(widget.portAndHost)));
                },
              ),
              Divider()
            ],
          ),
          Column(
            children: [
              ListTile(
                title: Text("Ejecuciones"),
                leading: Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                enabled: false,
              ),
              Divider()
            ],
          ),
          Column(
            children: [
              ListTile(
                title: Text("Gráficos"),
                leading: Icon(
                  Icons.auto_graph,
                  color: Colors.blue,
                ),
                enabled: false,
              ),
              Divider()
            ],
          ),
          Column(
            children: [
              ListTile(
                title: Text("Configuración"),
                leading: Icon(
                  Icons.settings,
                  color: Colors.blue,
                ),
                enabled: false,
              ),
              Divider()
            ],
          )
        ];

    Widget _lista() {
      return ListView(
        children: _listaItems(context),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("QR-Login-App")),
      body: _lista(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scan(),
        child: Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
