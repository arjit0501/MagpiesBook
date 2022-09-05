

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  bool isLoading = false;

  TextEditingController controller = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;





  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Post Idea'),
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [Colors.purple, Colors.blue]
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.0),
                      child: TextFormField(
                        controller: controller,
                        minLines: 1,
                        maxLines: 10,

                        autofocus: false,

                        decoration: InputDecoration(
                          labelText: 'Idea: ',
                          labelStyle: TextStyle(fontSize: 20.0),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.purple.withOpacity(0.8),
                                  width: 2)),
                          errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  isLoading ? Center(child: CircularProgressIndicator(
                    color: Colors.purple,
                  )) : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });


                        if (controller.text.isNotEmpty) {
                          DocumentReference doc_ref = await  _firestore.collection('users')
                                .doc(_auth.currentUser!.uid)
                                .collection('post')
                                .add(
                                {
                                  'post': controller.text,
                                  'time': FieldValue.serverTimestamp(),
                                  'timeAgo': DateTime.now(),
                                  'name' : _auth.currentUser!.displayName,
                                  'likes' : 0,
                                  'comments' :0,
                                  'bookMarks' :0,


                                }
                            );
                          DocumentSnapshot docSnap = await doc_ref.get();
                          var doc_id2 = docSnap.reference.id;

                          DocumentReference doc_ref2= await _firestore.collection('posts').add(
                                {
                                  'post': controller.text,
                                  'time': FieldValue.serverTimestamp(),
                                  'timeAgo': DateTime.now(),
                                  'uid': _auth.currentUser!.uid,
                                  'postId' : doc_id2 ,
                                  'likes' : 0,
                                  'comments' :0,
                                  'bookMarks' :0,
                                  'userPostId': "",
                                  'postUid' : ""
                                }
                            );
                          DocumentSnapshot docSnap2 = await doc_ref2.get();
                          var doc_id22 = docSnap2.reference.id;
                          await _firestore.collection('users')
                              .doc(_auth.currentUser!.uid)
                              .collection('post').doc(doc_id2).update({
                            'userPostId': doc_id2,
                            'postUid' : doc_id22
                          });
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.pop(context);
                      }
                        else {
                          print('nhi hai yha kuch');
                          setState(() {
                            isLoading = false;
                          });
                        }

                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple.withOpacity(0.8),
                        minimumSize: Size(size.width * 0.4, 40),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Text(
                            'Post',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          Icon(
                            Icons.post_add,
                            color: Colors.grey[300],
                          )
                        ],
                      ),
                    ),
                  )
                ]
            )
        ));
  }

}