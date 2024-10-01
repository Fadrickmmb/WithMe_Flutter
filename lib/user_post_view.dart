import 'package:flutter/material.dart';

class UserPostView extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UserPostView();
}

class _UserPostView extends State<UserPostView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                child: Column(
                  children: [
                    Row(
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
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/small_logo.png'),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Post Owner Name",
                              style: TextStyle(
                                fontFamily: 'DM Serif Display',
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.location_on),
                                Text("Location Name"),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.more_vert),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: Center(
                        child: Image.asset(
                          'assets/withme_newpost.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.asset('assets/withme_yummy.png', width: 25, height: 25),
                              const SizedBox(width: 10),
                              Text("Yummys", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Image.asset('assets/withme_comment.png', width: 25, height: 25),
                              const SizedBox(width: 10),
                              Text("Comments", style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("Date", style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: 5, // Simulating comments
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text("Comment $index"),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
