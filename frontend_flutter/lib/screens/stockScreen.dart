import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key, required this.stockSymbol}) : super(key: key);
  final String stockSymbol;
  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  final storage = const FlutterSecureStorage();
  var apiToken;
  var savedIcon = const Icon(
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
      yield* Stream.periodic(const Duration(seconds: 3), (i) {
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
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.orange),
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
                  margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                  child: ListTile(
                    title: Text(
                      '${snapshot.data['name']}',
                      style: GoogleFonts.ubuntu(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${snapshot.data['sector']}',
                      style: GoogleFonts.ubuntu(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
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
                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                  child: StreamBuilder(
                      stream: _getStockPriceStream(),
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<dynamic> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.fromLTRB(25, 0, 0, 0),
                            height: 45,
                            child:
                                LoadingAnimationWidget.horizontalRotatingDots(
                              color: Colors.orange,
                              size: 20,
                            ),
                          );
                        } else if (snapshot.connectionState ==
                                ConnectionState.active ||
                            snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return const Text('Error fetching price');
                          } else if (snapshot.hasData) {
                            return Container(
                              alignment: Alignment.topLeft,
                              child: ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Text(
                                  '${snapshot.data['price']['price']}',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                title: Row(children: [
                                  snapshot.data['price']['change'] > 0
                                      ? const Icon(
                                          Icons.arrow_drop_up,
                                          color: Colors.green,
                                        )
                                      : const Icon(
                                          Icons.arrow_drop_down,
                                          color: Color(0xFFC62828),
                                        ),
                                  Text(
                                      '${snapshot.data['price']['change_percent']}'
                                      '%',
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 18,
                                          color: snapshot.data['price']
                                                      ['change'] >
                                                  0
                                              ? Colors.green
                                              : Colors.red[800])),
                                  Text(
                                      "("
                                      '${snapshot.data['price']['change']}'
                                      ")",
                                      style: GoogleFonts.ubuntu(
                                          fontSize: 18,
                                          color: snapshot.data['price']
                                                      ['change'] >
                                                  0
                                              ? Colors.green
                                              : Colors.red[800])),
                                ]),
                              ),
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
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Open: ',
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            num.parse(
                                    '${snapshot.data['Numbers']['pricerange'][26]['Open']}')
                                .toStringAsFixed(2),
                            style: GoogleFonts.ubuntu(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Market Cap: ',
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${snapshot.data['marketcap']}',
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SfSparkAreaChart(
                  data: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
                  color: Colors.orange,
                  borderColor: Colors.black,
                )
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
