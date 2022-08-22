// ignore_for_file: sort_child_properties_last, prefer_const_constructors
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'stockScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int currentPage;
  late TabController tabController;

  @override
  void initState() {
    currentPage = 0;
    tabController = TabController(length: 3, vsync: this);
    tabController.animation!.addListener(
      () {
        final value = tabController.animation!.value.round();
        if (value != currentPage && mounted) {
          changePage(value);
        }
      },
    );
    super.initState();
  }

  void changePage(int newPage) {
    setState(() {
      currentPage = newPage;
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FrostedBottomBar(
      opacity: 0.6,
      bottomBarColor: Color.fromARGB(255, 77, 75, 75),
      sigmaX: 5,
      sigmaY: 5,
      child: TabBar(
        indicatorPadding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
        controller: tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Colors.orange, width: 4),
          insets: EdgeInsets.fromLTRB(16, 0, 16, 8),
        ),
        tabs: [
          TabsIcon(
              icons: Icons.home,
              color: currentPage == 0 ? Colors.orange : Colors.white),
          TabsIcon(
              icons: Icons.book,
              color: currentPage == 1 ? Colors.orange : Colors.white),
          TabsIcon(
              icons: Icons.settings,
              color: currentPage == 2 ? Colors.orange : Colors.white),
        ],
      ),
      borderRadius: BorderRadius.circular(500),
      duration: const Duration(milliseconds: 800),
      hideOnScroll: true,
      body: (BuildContext context, ScrollController controller) {
        // see the current page count and set the current page
        return page(currentPage);
      },
    ));
  }

  page(index) {
    if (index == 0) {
      return const Home();
    }
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final storage = FlutterSecureStorage();
  var apiToken;

  _getToken() async {
    await storage.read(key: 'token').then((value) {
      setState(() {
        apiToken = value;
      });
    });
  }

  _getNIFTYPrice() async {
    final response = await http.get(Uri.parse(
        'http://ec2-52-66-130-245.ap-south-1.compute.amazonaws.com:3000/api/stockdata/price?symbol=^NSEI&apiToken=$apiToken'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Stream<dynamic> _getNIFTYPriceStream() async* {
    if (DateTime.now().hour < 15 && DateTime.now().hour > 8) {
      yield* Stream.periodic(const Duration(seconds: 3), (i) {
        var response = _getNIFTYPrice();
        return response;
      }).asyncMap((value) async => await value);
    } else {
      var response = _getNIFTYPrice();
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          'epiquity',
          style: GoogleFonts.ubuntu(
            fontSize: 30,
            color: Colors.orange,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            color: Colors.black,
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 20,
                width: MediaQuery.of(context).size.width / 1.3,
                child: TypeAheadField(
                  textFieldConfiguration: TextFieldConfiguration(
                    style: GoogleFonts.ubuntu(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      hintText: 'Search stocks',
                      hintStyle: GoogleFonts.ubuntu(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: Colors.orange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    if (pattern.length >= 3) {
                      final response = await http.get(Uri.parse(
                          'http://ec2-52-66-130-245.ap-south-1.compute.amazonaws.com:3000/api/search?q=$pattern&apiToken=$apiToken'));
                      final stocks = json.decode(response.body);
                      if (kIsWeb) {
                        for (var i = 0; i < stocks.length; i++) {
                          stocks[i]['symbol'] =
                              stocks[i]['symbol'].toUpperCase();
                        }
                      }
                      return stocks;
                    } else {
                      return [];
                    }
                  },
                  itemBuilder: (BuildContext context, itemData) {
                    var data = itemData as Map;
                    return Column(
                      children: [
                        ListTile(
                          title: Text(
                            data['name'],
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: Text(
                            data['exchange'],
                            style: GoogleFonts.ubuntu(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Divider(color: Colors.grey, height: .8),
                      ],
                    );
                  },
                  onSuggestionSelected: (Object? suggestion) {
                    var data = suggestion as Map;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetails(
                          stockSymbol: data['yahooFinanceSymbol'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.topLeft,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 20, 0, 0),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'NIFTY',
                    style: GoogleFonts.ubuntu(
                      fontSize: 25,
                      color: Colors.black,
                    ),
                  ),
                ),
                StreamBuilder<dynamic>(
                    stream: _getNIFTYPriceStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 50,
                          child: LoadingAnimationWidget.horizontalRotatingDots(
                            color: Colors.orange,
                            size: 15,
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
                                        color:
                                            snapshot.data['price']['change'] > 0
                                                ? Colors.green
                                                : Colors.red[800])),
                                Text(
                                    "("
                                    '${snapshot.data['price']['change']}'
                                    ")",
                                    style: GoogleFonts.ubuntu(
                                        fontSize: 18,
                                        color:
                                            snapshot.data['price']['change'] > 0
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
                Container(
                  margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  alignment: Alignment.topLeft,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'Market is down today Tread carefully',
                    style: GoogleFonts.ubuntu(
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
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
