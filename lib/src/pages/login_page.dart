import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_login_app/src/pages/home_page.dart';
import 'package:qr_login_app/src/pages/register_page.dart';

final storage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  /*TextEditingController ipPortController =
      TextEditingController(text: '192.168.0.6:8080');*/

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Inicio de sesión'),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'QR Login App',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                          fontSize: 30),
                    )),
                /* Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: ipPortController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ip y puerto del servidor',
                    ),
                  ),
                ),*/
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nombre de usuario',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Contraseña',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    //forgot password screen
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.blue,
                  ),
                  child: Text('Has olvidado tu contraseña?'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Iniciar sesión'),
                      onPressed: () async {
                        var username = nameController.text;
                        var password = passwordController.text;
                        var ipPort = "qrloginserver.eliasfunes.com";
                        var jwt =
                            await attemptLogIn(username, password, ipPort);
                        if (jwt != null) {
                          storage.write(key: "jwt", value: jwt);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage(
                                      "qrloginserver.eliasfunes.com")));
                        } else {
                          displayDialog(context, "Ocurrió un error",
                              "No se encontró ninguna cuenta que coincida con ese nombre de usuario y contraseña");
                        }
                      },
                    )),
                Container(
                    child: Row(
                  children: <Widget>[
                    Text('No tiene cuenta?'),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()));
                      },
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ))
              ],
            )));
  }
}

Future<String?> attemptLogIn(
    String username, String password, String ipPortController) async {
  var res = await http.post(
      Uri.https(ipPortController, 'jwt/user_lessor/authenticate'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}));
  if (res.statusCode == 200) return res.body;
  return null;
}
