import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final String user2;
  final String chatRoomId;

  ChatRoom({required this.chatRoomId, required this.user2});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;



    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.uid,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
    FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});
      print(imageUrl);
    }
  }

  void onSendMessage() async {
    if (_message.text.trim().isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.uid,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  upload() async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid)
        .collection('chats').doc(widget.user2).set({
      'uid': widget.user2,
      'roomId' : widget.chatRoomId,
      'time' : FieldValue.serverTimestamp()
    });
    await _firestore.collection('users').doc(widget.user2)
        .collection('chats').doc(_auth.currentUser!.uid).set({
      'uid': _auth.currentUser!.uid,
      'roomId' : widget.chatRoomId,
      'time' : FieldValue.serverTimestamp()
    });
  }

  @override
  void initState() {
    upload();

  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
        elevation: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream:
          _firestore.collection("users").doc(widget.user2).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Container(
                child: Row(
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 22,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!['imageUrl']),

                        ),
                      ),
                      onTap:() => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ShowImage(
                            imageUrl: snapshot.data!['imageUrl'],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: size.width*0.1,),
                    Column(
                      children: [
                        Text(snapshot.data!['name']),
                        Text(snapshot.data!['status'], style:  TextStyle(fontWeight: FontWeight.bold , color :snapshot.data!['status'] == 'Online' ? Colors.green : Colors.grey[600] ,fontSize: 16),)
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: SingleChildScrollView(

        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container(
                      height: size.height / 10,
                      width: size.width,
                      alignment: Alignment.center,
                    );
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(

                      child: TextField(
                        controller: _message,
                        minLines: 1,
                        maxLines: 30,


                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.lightGreenAccent, width: 2)),
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              highlightColor: Colors.lightGreenAccent,
                              splashColor: Colors.lightGreenAccent,
                              icon: Icon(Icons.photo),


                            ),
                            hintText: "Send Message",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),

                            )),
                      ),
                    ),
                    IconButton(
                        icon: Icon(Icons.send, color: Colors.blueGrey,), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
      width: size.width,
      margin:EdgeInsets.symmetric(vertical: 8, horizontal: 8) ,

      alignment: map['sendby'] == _auth.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Column(
        crossAxisAlignment:map['sendby'] == _auth.currentUser!.uid ? CrossAxisAlignment.end :CrossAxisAlignment.start ,
        children: [
          Container(

            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black54,
            ),
            child: Text(
             map['time']==null ?"ok" :(map['time'] as Timestamp).toDate().toString().substring(0, 10),
              style: TextStyle(
                fontSize: 6,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Container(
width: size.width*0.5,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: map['sendby'] == _auth.currentUser!.uid ? Colors.purpleAccent.shade200: Colors.orangeAccent.shade200,
            ),
            child: Text(
              map['message'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    )
        : Container(


      margin:EdgeInsets.symmetric(vertical: 8, horizontal: 8) ,
      alignment: map['sendby'] == _auth.currentUser!.uid
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Column(
          crossAxisAlignment:map['sendby'] == _auth.currentUser!.uid ? CrossAxisAlignment.end :CrossAxisAlignment.start,
          children: [
          Container(

            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black54,
            ),
            child: Text(
              'ok',
              // DateTime.fromMillisecondsSinceEpoch(
              //     map['time'].seconds * 1000)
              //     .toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ShowImage(
                  imageUrl: map['message'],
                ),
              ),
            ),
            child: Container(
              height: size.height / 2.5,
              width: size.width / 2,
              decoration: BoxDecoration(border: Border.all(),
              ),
              alignment: map['message'] != "" ? null : Alignment.center,
              child: map['message'] != ""
                  ? Image.network(
                map['message'],
                fit: BoxFit.cover,
              )
                  : CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

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
      ),
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

//
