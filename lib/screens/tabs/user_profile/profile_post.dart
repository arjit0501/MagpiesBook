

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/post_page/post_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfilePost extends StatefulWidget {
  final String uid ;
  const ProfilePost({Key? key, required this.uid}) : super(key: key);

  @override
  State<ProfilePost> createState() => _ProfilePostState();
}

class _ProfilePostState extends State<ProfilePost> {
  @override

  final FirebaseAuth auth =FirebaseAuth.instance;
  final FirebaseFirestore users = FirebaseFirestore.instance ;

  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: users.collection('users').doc(widget.uid).collection('post').orderBy('time' , descending: true).get(),
    builder:
    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        print('Something went Wrong');
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return  ListView.builder(

          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index){
           return PostCard(time:snapshot.data!.docs[index]['timeAgo'].toDate() ,likes :  snapshot.data!.docs[index]['likes'] , comments :  snapshot.data!.docs[index]['comments'], uid: widget.uid  , idea: snapshot.data!.docs[index]['post'], postUid: snapshot.data!.docs[index]['postUid'], userPostId: snapshot.data!.docs[index]['userPostId'] );
          }
      );
    });
    }
}
