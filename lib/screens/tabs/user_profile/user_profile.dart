import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/chat/chat_room.dart';
import 'package:jojo/screens/tabs/person_search/card_profile.dart';
import 'package:jojo/screens/tabs/user_profile/followers.dart';
import 'package:jojo/screens/tabs/user_profile/profile_post.dart';
import 'package:jojo/widgets/button.dart';
import 'package:jojo/widgets/gesture.dart';


class UserProfile extends StatefulWidget {
  static String routeName = '/userProfile';
  final String uuid ;
   UserProfile({required this.uuid}) ;

  @override
  State<UserProfile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<UserProfile> {
  final FirebaseAuth auth =FirebaseAuth.instance ;

  CollectionReference users = FirebaseFirestore.instance.collection('users');


bool isFollower = false ;


  String chatRoomId(String uid1, String uid2) {
    if (uid1.toLowerCase().codeUnits[0] +uid1.toLowerCase().codeUnits[1]+uid1.toLowerCase().codeUnits[6]
        >
        uid2.toLowerCase().codeUnits[0]+uid2.toLowerCase().codeUnits[1]+uid2.toLowerCase().codeUnits[6]) {
      return "$uid1$uid2";
    } else {
      return "$uid2$uid1";
    }
  }


 onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    await _firestore
        .collection('users').doc(widget.uuid).collection('followerList')
        .where('uid', isEqualTo: auth.currentUser!.uid)
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
            isFollower = g ;

            print(g);
          });


        }
    });
  }
  void initState() {
    print('nhi hhhhhhhh');
    onSearch();

  }

  @override
  Widget build(BuildContext context)  {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final size = MediaQuery.of(context).size;
    return  StreamBuilder<Object>(
      stream: null,
      builder: (context, snapshot) {
        return FutureBuilder<DocumentSnapshot>(
          future: users.doc(widget.uuid).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

            if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child:Text("Something went wrong"),
                ),
              );
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              var name = data['name'] ;
              var level = data['level'];
              var profession = data['profession'] ;
              var imageUrl = data['imageUrl'];
              var followers = data['followers'];
              var following = data['following'];
              var comments = data['comments'];
              var liveStream = data['liveStreams'];
              var uid = data['uid'];
              var bio= data['bio'];
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title:  Text(name),
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

                ),

                body: SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:ProfileCard(name:name, imageUrl: imageUrl, level: level, profession: profession,uid: uid,onTap: (){},)

                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children:  [
                            GestureDetector(child: GestureCustom(text: 'Followers', value: followers.toString()),onTap: (){
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => Followers(
                                    what: 'followerList',
                                    uid: uid,
                                  ),
                                ),
                              );
                            } ,),

                              GestureDetector(child: GestureCustom(text: 'Following', value: following.toString()),onTap: (){
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => Followers(
                                      what: 'followingList',
                                      uid: uid,
                                    ),
                                  ),
                                );
                              } ,),

                            GestureCustom(text: 'Comments', value: comments.toString()),
                            GestureCustom(text: 'Live Streams', value: liveStream.toString())
                          ],
                        ),
                        Container(width: size.width,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8,vertical: 2),
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children : [
                                      Text('Bio', style: TextStyle(fontWeight: FontWeight.bold),),
                                      Text(bio)
                                    ]
                                ),
                              )),
                        ) ,
                        const SizedBox(
                          height: 10,
                        ),

                        isFollower?  Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CustomButton2(text: 'Following', onPressed: ( ) {

                                WriteBatch batch = FirebaseFirestore.instance.batch();

                                DocumentReference tt = users.doc(uid).collection('followerList').doc(auth.currentUser!.uid) ;
                                DocumentReference tt4 = users.doc(auth.currentUser!.uid).collection('followingList').doc(uid) ;
                                DocumentReference tt2 = users.doc(uid);
                                DocumentReference tt3 = users.doc(auth.currentUser!.uid);
                                batch.delete(tt);
                                batch.delete(tt4);
                                batch.update(tt2,{ 'followers':FieldValue.increment(-1)});
                                batch.update(tt3,{ 'following':FieldValue.increment(-1)});

                                batch.commit();
                                setState((){
                                  bool j = false ;
                                  isFollower = j;
                                });

                              }
                              ),
                              SizedBox(width: size.width*0.04,),
                              CustomButton(text: 'Message', onPressed:() {

                                String roomId = chatRoomId(
                                    auth.currentUser!.uid,
                                    uid);

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoom(
                                      chatRoomId: roomId,
                                      user2: uid,
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),


                        ):Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(text: 'Follow', onPressed: ( ) {

                      WriteBatch batch = FirebaseFirestore.instance.batch();

                      DocumentReference tt = users.doc(uid).collection('followerList').doc(auth.currentUser!.uid) ;
                      DocumentReference tt4 = users.doc(auth.currentUser!.uid).collection('followingList').doc(uid) ;
                      DocumentReference tt2 = users.doc(uid);
                      DocumentReference tt3 = users.doc(auth.currentUser!.uid);
                      batch.set(tt, {'follower': 'follower', 'uid': auth.currentUser!.uid});
                      batch.set(tt4, {'following': 'following', 'uid': uid});
                      batch.update(tt2,{ 'followers':FieldValue.increment(1)});
                      batch.update(tt3,{ 'following':FieldValue.increment(1)});

                      batch.commit();
                      setState((){
                        bool j = true ;
                        isFollower = j;
                      });

                    }
                    ),
                    SizedBox(width: size.width*0.04,),
                    CustomButton(text: 'Message', onPressed:(){
                      String roomId = chatRoomId(
                          auth.currentUser!.uid,
                          uid);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: roomId,
                            user2: uid,
                          ),
                        ),
                      );
                    })
                  ],
                ),

              ),
                        const Divider(
                          thickness: 2,
                          indent: 10,
                          endIndent: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                          child: Container(
                            width: double.infinity,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                              gradient:  LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,

                                  colors: [Colors.purple, Colors.blue]
                              ) ,
                            ),
                            child: Center(child: Text('Posts', style:  TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),)),
                          ),
                        ),
                        Container(
                            height: size.height*0.55,

                            child: ProfilePost(uid : uid)),


                      ],
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      }
    );
  }
}










