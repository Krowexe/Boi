import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creators List',
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
      });
    } else {
      throw Exception('Failed to load creators');
    }
  }

  void searchByName(String query) {
    setState(() {
      filteredCreatorsList = creatorsList
          .where((creator) => creator['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Creators List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => searchByName(value),
              decoration: InputDecoration(
                labelText: 'Search by Name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: creatorsList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredCreatorsList.length,
                    itemBuilder: (context, index) {
                      final creator = filteredCreatorsList[index];
                      return ListTile(
                        title: Text(creator['name']),
                        subtitle: Text('Service: ${creator['service']}'),
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
