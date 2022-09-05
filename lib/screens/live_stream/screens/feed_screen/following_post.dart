


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/live_stream/screens/feed_screen/following_card.dart';
import 'package:shimmer/shimmer.dart';

class FollowingPost extends StatefulWidget {
  const FollowingPost({Key? key}) : super(key: key);

  @override
  State<FollowingPost> createState() => _FollowingPostState();
}

class _FollowingPostState extends State<FollowingPost> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder < QuerySnapshot<Map<String , dynamic>>>(
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


          return  ListView.builder(


              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index)  {


                return PostCardHome(time:snapshot.data!.docs[index]['timeAgo'].toDate(),likes:snapshot.data!.docs[index]['likes'] ,comments:snapshot.data!.docs[index]['comments'],uid: snapshot.data!.docs[index]['uid'], idea: snapshot.data!.docs[index]['post'] , postUid: snapshot.data!.docs[index].id ,userPostId :snapshot.data!.docs[index]['postId']);});
        }
    );
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
