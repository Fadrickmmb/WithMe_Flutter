import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String name;
  final String text;
  final String date;

  CommentWidget({required this.name, required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: [
              Text(name,style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              ),
              Text(date,style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(text,style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
