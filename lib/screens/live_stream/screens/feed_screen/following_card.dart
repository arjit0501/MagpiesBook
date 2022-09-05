



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/post_page/comment.dart';
import 'package:jojo/screens/tabs/post_page/likes.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCardHome extends StatefulWidget {
  final String uid;
  final String idea;
  final String postUid ;
  final String userPostId ;
  final int likes ;
  final int comments ;
  final DateTime time;

  const PostCardHome({Key? key, required this.uid, required this.idea , required this.postUid , required this.userPostId,
  required this.likes, required this.comments, required this.time})
      : super(key: key);

  @override
  State<PostCardHome> createState() => _PostCardHomeState();
}

class _PostCardHomeState extends State<PostCardHome> {

  FirebaseAuth auth = FirebaseAuth.instance ;
  bool isLiked = false ;
  bool isSaved= false ;
  bool  isFollowing = false ;
  late int likess ;


  onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore
        .collection('posts').doc(widget.postUid).
    collection('likers').
    where('uid', isEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      int k = value.docs.length;
      print('achhhhh'.toString().codeUnits);
      print(k);

      if (k>0){
        bool g= true ;
        print('fjhg');
        setState((){
          print('kya hua');
          isLiked = true ;

          print(g);
        });


      }
    });
  }

  onSaved() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore
        .collection('posts').doc(widget.postUid).
    collection('savers').
    where('uid', isEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      int k = value.docs.length;
      print('Saveeeeee'.toString().codeUnits);
      print(k);

      if (k>0){
        bool g= true ;
        print('Savedddddd');
        setState((){
          print('kya hua2222222222');
          isSaved = true ;

          print(g);
        });


      }
    });
  }

  follower() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    FirebaseAuth _auth = FirebaseAuth.instance ;
    await _firestore
        .collection('users').doc(_auth.currentUser!.uid).
    collection('followingList').
    where('uid', isEqualTo: widget.uid)
        .get()
        .then((value) {
      int k = value.docs.length;
      print('achhhhh'.toString().codeUnits);
      print(k);

      if (k>0){
        bool g= true ;
        print('fjhg');
        setState((){
          print('kya hua');
          isFollowing = true ;

          print(g);
        });


      }
    });
  }


  void initState() {
    likess= widget.likes;
    print('nhi hhhhhhhh');
    follower();
    onSearch();
    onSaved();

  }



  @override
  Widget build(BuildContext context) {
    return isFollowing ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid)
            .get(),
        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print('something wet wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              // enabled: true,
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: 1,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: placeHolderRow(),
                ),
                separatorBuilder: (_,__) => const SizedBox(height: 2),
              ),

            );
          }
          var data = snapshot.data!.data();
          var name = data!['name'];
          var imageUrl = data['imageUrl'];

          return Card(
            color: Colors.white.withOpacity(0.4),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => UserProfile(
                                uuid: widget.uid
                            ),
                          ),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                        ), Column(
                          children: [
                            Text(name, style:  TextStyle(fontWeight: FontWeight.bold , fontSize: 16),),
                            Text('${timeago.format(widget.time)}', style: TextStyle(fontSize: 10, color: Colors.grey[700]),)
                          ],
                        )],
                      ),
                    ),
                    IconButton(onPressed: () {
                    // The function showDialog<T> returns Future<T>.
                    // Use Navigator.pop() to return value (of type T).
                    showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                   content: Container(
                     height: 115,
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.start,
                       children: [
                         ListTile(
                           leading: Icon(Icons.not_interested_outlined),
                           title: Text('Not interested'),
                           onTap: (){},
                         ),
                         ListTile(
                           leading: Icon(Icons.report_gmailerrorred_outlined, color: Colors.redAccent,),
                           title: Text('Report about it'),
                           onTap: (){},
                         ),
                       ],
                     ),
                   ),
                    alignment: Alignment.centerRight,
                    ),
                    );
                    },icon: Icon(Icons.more_vert))
                  ],
                ),
                Container(

                  padding: const EdgeInsets.only(left: 48.0, top: 8, bottom: 8 , right: 16),
                  child: Text(widget.idea),
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    isLiked ?  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(onPressed: (){
                          print(widget.uid);
                          print('possssssstttttt profileeeeeeee');
                          WriteBatch batch = FirebaseFirestore.instance.batch();
                          DocumentReference tt = FirebaseFirestore.instance.collection('posts')
                              .doc(widget.postUid).collection('likers').doc(auth.currentUser!.uid) ;
                          DocumentReference tt4 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId).collection('likers').doc(auth.currentUser!.uid) ;
                          DocumentReference tt2 = FirebaseFirestore.instance.collection('posts')
                              .doc(widget.postUid);
                          DocumentReference tt3 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId);
                          batch.delete(tt);
                          batch.delete(tt4);
                          batch.update(tt2,{ 'likes':FieldValue.increment(-1)});
                          batch.update(tt3,{ 'likes':FieldValue.increment(-1)});

                          batch.commit();
                          setState((){
                            likess =likess-1;
                            bool j = false ;
                            isLiked = j;
                          });

                        },
                          icon:  Icon(Icons.favorite , color: Colors.redAccent,),
                         alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(2),
                        ),
                        GestureDetector(
                          onTap:  (){
          Navigator.of(context).push(
          MaterialPageRoute(
          builder: (_) => Likes(
          postUid: widget.postUid,
          ),
          ),
          );
          },
                          child: Row(
                            children: [
                              Text(likess.toString(), style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16),),
                              SizedBox(width: 4,),
                              Text('likes', style: TextStyle( fontSize: 10),),

                            ],
                          ),
                        )
                      ],
                    ) :
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          print(widget.userPostId);
                          print(widget.postUid);

                          print(widget.uid);
                          print('possssssstttttt profileeeeeeee2');
                          WriteBatch batch = FirebaseFirestore.instance.batch();
                          DocumentReference tt = FirebaseFirestore.instance.collection('posts')
                              .doc(widget.postUid).collection('likers').doc(auth.currentUser!.uid) ;
                          DocumentReference tt4 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId).collection('likers').doc(auth.currentUser!.uid) ;
                          DocumentReference tt2 = FirebaseFirestore.instance.collection('posts')
                              .doc(widget.postUid);
                          DocumentReference tt3 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId);
                          batch.set(tt, { 'uid': auth.currentUser!.uid});
                          batch.set(tt4, { 'uid':  auth.currentUser!.uid});
                          batch.update(tt2,{ 'likes':FieldValue.increment(1)});
                          batch.update(tt3,{ 'likes':FieldValue.increment(1)});

                          batch.commit();
                          setState((){
                            likess= likess+1;
                            bool j = true ;
                            isLiked = j;
                          });

                        },
                          icon:  Icon(Icons.favorite_border ,),
                         alignment: Alignment.centerRight,
                          padding: const EdgeInsets.all(2),
                        ),
                        GestureDetector(
                          onTap:  (){
          Navigator.of(context).push(
          MaterialPageRoute(
          builder: (_) => Likes(
          postUid: widget.postUid,
          ),
          ),
          );
          },
                          child: Row(
                            children: [
                              Text(likess.toString(), style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16),),
                              SizedBox(width: 4,),
                              Text('likes', style: TextStyle( fontSize: 10),),

                            ],
                          ),
                        )
                      ],
                    ),

                    GestureDetector(
                      onTap:  (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Comments(
                              uuid: widget.uid,
                              uid: widget.userPostId,
                              postUid: widget.postUid,
                            ),
                          ),
                        );
                      },
                      child: Row(

                        children: [

                          Icon(Icons.comment, ),
                          SizedBox(width: 4,),
                          Row(

                            children: [
                              Text(widget.comments.toString(), style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16),),
                              SizedBox(width: 4,),
                              Text('comments', style: TextStyle( fontSize: 10),),

                            ],
                          )
                        ],
                      ),
                    ),
                    isSaved ? IconButton(onPressed: (){
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      DocumentReference tt = FirebaseFirestore.instance.collection('posts')
                          .doc(widget.postUid).collection('savers').doc(auth.currentUser!.uid) ;
                      DocumentReference tt4 = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).collection('saved').doc(widget.postUid);
                      DocumentReference tt2 = FirebaseFirestore.instance.collection('posts')
                          .doc(widget.postUid);
                      DocumentReference tt3 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId);
                      batch.delete(tt);
                      batch.delete(tt4);
                      batch.update(tt2,{ 'bookMarks': FieldValue.increment(-1)});
                      batch.update(tt3,{ 'bookMarks': FieldValue.increment(-1)});

                      batch.commit();
                      setState((){
                        bool j = false ;
                        isSaved = j;
                      });

                    }, icon:  Icon(Icons.bookmark_sharp, color: Colors.purple,),
                    ) : IconButton(onPressed: (){
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      DocumentReference tt = FirebaseFirestore.instance.collection('posts')
                          .doc(widget.postUid).collection('savers').doc(auth.currentUser!.uid) ;
                      DocumentReference tt4 = FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).collection('saved').doc(widget.postUid) ;
                      DocumentReference tt2 = FirebaseFirestore.instance.collection('posts')
                          .doc(widget.postUid);
                      DocumentReference tt3 = FirebaseFirestore.instance.collection('users').doc(widget.uid).collection('post').doc(widget.userPostId);

                      batch.set(tt, { 'uid': auth.currentUser!.uid,
                        'postUid': widget.postUid,
                        'userPostId': widget.userPostId,
                        'idea': widget.idea});
                      batch.set(tt4, { 'uid':  auth.currentUser!.uid, 'postUid': widget.postUid, 'userPostId': widget.userPostId,
                        'idea': widget.idea});
                      batch.update(tt2,{ 'bookMarks':FieldValue.increment(1)});
                      batch.update(tt3,{ 'bookMarks':FieldValue.increment(1)});

                      batch.commit();
                      setState((){
                        bool j = true ;
                        isSaved = j;
                      });

                    },
                      icon:  Icon(Icons.bookmark_outline_sharp, color: Colors.black,),
                    )
                  ],
                )
              ],
            ),
          );
        }): Container();
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
