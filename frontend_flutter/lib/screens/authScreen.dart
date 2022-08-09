import 'dart:io';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  _pageRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(1.0, 0.0);
        var end = Offset.zero;
        var tween = Tween(begin: begin, end: end);
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) => GoogleRegister(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Epiquity',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: // button with text
            Center(
          child: ElevatedButton(
            onPressed: () {
              html.window
                  .open("http://localhost:3000/api/register/google", "_self");
            },
            child: const Text('Register with google'),
          ),
        ),
      ),
    );
  }
}

class GoogleRegister extends StatefulWidget {
  const GoogleRegister({Key? key}) : super(key: key);

  @override
  State<GoogleRegister> createState() => _GoogleRegisterState();
}

class _GoogleRegisterState extends State<GoogleRegister> {
  late WebViewController _controller;
  late String token;
  final storage = new FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Epiquity',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: WebView(
        initialUrl: 'http://localhost:3000/api/register/google',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller = controller;
        },
        onPageFinished: (String url) {
          if (url.contains('http://localhost:3000/api/register/google')) {
            _controller.evaluateJavascript(
                'document.getElementById("token").value = "$token";');
          }
        },
      ),
    );
  }
}
