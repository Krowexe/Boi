import 'dart:convert';
import 'package:coomer_android/CreatorDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';

void main() => runApp(MyApp());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coomer.Party'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) =>
                        searchByNameAndService(value, selectedService),
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedService,
                  onChanged: (value) {
                    setState(() {
                      selectedService = value!;
                      searchByNameAndService(
                          searchController.text, selectedService);
                    });
                  },
                  items: services.map((service) {
                    return DropdownMenuItem<String>(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSort = 'Alphabetical';
                    _sortList();
                  });
                },
                child: Text('Sort Alphabetically'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedSort = 'Popularity';
                    _sortList();
                  });
                },
                child: Text('Sort by Popularity'),
              ),
            ],
          ),
          Expanded(
            child: creatorsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredCreatorsList.length,
                    itemBuilder: (context, index) {
                      final creator = filteredCreatorsList[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreatorDetailsScreen(creator: creator),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://img.coomer.su/icons/${creator['service']}/${creator['id']}'),
                        ),
                        title: Text(creator['name']),
                        subtitle: Text(
                            '${creator['service']} \n${creator['favorited']} ★'),
                        // Add more details if needed
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
