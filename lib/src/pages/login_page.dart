import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:qr_login_app/src/pages/home_page.dart';

// const SERVER_IP = '192.168.0.3:8080';
final storage = FlutterSecureStorage();

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController ipPortController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
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
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: ipPortController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ip and port of host server',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User Name',
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
                      labelText: 'Password',
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
                  child: Text('Forgot Password'),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Login'),
                      onPressed: () async {
                        print(nameController.text);
                        print(passwordController.text);

                        var username = nameController.text;
                        var password = passwordController.text;
                        var ipPort = ipPortController.text;
                        var jwt =
                            await attemptLogIn(username, password, ipPort);
                        if (jwt != null) {
                          storage.write(key: "jwt", value: jwt);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage.fromBase64(
                                      jwt, ipPortController.text)));
                        } else {
                          displayDialog(context, "An Error Occurred",
                              "No account was found matching that username and password");
                        }
                      },
                    )),
                Container(
                    child: Row(
                  children: <Widget>[
                    Text('Does not have account?'),
                    TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: Text(
                        'Sign in',
                        style: TextStyle(fontSize: 20),
                      ),
                      onPressed: () {
                        //signup screen
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
  var res = await http.post(Uri.http(ipPortController, 'jwt/user/authenticate'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}));
  if (res.statusCode == 200) return res.body;
  return null;
}

Future<int> attemptSignUp(String username, String password) async {
  var res = await http.post(Uri.http('', 'signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}));
  return res.statusCode;
}
