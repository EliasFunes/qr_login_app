import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonDecode;

final storage = FlutterSecureStorage();

class TenantListPage extends StatefulWidget {
  final String portAndHost;

  TenantListPage(this.portAndHost);

  @override
  State<TenantListPage> createState() => _TenantListPageState();
}

class _TenantListPageState extends State<TenantListPage> {
  @override
  Widget build(BuildContext context) {
    String ipPort = widget.portAndHost;

    Future<List<Widget>> listOfServices() async {
      String? jwt = await storage.read(key: "jwt");
      Map valueMap = json.decode(jwt!);
      String token = valueMap['token'];
      var res =
          await http.get(Uri.https(ipPort, 'relation/getAllByUser'), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body) as List<dynamic>;
        return jsonData
            .map((item) => Column(
                  children: [
                    ListTile(
                      title: Text(item['tenant']['username'] +
                          " " +
                          item['tenant']['email']),
                      leading: Icon(
                        Icons.app_shortcut,
                        color: Colors.black,
                      ),
                      onTap: () {},
                    ),
                    Divider()
                  ],
                ))
            .toList();
      } else {
        //TODO: Handle the error
        return [
          Column(
            children: [
              ListTile(
                title: Text("No se encontraron servicios o apps relacionadas"),
                leading: Icon(
                  Icons.app_shortcut,
                  color: Colors.black,
                ),
                onTap: () {},
              ),
              Divider()
            ],
          )
        ];
      }
    }

    ;

    return Scaffold(
      appBar: AppBar(title: Text("QR-Login-App")),
      body: FutureBuilder<List<Widget>>(
          future: listOfServices(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return data[index];
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando...'),
              ],
            ));
          }),
    );
  }
}
