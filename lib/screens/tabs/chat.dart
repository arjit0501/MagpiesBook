import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/chat/chat_card.dart';
import 'package:jojo/screens/tabs/chat/chat_room.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver  {
  final FirebaseAuth auth = FirebaseAuth.instance ;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setStatus(String status) async {
    await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).update({
      "status": status,
    });
  }


  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid).collection('chats').orderBy('time',descending: true).snapshots() ,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

      final List storedocs = [];
      snapshot.data!.docs.map((DocumentSnapshot document) {
        Map a = document.data() as Map<String, dynamic>;
        a['id'] = document.id;
        storedocs.add(a);

      }).toList();
      return      Container(
       decoration: BoxDecoration(
      gradient:  LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,

      colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)]
          ) ,
          ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text('Inbox' ,),
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
              actions: [
                IconButton(
                  onPressed: () {
                    setState((){

                    });
                  },
                  icon: Icon(Icons.group_add_outlined),

                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < storedocs.length; i++) ...[
                    StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(storedocs[i]['uid']).snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Text("Something went wrong");

                              }

                              if (snapshot.hasData && !snapshot.data!.exists) {
                                return Text("Document does not exist");
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();

                              }

                              Map<String, dynamic> data = snapshot.data!
                                  .data() as Map<String, dynamic>;
                              var name = data['name'];
                              var imageUrl = data['imageUrl'];
                              var status = data['status'];
                              var uid = data['uid'];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 5),
                                    child: ChatCard(name: name,
                                        status: status,
                                        imageUrl: imageUrl,
                                        uid: uid,
                                        onTap: () {
                                          String roomId = storedocs[i]['roomId'];

                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ChatRoom(
                                                    chatRoomId: roomId,
                                                    user2: uid,
                                                  ),
                                            ),
                                          );
                                        }),
                                  ),
                                  const Divider(
                                    thickness: 2,
                                    indent: 10,
                                    endIndent: 10,
                                  )
                                ],
                              );
                            } )]
                ],

            ) ,
            ) ),
      );
        });
  }
}











