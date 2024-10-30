import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:withme_flutter/admin_home_page.dart';
import 'package:withme_flutter/mod_search_page.dart';

import 'admin_profile_page.dart';
import 'admin_search_page.dart';

class ModHomePage extends StatefulWidget {
  const ModHomePage({super.key});

  @override
  State<ModHomePage> createState() => _ModHomePageState();
}

class _ModHomePageState extends State<ModHomePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }


  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'MOD HOME PAGE',
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminSearchPage()),
                    );
                  },
                  child: Text('To Search Page'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminProfilePage()),
                    );
                  },
                  child: Text('To Profile Page'),
                ),
              ],
            ),
          )
      ),
    );
  }
}
