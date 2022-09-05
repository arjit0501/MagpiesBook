

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/person_search/card_profile.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';

class Likes extends StatefulWidget {
  final postUid ;
  const Likes({Key? key, required this.postUid}) : super(key: key);

  @override
  State<Likes> createState() => _LikesState();
}

class _LikesState extends State<Likes> {


  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
    gradient:  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,

    colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)]
    ) ,
    ),
      child: Scaffold(
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
          title: Text('Likes'),
          elevation: 0,
        ),
        body: FutureBuilder<QuerySnapshot>(
            future:  FirebaseFirestore.instance.collection('posts').doc(widget.postUid).collection('likers').get(),
        builder:
        (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
        print('Something went Wrong');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
        child: CircularProgressIndicator(),
        );
        }
        return ListView.builder(

        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.docs[index]['uid']).get(),
        builder:
        (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot2) {
        if (snapshot2.hasError) {
        print('Something went Wrong');
        }
        if (snapshot2.connectionState == ConnectionState.waiting) {
        return Container();
        }
        return ProfileCard(name: snapshot2.data!['name'], profession: snapshot2.data!['profession'], level: snapshot2.data!['level'], imageUrl: snapshot2.data!['imageUrl'], uid: snapshot2.data!['uid'], onTap: (){
        Navigator.of(context).push(
        MaterialPageRoute(
        builder: (_) => UserProfile(
        uuid: snapshot2.data!['uid']
        ),
        ),
        );
        });
        }
        );
        }
        );
        }),
      ),
    );
    }
}
