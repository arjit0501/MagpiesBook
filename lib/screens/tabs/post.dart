import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/post_page/post_card.dart';
import 'package:jojo/screens/tabs/post_page/post_page.dart';
import 'package:shimmer/shimmer.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Container ( child : Scaffold(
      appBar: AppBar(
        title: Text(
          'Ideas'
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient:  LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [Colors.purple, Colors.blue]
            ) ,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(onPressed: (){
              Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>   PostPage(
                    ),
                  ));
            }, icon: Icon(Icons.add_box_outlined)),
          )
        ],

      ),
      backgroundColor: Colors.transparent,
      body:   FutureBuilder < QuerySnapshot<Map<String , dynamic>>>(
    future: FirebaseFirestore.instance
        .collection('posts').orderBy('time', descending: true)
        .get(),
    builder: (_ , snapshot){
    if (snapshot.hasError){
    print('something wet wrong') ;
    }
    if (snapshot.connectionState == ConnectionState.waiting){
    return Shimmer.fromColors(
      // enabled: true,
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: 15,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: placeHolderRow(),
        ),
        separatorBuilder: (_,__) => const SizedBox(height: 2),
      ),

    );
    }


    return ListView.builder(


        itemCount: snapshot.data!.docs.length,
        itemBuilder: (context, index)  {


          return PostCard(time: snapshot.data!.docs[index]['timeAgo'].toDate()  ,likes:snapshot.data!.docs[index]['likes'] , comments : snapshot.data!.docs[index]['comments'],uid:snapshot.data!.docs[index]['uid'], idea: snapshot.data!.docs[index]['post'] , postUid: snapshot.data!.docs[index].id ,userPostId :snapshot.data!.docs[index]['postId']);});
    }
    )

     )
    , decoration: BoxDecoration(
        gradient:  LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)]
        ) ,
      ),);
  }
}


Widget placeHolderRow() => Card(
  color: Colors.transparent,
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.white,
              height: 20,
              width: 40,
            )
          ],
        ),
      ),
      Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        color: Colors.white,
        height: 60,
        width: double.infinity,
      ),
      Container(
        margin:EdgeInsets.symmetric(horizontal: 10,vertical: 10) ,
        height: 20,
        width: double.infinity,
        color: Colors.white,
      )
    ],
  ),
);
