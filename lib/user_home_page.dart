import 'package:flutter/material.dart';
import 'package:withme_flutter/user_profile_page.dart';

class UserHomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UserHomePage();
}

class _UserHomePage extends State<UserHomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserProfilePage(),),);
            }, child: Text('Profile'),),
          ],
        ),
      ),
    );
  }
}
