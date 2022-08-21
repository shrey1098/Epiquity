import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key, required this.stockSymbol}) : super(key: key);
  final String stockSymbol;
  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  final storage = FlutterSecureStorage();
  var apiToken;
  var savedIcon = Icon(
    Icons.bookmark_add_outlined,
    color: Colors.grey,
  );

  _getToken() async {
    await storage.read(key: 'token').then((value) {
      setState(() {
        apiToken = value;
      });
    });
  }

  _getStockData() async {
    final response = await http.get(Uri.parse(
        'http://ec2-52-66-130-245.ap-south-1.compute.amazonaws.com:3000/api/stockdata/allinfo?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  _getStockPrice() async {
    final response = await http.get(Uri.parse(
        'http://ec2-52-66-130-245.ap-south-1.compute.amazonaws.com:3000/api/stockdata/price?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Stream<dynamic> _getStockPriceStream() async* {
    if (DateTime.now().hour < 15 && DateTime.now().hour > 8) {
      yield* Stream.periodic(Duration(seconds: 10), (i) {
        var response = _getStockPrice();
        return response;
      }).asyncMap((value) async => await value);
    } else {
      var response = _getStockPrice();
      yield Map.from(await response);
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
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: _getStockData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: ListTile(
                    title: Text(
                      '${snapshot.data['name']}',
                      style: GoogleFonts.ubuntu(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: GestureDetector(
                        onTap: () => setState(() {
                              savedIcon = const Icon(Icons.bookmark_added,
                                  color: Colors.orange);
                            }),
                        child: savedIcon),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: StreamBuilder(
                      stream: _getStockPriceStream(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<dynamic> snapshot,
                      ) {
                        print(snapshot.data.toString());
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.orange,
                            size: 15,
                          );
                        } else if (snapshot.connectionState ==
                                ConnectionState.active ||
                            snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return const Text('Error fetching price');
                          } else if (snapshot.hasData) {
                            return Row(
                              children: [
                                Text(
                                  '${snapshot.data['price']['price']}',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data['price']['change']}',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${snapshot.data['price']['change_percent']}',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Text(
                              'Error fetching price',
                              style: GoogleFonts.ubuntu(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        } else {
                          return Text(
                            'State: ${snapshot.connectionState}',
                            style: GoogleFonts.ubuntu(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      }),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return Center(
            child: LoadingAnimationWidget.newtonCradle(
                color: Colors.orange, size: 80),
          );
        },
      ),
    );
  }
}

class OverflowProofText extends StatelessWidget {
  const OverflowProofText({required this.text, required this.fallback});

  final Text text;
  final Text fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child:
            LayoutBuilder(builder: (BuildContext context, BoxConstraints size) {
          final TextPainter painter = TextPainter(
            maxLines: 1,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
            text: TextSpan(
                style: text.style ?? DefaultTextStyle.of(context).style,
                text: text.data),
          );

          painter.layout(maxWidth: size.maxWidth);

          return painter.didExceedMaxLines ? fallback : text;
        }));
  }
}
