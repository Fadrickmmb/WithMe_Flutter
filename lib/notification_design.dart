import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationModelWidget extends StatelessWidget {
  final String senderName;
  final String message;
  final String notDate;
  final Function goToComment;

  NotificationModelWidget({required this.senderName, required this.message, required this.notDate, required this.goToComment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        senderName + ' ' + message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        notDate,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: (){
              goToComment();
            },
            child: Icon(Icons.warning_amber),
          ),
        ],
      ),
    );
  }
}
