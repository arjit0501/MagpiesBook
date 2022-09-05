
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/live_stream/utils/utils.dart';
import 'package:jojo/screens/tabs/post_page/comment_card.dart';

class Comments extends StatefulWidget {

  static String routeName = '/comment' ;

  final String postUid ;
  final String uid ;
  final String uuid ;

  const Comments({Key? key, required this.postUid, required this.uid, required this.uuid }) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
   TextEditingController _controller = TextEditingController() ;
   FirebaseAuth _auth = FirebaseAuth.instance ;
   FirebaseFirestore _firestore = FirebaseFirestore.instance ;



  @override
  Widget build(BuildContext context) {
  Size  size = MediaQuery.of(context).size ;
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),

          flexibleSpace: Container(
          decoration: BoxDecoration(
          gradient:  LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Colors.purple, Colors.blue]
      ) ,
    ),
    ),
        elevation: 0,

      )
          ,
      body : SingleChildScrollView(

        child: Column(
          children: [
            Container(
            height: size.height / 1.25,
            width: size.width,
            child: StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance.collection('posts').doc(widget.postUid).collection('comments').orderBy('time',descending: true).snapshots() ,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.data != null) {
      return ListView.builder(
          itemCount: snapshot.data!.docs.length, itemBuilder: (context, index) {
        return CommentCard(uid: snapshot.data!.docs[index]['uid'],
            comment: snapshot.data!.docs[index]['comment'],
            time: snapshot.data!.docs[index]['timeAgo'].toDate());
      });
    }else{
      return Center(
        child: Text('No Comments'),
      );
    }}),
          ),
            Container(
              height: size.height / 12,
              width: size.width / 1.1,

              alignment: Alignment.bottomCenter,
              child:  Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FutureBuilder <DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('users').doc(_auth.currentUser!.uid)
        .get(),
    builder: (_ , snapshot){
    if (snapshot.hasError){
    print('something wet wrong') ;
    }
    if (snapshot.connectionState == ConnectionState.waiting){
    return CircleAvatar(radius: 17,); }

   var image = snapshot.data!['imageUrl'];
    return CircleAvatar(
                      radius: 17,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(image),
                      ),
                    );})
                  ),
                  Flexible(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(

                        hintText: 'add comment',
                        suffix: GestureDetector(
                          onTap: ()async {

                            if (_controller.text
                                .trim()
                                .isNotEmpty) {
                              await _firestore.collection('posts').doc(widget.postUid).collection('comments').add({
                                'uid': _auth.currentUser!.uid,
                                'comment': _controller.text.trim(),
                                'time': FieldValue.serverTimestamp(),
                                'timeAgo': DateTime.now(),
                              });

                              await _firestore.collection('users').doc(widget.uuid).collection('post').doc(widget.uid).collection('comments').add({
                                'uid': _auth.currentUser!.uid,
                                'comment': _controller.text.trim(),
                                'time': FieldValue.serverTimestamp(),
                                'timeAgo': DateTime.now(),
                              });

                              WriteBatch batch = FirebaseFirestore.instance.batch();
                              DocumentReference tt2 = FirebaseFirestore.instance.collection('posts')
                                  .doc(widget.postUid);
                              DocumentReference tt3 = FirebaseFirestore.instance.collection('users').doc(widget.uuid).collection('post').doc(widget.uid);

                              batch.update(tt2,{ 'comments': FieldValue.increment(1)});
                              batch.update(tt3,{ 'comments': FieldValue.increment(1)});
                              batch.commit();
                              _controller.clear() ;

                            }else{
                              showSnackBar(context, 'Enter comment') ;
                            }
                          },
                          child: Text('Add', style:  TextStyle(color: Colors.purple),),
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

    )
    );
  }
}
