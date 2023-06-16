import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_login_app/src/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController ipPortController =
      TextEditingController(text: '192.168.0.6:8080');

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Register'),
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
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'email',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                  child: TextField(
                    obscureText: true,
                    controller: rePasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Re-Password',
                    ),
                  ),
                ),
                Container(
                    height: 50,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: RaisedButton(
                      textColor: Colors.white,
                      color: Colors.blue,
                      child: Text('Register'),
                      onPressed: () async {
                        var username = nameController.text;
                        var email = emailController.text;
                        var password = passwordController.text;
                        var rePassword = rePasswordController.text;
                        var ipPort = ipPortController.text;
                        var success = await attemptRegister(
                            username, email, password, rePassword, ipPort);

                        if (success) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        } else {
                          displayDialog(context, "An Error Occurred",
                              "Cannot register user");
                        }
                      },
                    )),
              ],
            )));
  }
}

Future<bool> attemptRegister(String username, String email, String password,
    String rePassword, String ipPortController) async {
  var res = await http.post(Uri.http(ipPortController, '/jwt/user/register'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "username": username,
        "email": email,
        "password": password,
        "rePassword": rePassword
      }));

  if (res.statusCode == 200) return true;
  return false;
}
