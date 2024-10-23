import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ModHomePage extends StatefulWidget {
  const ModHomePage({super.key});

  @override
  State<ModHomePage> createState() => _ModHomePageState();
}

class _ModHomePageState extends State<ModHomePage> {
  @override
  Widget build(BuildContext context) {
    return Text("Moderator Home Page");
  }
}
