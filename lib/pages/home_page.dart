import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coomer_android/CreatorDetailsScreen.dart';

class HomePageBody extends StatelessWidget {
  final List<Map<String, dynamic>> creatorsList;
  final List<Map<String, dynamic>> filteredCreatorsList;
  final List<String> services;
  final String selectedService;
  final String selectedSort;
  final TextEditingController searchController;
  final Function(String, String) searchByNameAndService;
  final Function() sortList;

  HomePageBody({
    required this.creatorsList,
    required this.filteredCreatorsList,
    required this.services,
    required this.selectedService,
    required this.selectedSort,
    required this.searchController,
    required this.searchByNameAndService,
    required this.sortList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  searchByNameAndService(searchController.text, value!);
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
                sortList();
              },
              child: Text('Sort Alphabetically'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                sortList();
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
                        backgroundImage: CachedNetworkImageProvider(
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
    );
  }
}
