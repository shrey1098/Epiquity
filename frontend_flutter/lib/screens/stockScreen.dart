import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key, required this.stockSymbol}) : super(key: key);
  final String stockSymbol;
  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  final storage = FlutterSecureStorage();
  var apiToken;

  _getToken() async {
    await storage.read(key: 'token').then((value) {
      setState(() {
        apiToken = value;
      });
    });
  }

  _getStockData() async {
    final response = await http.get(Uri.parse(
        'http://ec2-43-204-98-31.ap-south-1.compute.amazonaws.com:3000/api/stockdata/allinfo?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  @override
  void initState() {
    _getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stockSymbol),
      ),
      body: Center(
        child: FutureBuilder<dynamic>(
          future: _getStockData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data['Numbers']['price'].toString());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
