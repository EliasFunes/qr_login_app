import 'package:flutter/material.dart';
import 'package:qr_login_app/src/pages/login_page.dart';

Map<String, Widget Function(BuildContext)> getApplicationRoutes() => {
      '/': (BuildContext context) => LoginPage(),
      'login': (BuildContext context) => LoginPage(),
    };
