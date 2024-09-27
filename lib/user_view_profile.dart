import 'package:flutter/material.dart';
import 'package:withme_flutter/user_add_post_page.dart';
import 'package:withme_flutter/user_edit_profile.dart';
import 'package:withme_flutter/user_home_page.dart';
import 'package:withme_flutter/user_profile_page.dart';
import 'package:withme_flutter/user_search_page.dart';
import 'post_model.dart';
import 'user_post.dart';

class UserViewProfile extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UserViewProfile();
}

class _UserViewProfile extends State<UserViewProfile>{
  late String name = '';
  late String followers = '0';
  late String posts = '0';
  late String yummys = '0';
  int _selectedIndex = 0;
  final List postList = ['post1','post2','post3'];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserHomePage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSearchPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserAddPostPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child:
        Container(
          padding: EdgeInsets.all(20),
          width: double.infinity,
          alignment: Alignment.center,

          //Header
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //header
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0,30,0,0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        children: [
                          Image.asset('assets/withme_logo.png', height:60),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox.shrink()),
                    Container(
                      padding: EdgeInsets.fromLTRB(0,0,10,0),
                      alignment: Alignment.centerRight,
                      child: Image.asset('assets/withme_yummy.png', height:30),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Image.asset('assets/withme_comment.png', height:30),
                    ),
                  ],
                ),
              ),
              //insert content here
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                child: CircleAvatar(
                  backgroundColor: Color(0xFF1A2F31),
                  radius: 70,
                  backgroundImage: AssetImage('assets/small_logo.png'),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                padding: EdgeInsets.all(20),
                child: Text('NAME' + name.toUpperCase(),style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'DM Serif Display',
                ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Text('Write your bio here.',style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'DM Serif Display',
                ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(followers,style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Followers',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(posts,style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Posts',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(yummys,style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'DM Serif Display',
                          ),
                          ),
                          Text('Yummys',style: TextStyle(
                            fontSize: 16,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(onPressed: (){},
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Color(0xFF1A2F31)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.all(10),),
                  fixedSize: MaterialStateProperty.all<Size>(Size(200.0, 60.0),),
                ),
                child: Text('Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              ListView.builder(
                primary: false,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:postList.length,
                itemBuilder: (context,index){
                  return UserPost(name: postList[index],);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Image.asset('assets/withme_home.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_search.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_newpost.png',height: 30,),label: ''),
          BottomNavigationBarItem(icon: Image.asset('assets/withme_home.png',height: 30,),label: ''),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

