import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_flutter/screens/authScreen.dart';

void main() {
  runApp(const EpiquityApp());
}

class EpiquityApp extends StatefulWidget {
  const EpiquityApp({Key? key}) : super(key: key);
  @override
  State<EpiquityApp> createState() => _EpiquityAppState();
}

class _EpiquityAppState extends State<EpiquityApp> {
  getToken() {
    const storage = FlutterSecureStorage();
    return storage.read(key: 'token');
  }

  @override
  Widget build(BuildContext context) {
    var token = getToken();
    return MaterialApp(
      title: 'Epiquity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color.fromARGB(255, 227, 137, 19),
        secondaryHeaderColor: const Color.fromARGB(255, 227, 137, 19),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: token == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const AuthScreen(),
        '/home': (context) => const AuthScreen(),
      },
    );
  }
}
