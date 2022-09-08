// ignore_for_file: unnecessary_const, prefer_const_constructors

import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class StockDetails extends StatefulWidget {
  const StockDetails({Key? key, required this.stockSymbol}) : super(key: key);
  final String stockSymbol;
  @override
  State<StockDetails> createState() => _StockDetailsState();
}

class _StockDetailsState extends State<StockDetails> {
  final storage = const FlutterSecureStorage();
  var apiToken;
  late final Future stockData;
  late final stockPriceRange;
  late final Future stockNews;
  late Stream<dynamic> _stream;
  bool _isExpanded = false;
  var savedIcon = const Icon(
    Icons.bookmark_add_outlined,
    color: Colors.grey,
  );

  _getToken() {
    storage.read(key: 'token').then((value) {
      setState(() {
        apiToken = value;
      });
    }).then((value) {
      setState(() {
        stockNews = _getStockNews();
        stockData = _getStockData();
        stockPriceRange = _getStockCloseRange();
        _stream = _getStockPriceStream();
      });
    });
  }

  _getStockData() async {
    final response = await http.get(Uri.parse(
        'http://ec2-15-206-210-181.ap-south-1.compute.amazonaws.com:3000/api/stockdata/allinfo?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  _getStockPrice() async {
    final response = await http.get(Uri.parse(
        'http://ec2-15-206-210-181.ap-south-1.compute.amazonaws.com:3000/api/stockdata/price?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      //print(data);
      return data;
    } else {
      return {'price': 132};
    }
  }

  Stream<dynamic> _getStockPriceStream() async* {
    if (DateTime.now().hour < 15 && DateTime.now().hour > 8) {
      yield* Stream.periodic(const Duration(seconds: 3), (i) {
        var response = _getStockPrice();
        //print(response);
        return response;
      }).asyncMap((value) async => await value);
    } else {
      var response = _getStockPrice();
      yield Map.from(await response);
    }
  }

  _getStockCloseRange() async {
    final response = await http.get(Uri.parse(
        'http://ec2-15-206-210-181.ap-south-1.compute.amazonaws.com:3000/api/stockdata/pricerange?symbol=${widget.stockSymbol}&apiToken=$apiToken&close=true&range=450'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      List<FlSpot> flList = [];

      var dates = data.keys;

      var prices = data.values;

      for (var i = 0; i < data.length; i++) {
        flList.add(FlSpot(
            DateTime.parse(dates.elementAt(i))
                .millisecondsSinceEpoch
                .toDouble(),
            prices.elementAt(i).toDouble()));
      }
      return flList;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  _getStockNews() async {
    final response = await http.get(Uri.parse(
        'http://ec2-15-206-210-181.ap-south-1.compute.amazonaws.com:3000/api/getnews?symbol=${widget.stockSymbol}&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  // ignore: unused_element, prefer_final_fields
  PageController _controller = PageController(
    initialPage: 0,
  );
  var _currentIndex = 0;
  bool _isVisibleAppbar = false;
  bool _isVisibleFAB = false;

  @override
  void initState() {
    _getToken();
    _stream = _getStockPriceStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _isVisibleAppbar ? kToolbarHeight : 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<dynamic>(
        future: stockData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onVerticalDragDown: (details) {
                //print(details.globalPosition.direction);
                if (details.globalPosition.direction > 1) {
                  setState(() {
                    _isVisibleAppbar = false;
                    _isVisibleFAB = true;
                  });
                } else if (details.globalPosition.direction < 1) {
                  setState(() {
                    _isVisibleAppbar = true;
                    _isVisibleFAB = false;
                  });
                }
              },
              child: ListView(
                children: [
                  Column(
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
                            stream: _stream,
                            builder: (
                              BuildContext context,
                              AsyncSnapshot<dynamic> snapshot,
                            ) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  alignment: Alignment.topLeft,
                                  margin:
                                      const EdgeInsets.fromLTRB(25, 0, 0, 0),
                                  height: 45,
                                  child: LoadingAnimationWidget
                                      .horizontalRotatingDots(
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                );
                              } else if (snapshot.connectionState ==
                                      ConnectionState.active ||
                                  snapshot.connectionState ==
                                      ConnectionState.done) {
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
                                                color: Colors.red,
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
                                          '${snapshot.data['Numbers']['pricerange'].last['Open']}')
                                      .toStringAsFixed(2),
                                  style: GoogleFonts.ubuntu(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
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
                      // container with text last 30 day trend
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Trend ',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '52 Weeks',
                                  style: GoogleFonts.ubuntu(
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<dynamic>(
                          future: stockPriceRange,
                          builder: (context, data) {
                            if (data.hasData) {
                              List<FlSpot> dataList = [];
                              for (var i = 0; i < data.data.length; i++) {
                                dataList.add(data.data[i]);
                              }
                              return AspectRatio(
                                aspectRatio: 3.5,
                                child: LineChart(
                                  LineChartData(
                                      gridData: FlGridData(
                                        show: false,
                                      ),
                                      borderData: FlBorderData(
                                        show: true,
                                        border: const Border(
                                          bottom: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 218, 218, 218),
                                            width: 1,
                                          ),
                                          left: const BorderSide(
                                            color: Colors.white,
                                            width: 5,
                                          ),
                                          right: const BorderSide(
                                            color: Colors.white,
                                            width: 5,
                                          ),
                                          top: const BorderSide(
                                            color: Colors.white,
                                            width: 0,
                                          ),
                                        ),
                                      ),
                                      titlesData: FlTitlesData(
                                        show: false,
                                      ),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: dataList,
                                          isCurved: true,
                                          barWidth: 2,
                                          color: Colors.orange,
                                          dotData: FlDotData(
                                            show: false,
                                          ),
                                        ),
                                      ]),
                                ),
                              );
                            } else {
                              return Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                                height: 45,
                                child: LoadingAnimationWidget
                                    .horizontalRotatingDots(
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              );
                            }
                          }),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: FlatButton(
                                  height: 20,
                                  shape: Border(
                                    bottom: BorderSide(
                                      color: _currentIndex == 0
                                          ? Colors.orange
                                          : Colors.grey,
                                      width: _currentIndex == 0 ? 2 : 1,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller.animateToPage(0,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  },
                                  child: Text(
                                    'Financials',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: _currentIndex == 0 ? 16 : 15,
                                      fontWeight: _currentIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _currentIndex == 0
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: FlatButton(
                                  height: 20,
                                  shape: Border(
                                    bottom: BorderSide(
                                      color: _currentIndex == 1
                                          ? Colors.orange
                                          : Colors.grey,
                                      width: _currentIndex == 1 ? 2 : 1,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller.animateToPage(1,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  },
                                  child: Text(
                                    'Technicals',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: _currentIndex == 1 ? 16 : 15,
                                      fontWeight: _currentIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _currentIndex == 1
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                child: FlatButton(
                                  height: 20,
                                  shape: Border(
                                    bottom: BorderSide(
                                      color: _currentIndex == 2
                                          ? Colors.orange
                                          : Colors.grey,
                                      width: _currentIndex == 2 ? 2 : 1,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller.animateToPage(2,
                                        duration: Duration(milliseconds: 100),
                                        curve: Curves.linear);
                                  },
                                  child: Text(
                                    '   News   ',
                                    style: GoogleFonts.ubuntu(
                                      fontSize: _currentIndex == 2 ? 16 : 15,
                                      fontWeight: _currentIndex == 2
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: _currentIndex == 2
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height + 914,
                        child: PageView(
                          controller: _controller,
                          onPageChanged: (value) {
                            setState(() {
                              _currentIndex = value;
                            });
                          },
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 15, 25, 0),
                              child: Column(
                                children: _buildFinancialsList(
                                    snapshot.data['Numbers']['financials']
                                        ['incomeStatement']),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 15, 25, 0),
                              child: Column(
                                children: _buildTchnicalsList(
                                    snapshot.data['Numbers']['technical']),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(15, 15, 25, 0),
                              child: FutureBuilder<dynamic>(
                                future: stockNews,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    List<Container> list = [];

                                    for (var i = 0;
                                        i < snapshot.data['articles'].length;
                                        i++) {
                                      list.add(Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 0, 15),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              isThreeLine: true,
                                              leading: Image.network(
                                                snapshot.data['articles'][i]
                                                    ['urlToImage'],
                                                width: 65,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                              title: Text(
                                                snapshot.data['articles'][i]
                                                    ['title'],
                                                style: GoogleFonts.ubuntu(
                                                  fontSize: 15,
                                                ),
                                              ),
                                              subtitle: RichText(
                                                text: TextSpan(
                                                  text:
                                                      snapshot.data['articles']
                                                          [i]['description'],
                                                  style: GoogleFonts.ubuntu(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              onTap: () {
                                                launch(snapshot.data['articles']
                                                        [i]['url']
                                                    .toString());
                                              },
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                i % 2 == 0
                                                    ? Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 15, 0),
                                                        child: Text(
                                                          'Sentiment: Positive',
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                            fontSize: 14,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 0, 15, 0),
                                                        child: Text(
                                                          'Sentiment: Negative',
                                                          style: GoogleFonts
                                                              .ubuntu(
                                                            fontSize: 14,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ));
                                    }

                                    return Column(children: list);
                                  } else {
                                    return Container(
                                      alignment: Alignment.topLeft,
                                      margin: const EdgeInsets.fromLTRB(
                                          25, 0, 0, 0),
                                      height: 45,
                                      child: LoadingAnimationWidget
                                          .horizontalRotatingDots(
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  List<Container> _buildFinancialsList(Map<dynamic, dynamic> data) {
    List<Container> list = [];

    data.forEach((key, value) {
      list.add(Container(
        child: ListTile(
          title: Text(
            key,
            style: GoogleFonts.ubuntu(
              fontSize: 15,
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              (value),
              style: GoogleFonts.ubuntu(
                fontSize: 15,
              ),
            ),
          ),
        ),
      ));
      Spacer();
    });
    return list;
  }

  List<Container> _buildTchnicalsList(Map<dynamic, dynamic> data) {
    List<Container> list = [];

    data.forEach((key, value) {
      list.add(Container(
        child: Column(
          children: [
            ListTile(
              leading: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.orange,
                  size: 20,
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key,
                    style: GoogleFonts.ubuntu(
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    (value.values.first).toStringAsFixed(2),
                    style: GoogleFonts.ubuntu(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: _isExpanded
                  ? Card(
                      color: Colors.grey[200],
                      shape: ShapeBorder.lerp(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        0.5,
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Recommendation',
                              style: GoogleFonts.ubuntu(
                                fontSize: 15,
                              ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text(
                                (value.values.last),
                                style: GoogleFonts.ubuntu(
                                  fontSize: 15,
                                  color: (value.values.last) == 'Buy'
                                      ? Colors.green
                                      : (value.values.last) == 'Sell'
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Why it is a ${value.values.last}?',
                              style: GoogleFonts.ubuntu(
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                              style: GoogleFonts.ubuntu(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Learn ${key} in 5 minutes',
                              style: GoogleFonts.ubuntu(
                                fontSize: 15,
                              ),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.orange,
                                size: 15,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  : Container(),
            )
          ],
        ),
      ));
      Spacer();
    });
    return list;
  }

  List<Container> _buildNews(List<dynamic> data) {
    List<Container> list = [];

    data.forEach((element) {
      list.add(Container(
        child: ListTile(
          title: Text(
            element['title'],
            style: GoogleFonts.ubuntu(
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            element['description'],
            style: GoogleFonts.ubuntu(
              fontSize: 15,
            ),
          ),
        ),
      ));
    });
    return list;
  }
}

class TabsIcon extends StatelessWidget {
  final Color color;
  final double height;
  final double width;
  final IconData icons;

  const TabsIcon(
      {Key? key,
      this.color = Colors.white,
      this.height = 60,
      this.width = 50,
      required this.icons})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: Icon(
          icons,
          color: color,
        ),
      ),
    );
  }
}
