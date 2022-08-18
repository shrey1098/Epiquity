import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_flutter/screens/authScreen.dart';
import 'package:frontend_flutter/screens/homeScreen.dart';

void main() async {
  runApp(const EpiquityApp());
}

class EpiquityApp extends StatefulWidget {
  const EpiquityApp({Key? key}) : super(key: key);
  @override
  State<EpiquityApp> createState() => _EpiquityAppState();
}

class _EpiquityAppState extends State<EpiquityApp> {
  String? token;
  final storage = new FlutterSecureStorage();

  _getToken() async {
    await storage.write(key: 'token', value: 'Il0.CmCil_jgpZId1X');
    await storage.read(key: 'token').then((value) {
      setState(() {
        token = value;
        print(token);
      });
    });
  }

  @override
  void initState() {
    _getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        '/home': (context) => const AuthScreen(),
        '/login': (context) => const HomeScreen(),
      },
    );
  }
}
