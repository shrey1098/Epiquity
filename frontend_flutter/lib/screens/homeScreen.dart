// ignore_for_file: sort_child_properties_last, prefer_const_constructors
import 'dart:convert';
import 'dart:html';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:floating_frosted_bottom_bar/floating_frosted_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'stockScreen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
      body: Column(
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
                          'http://ec2-43-204-98-31.ap-south-1.compute.amazonaws.com:3000/api/search?q=$pattern&apiToken=$apiToken'));
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
            color: Colors.white,
          )
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
