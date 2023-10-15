import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonDecode;

final storage = FlutterSecureStorage();

class LogListPage extends StatefulWidget {
  final String portAndHost;

  LogListPage(this.portAndHost);

  @override
  State<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends State<LogListPage> {
  @override
  Widget build(BuildContext context) {
    String ipPort = widget.portAndHost;

    Future<List<Widget>> listOfServices() async {
      String? jwt = await storage.read(key: "jwt");
      Map valueMap = json.decode(jwt!);
      String token = valueMap['token'];
      var res = await http
          .get(Uri.https(ipPort, 'relation/getAllLogByUserId'), headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body) as List<dynamic>;
        return jsonData.map((item) {
          String fechaHora = "";
          if (item['createdAt'] != null) {
            final parsedDateTime = DateTime.parse(item['createdAt']);
            final formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
            fechaHora = formatter.format(parsedDateTime);
          }
          return Column(
            children: [
              ListTile(
                title: Text(item['tenant']['username'] + " " + fechaHora),
                leading: Icon(
                  Icons.access_time,
                  color: Colors.black,
                ),
                onTap: () {},
              ),
              Divider()
            ],
          );
        }).toList();
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
