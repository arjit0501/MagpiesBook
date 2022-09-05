

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/person_search/card_profile.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';

class Followers extends StatefulWidget {
  final String uid ;
  final String what ;
    const Followers({Key? key, required this.uid, required this.what}) : super(key: key);

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient:  LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [Colors.purple, Colors.blue]
            ) ,
          ),
        ),
        title: Text(widget.what == 'followerList'? 'Followers': 'Following'),
        elevation: 0,
      ),
      body: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('users')
              .doc(widget.uid)
              .collection(widget.what)
              .get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot2) {
            if (snapshot2.hasError) {
              print('Something went Wrong');
            }
            if (snapshot2.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(

                itemCount: snapshot2.data!.docs.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(
                          snapshot2.data!.docs[index]['uid']).get(),
                      builder:
                          (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          print('Something went Wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container();
                        }
                        return ProfileCard(name: snapshot.data!['name'],
                            profession: snapshot.data!['profession'],
                            level: snapshot.data!['level'],
                            imageUrl: snapshot.data!['imageUrl'],
                            uid: snapshot.data!['uid'],
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      UserProfile(
                                          uuid: snapshot.data!['uid']
                                      ),
                                ),
                              );
                            });
                      }
                  );
                }
            );
          }
      ),
    );
  }
}
