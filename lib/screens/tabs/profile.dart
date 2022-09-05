import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/resources/auth.dart';
import 'package:jojo/screens/tabs/person_search/card_profile.dart';
import 'package:jojo/screens/tabs/user_profile/edit_profile.dart';
import 'package:jojo/screens/tabs/user_profile/followers.dart';
import 'package:jojo/screens/tabs/user_profile/profile_post.dart';
import 'package:jojo/screens/tabs/user_profile/profile_saved.dart';

import 'package:jojo/widgets/gesture.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileScreen extends StatefulWidget {
  static String routeName = '/userprofile' ;
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>  with SingleTickerProviderStateMixin{
  final FirebaseAuth auth =FirebaseAuth.instance ;

 late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final size = MediaQuery.of(context).size;
    final drawerItems = ListView(
      children: <Widget>[
    Container(
      height: 56,
      decoration: BoxDecoration(
        gradient:  LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [Colors.purple, Colors.blue]
        ) ,
      ),

    ),
        ListTile(
          leading: Icon(Icons.shop_rounded,),
          title: const Text('Rate this app'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.help),
          title: const Text('Help'),
          onTap: () {},
        ),
        ListTile(
          leading:  Icon(Icons.share),
          title: const Text('Share this app'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.video_library),
          title: const Text('My YouTube Channel'),
          onTap: () async {
              try{
                await launch('https://www.youtube.com/channel/UC6PagxMIxMbHXnJ35UP_Xvw');
              } catch (e){
                throw 'Could not launch https://www.youtube.com/channel/UC6PagxMIxMbHXnJ35UP_Xvw';
              }

          },
        ),
        ListTile(
          leading: Icon(Icons.feedback),
          title: const Text('Feedbacks'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.bug_report),
          title: const Text('Report Bug'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.privacy_tip),
          title: const Text('Privacy & Policy'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.lock),
          title: const Text('Terms & Conditions'),
          onTap: () {},
        ),ListTile(
          leading: Icon(Icons.phone_android),
          title: const Text('About us'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: const Text('Logout'),
          onTap: () {
    // The function showDialog<T> returns Future<T>.
    // Use Navigator.pop() to return value (of type T).
    showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
    title: const Text('Are you sure you want to logout ?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),

    actions: <Widget>[
    TextButton(
    onPressed: () => Navigator.pop(context, 'Cancel'),
    child: const Text('Cancel', style: TextStyle(color: Colors.grey),),
    ),
    TextButton(
    onPressed: () async {
            await FirebaseFirestore.instance.collection('users').doc(auth.currentUser!.uid)
                .update({'status': 'Offline'});
            AuthClass authClass = AuthClass() ;
            authClass.logOut(context) ;
            },
    child: const Text('Logout', style: TextStyle(color: Colors.redAccent),),
    ),
    ],
    ),
    );
    },
        ),
      ],
    );
    return  StreamBuilder<DocumentSnapshot>(
      stream: users.doc(auth.currentUser!.uid).snapshots(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }


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
          var bio = data['bio'];
          return Container(
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
                flexibleSpace: Container(
                 decoration: BoxDecoration(
                gradient:  LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [Colors.purple, Colors.blue]
                ) ,
              ),
                ),
                title:  Text(name),

                elevation: 0,

              ),
              endDrawer: Drawer(

                child: drawerItems,
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.purple.withOpacity(0.8),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfile(
                        name: name,
                        imageUrl: imageUrl,
                        profession: profession,
                        bio :bio
                      ),
                    ),
                  );

    },
                child: const Icon(Icons.edit),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8,top: 4, bottom: 0),
                          child:ProfileCard(name:name, imageUrl: imageUrl, level: level, profession: profession,uid: uid,onTap: (){},)

                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:  [
                          GestureDetector(child: GestureCustom(text: 'Followers', value: followers.toString()), onTap:(){
            Navigator.of(context).push(
            MaterialPageRoute(
            builder: (_) => Followers(
            what: 'followerList',
              uid: auth.currentUser!.uid,
            ),
            ),
            );
          },),

                          GestureDetector(child: GestureCustom(text: 'Following', value: following.toString()), onTap: (){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => Followers(
                                  what: 'followingList',
                                  uid: auth.currentUser!.uid,
                                ),
                              ),
                            );
                          } ,),
                          GestureCustom(text: 'Comments', value: comments.toString()),
                          GestureCustom(text: 'Live Streams', value: liveStream.toString())
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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
                      const Divider(
                        thickness: 2,
                        indent: 10,
                        endIndent: 10,

                      ),
                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(
                            25.0,
                          ),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          // give the indicator a decoration (color and border radius)
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                            gradient:  LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [Colors.purple, Colors.blue]
                            ) ,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          tabs: [
                            // first tab [you can add an icon using the icon property]
                            Tab(
                              text: 'Posts',
                            ),

                            // second tab [you can add an icon using the icon property]
                            Tab(
                              text: 'Saved',
                            ),
                          ],
                        ),
                      ),
                      // tab bar view here
                      SingleChildScrollView(
                        child: SizedBox(
                          width: size.width,
                          height: size.height*0.55,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // first tab bar view widget
                              ProfilePost(uid: auth.currentUser!.uid,),

                              // second tab bar view widget
                              ProfileSaved()
                            ],
                          ),
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),
          );
        }



    );
  }
}












