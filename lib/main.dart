import 'dart:convert';
import 'package:coomer_android/CreatorDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.
import 'app/app.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pages/home_page.dart';
import 'pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(MyApp());
}

final theme = AppTheme();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coomer.Party',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: ThemeMode.system,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> creatorsList = [];
  List<Map<String, dynamic>> filteredCreatorsList = [];
  List<String> services = [];
  String selectedService = 'All';
  String selectedSort = 'Popularity';

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCreatorsList();
  }

  Future<void> loadCreatorsList() async {
    try {
      // Attempt to load data from local storage
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String cachedData = prefs.getString('creatorsList') ?? '';

      if (cachedData.isNotEmpty) {
        final List<dynamic> cachedList = json.decode(cachedData);
        setState(() {
          creatorsList = List<Map<String, dynamic>>.from(cachedList);
          filteredCreatorsList = creatorsList;
          services = creatorsList
              .map<String>((creator) => creator['service'])
              .toSet()
              .toList();
          services.insert(0, 'All');
          _sortList();
        });
      }

      // Fetch data from the internet to ensure it is up to date
      fetchCreatorsList();
    } catch (e) {
      print('Error loading creators list: $e');
      // Handle the error as needed
    }
  }

  Future<void> fetchCreatorsList() async {
    try {
      final Uri url = Uri.parse('https://coomer.su/api/v1/creators.txt');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          creatorsList = List<Map<String, dynamic>>.from(
              json.decode(utf8.decode(response.bodyBytes)));
          filteredCreatorsList = creatorsList;
          services = creatorsList
              .map<String>((creator) => creator['service'])
              .toSet()
              .toList();
          services.insert(0, 'All');
          _sortList();
        });

        // Save the data to local storage
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('creatorsList', json.encode(creatorsList));
      } else {
        throw Exception('Failed to load creators');
      }
    } catch (e) {
      print('Error fetching creators list: $e');
      // Handle the error as needed
    }
  }

  void _sortList() {
    if (selectedSort == 'Alphabetical') {
      filteredCreatorsList.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (selectedSort == 'Popularity') {
      filteredCreatorsList
          .sort((a, b) => b['favorited'].compareTo(a['favorited']));
    }
  }

  void searchByNameAndService(String nameQuery, String serviceQuery) {
    setState(() {
      filteredCreatorsList = creatorsList
          .where((creator) =>
              creator['name'].toLowerCase().contains(nameQuery.toLowerCase()) &&
              (serviceQuery == 'All' || creator['service'] == serviceQuery))
          .toList();
      _sortList();
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coomer.Party'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePageBody(
            creatorsList: creatorsList,
            filteredCreatorsList: filteredCreatorsList,
            services: services,
            selectedService: selectedService,
            selectedSort: selectedSort,
            searchController: searchController,
            searchByNameAndService: searchByNameAndService,
            sortList: _sortList,
          ),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
