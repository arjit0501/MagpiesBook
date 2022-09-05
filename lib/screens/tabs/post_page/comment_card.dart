

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentCard extends StatefulWidget {
  final String uid ;
  final String comment ;
  final DateTime time ;
  const CommentCard({Key? key, required this.uid , required this.comment , required this.time}) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<DocumentSnapshot<Object>>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.uid).snapshots(),
    builder: (BuildContext context, AsyncSnapshot <DocumentSnapshot<Object>> snapshot) {
      if (snapshot.hasError) {
        print('Something went Wrong');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return
          Container();
      }
      return Container(

        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
       // color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap:  (){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UserProfile(
                        uuid: widget.uid
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: NetworkImage(snapshot.data!['imageUrl']),
                    ),
                  ),
                   Text(snapshot.data!['name'], style: TextStyle(fontWeight: FontWeight.bold),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 45.0),
              child: Text(widget.comment),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text( '${timeago.format(widget.time)}', style: TextStyle(fontSize: 10, color: Colors.grey),),
            )
          ],
        ),
      );
    }
);
    }
}
