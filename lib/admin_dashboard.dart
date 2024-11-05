import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'admin_view_profile.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> options = [
    "Reported Comments",
    "Reported Posts",
    "Reported Users",
    "Suspended Users"
  ];
  String selectedOption = "Reported Comments";
  List<String> items = [];
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedOption,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedOption = newValue!;
                  fetchItems();
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  if (selectedOption == "Reported Users" ||
                      selectedOption == "Suspended Users") {
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminViewProfile(followerId: item),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListTile(
                      title: Text(item),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void fetchItems() {
    String tableName;

    switch (selectedOption) {
      case "Reported Posts":
        tableName = "reportedPosts";
        break;
      case "Reported Comments":
        tableName = "reportedComments";
        break;
      case "Reported Users":
        tableName = "reportedUsers";
        break;
      case "Suspended Users":
        tableName = "suspendedUsers";
        break;
      default:
        return;
    }

    database.child(tableName).once().then((DatabaseEvent event) {
      final snapshot = event.snapshot;
      List<String> fetchedItems = [];
      if (snapshot.value != null) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          fetchedItems.add(key);
        });
      }
      setState(() {
        items = fetchedItems;
      });
    });
  }
}


