import 'dart:convert';
import 'package:coomer_android/CreatorDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coomer.Party',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    fetchCreatorsList();
  }

  Future<void> fetchCreatorsList() async {
    final Uri url = Uri.parse('https://coomer.su/api/v1/creators.txt');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        creatorsList = List<Map<String, dynamic>>.from(json.decode(response.body));
        filteredCreatorsList = creatorsList;
        services = creatorsList.map<String>((creator) => creator['service']).toSet().toList();
        services.insert(0, 'All');
        _sortList();
      });
    } else {
      throw Exception('Failed to load creators');
    }
  }

  void _sortList() {
    if (selectedSort == 'Alphabetical') {
      filteredCreatorsList.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (selectedSort == 'Popularity') {
      filteredCreatorsList.sort((a, b) => b['favorited'].compareTo(a['favorited']));
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
                    onChanged: (value) => searchByNameAndService(value, selectedService),
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
                      searchByNameAndService(searchController.text, selectedService);
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
                              builder: (context) => CreatorDetailsScreen(creator: creator),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage('https://img.coomer.su/icons/${creator['service']}/${creator['id']}'),
                        ),
                        title: Text(creator['name']),
                        subtitle: Text('${creator['service']} \n${creator['favorited']} ★'),
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
