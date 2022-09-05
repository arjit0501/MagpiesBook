


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/post_page/post_card.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileSaved extends StatefulWidget {
  const ProfileSaved({Key? key}) : super(key: key);

  @override
  State<ProfileSaved> createState() => _ProfileSavedState();
}

class _ProfileSavedState extends State<ProfileSaved> {
  final FirebaseAuth auth =FirebaseAuth.instance;
  final FirebaseFirestore users = FirebaseFirestore.instance ;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        future: users.collection('users').doc(auth.currentUser!.uid).collection('saved').get(),
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
              return ListView.builder(

                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                        future: users.collection('posts').doc(
                            snapshot.data!.docs[index]['postUid']).get(),
                        builder:
                            (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot2) {
                          if (snapshot2.hasError) {
                            print('Something went Wrong');
                          }
                          if (snapshot2.connectionState ==
                              ConnectionState.waiting) {
                            print('chalaa 1');
                            return Container();
                          }
                          print(snapshot2.data!['likes']);
                          return PostCard(time: snapshot2.data!['timeAgo'].toDate(),likes: snapshot2.data!['likes'],
                              comments: snapshot2.data!['comments'],
                              uid: snapshot.data!.docs[index]['uid'],
                              idea: snapshot.data!.docs[index]['idea'],
                              postUid: snapshot.data!.docs[index]['postUid'],
                              userPostId: snapshot.data!
                                  .docs[index]['userPostId']);
                        }
                    );
                  });
            }
    );
  }
}
