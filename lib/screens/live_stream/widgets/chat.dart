import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:jojo/provider/provider.dart';
import 'package:jojo/resources/firestore_methods.dart';
import 'package:jojo/screens/live_stream/screens/broadcast_screen.dart';
import 'package:jojo/screens/live_stream/screens/hopOn.dart';
import 'package:jojo/screens/live_stream/utils/utils.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';
import 'package:provider/provider.dart';


class Chat extends StatefulWidget {
  final String channelId;
  const Chat({
    Key? key,
    required this.channelId,
  }) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _chatController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance ;
  final FirebaseAuth _auth = FirebaseAuth.instance ;

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width > 600 ? size.width * 0.25 : double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: StreamBuilder<dynamic>(
              stream: FirebaseFirestore.instance
                  .collection('livestream')
                  .doc(widget.channelId)
                  .collection('comments')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData == true) {
                  return Container(

                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.blue.withOpacity(0.2)
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, index) =>
                          Container(
                            padding : EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                              decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent
                          ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => UserProfile(
                                                uuid: snapshot.data.docs[index]['uid']
                                            ),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(radius: 22,
                                        backgroundColor: Colors.purple,
                                        child: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot.data.docs[index]['imageUrl']),
                                      ),),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data.docs[index]['username'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: snapshot.data.docs[index]['uid'] ==
                                                  userProvider.user.uid
                                                  ? Colors.purple
                                                  : Colors.blue,
                                            ),
                                          ),
                                          Container(
                                            width: size.width > 600 ?size.width*0.1: size.width*0.5,
                                            child: Text(
                                              snapshot.data.docs[index]['message'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),


                              ],
                            ),

                          ),
                    ),
                  );
                }
                else{
                  return Container();
                }
              },
            ),
          ),
          Container(
            height: size.height / 12,
            width: size.width / 1.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(

                  child: TextField(
                    controller: _chatController,
                    minLines: 1,
                    maxLines: 30,


                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple, width: 2)),

                        hintText: "Comment",

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),

                        )),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.send, color: Colors.blueGrey,), onPressed:() {
                      if (_chatController.text.trim().isNotEmpty) {
                        FirestoreMethods().chat(
                          _chatController.text.trim(),
                          widget.channelId,
                          context,
                        );
                        _chatController.clear();
                      }
                      else{
                        showSnackBar(context, 'Enter somethings');
                      }
                }, ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}