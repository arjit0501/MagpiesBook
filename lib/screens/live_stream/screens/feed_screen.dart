import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:jojo/models/live_stream.dart';
import 'package:jojo/resources/firestore_methods.dart';
import 'package:jojo/screens/live_stream/responsive/reponsive_layout.dart';
import 'package:jojo/screens/live_stream/screens/broadcast_screen.dart';
import 'package:jojo/screens/live_stream/screens/feed_screen/following_post.dart';
import 'package:jojo/screens/live_stream/screens/go_live_screen.dart';
import 'package:jojo/screens/live_stream/widgets/loading_indicator.dart';

import 'package:timeago/timeago.dart' as timeago;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false ;
  @override
  Widget build(BuildContext context) {
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
          leading: Icon(Icons.wallet,),
          title: const Text('My Wallet'),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(Icons.list_alt),
          title: const Text('History'),
          onTap: () {},
        ),


      ],
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'MagpiesBook',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'MagpiesBook'),
        ),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications_active))
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient:  LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: [Colors.purple, Colors.blue]
            ) ,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(

        child: drawerItems,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            Navigator.pushNamed(context, GoLiveScreen.routeName);
          });
        },
        backgroundColor: Colors.purple.withOpacity(0.8),
        child: const Icon(Icons.video_call),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(
            top: 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: size.height*0.26,
                  decoration: BoxDecoration(
                      gradient:  LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,

                          colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)]
                      ) ,
                    borderRadius: BorderRadius.circular(10),

                  ),
                  child: Column(
                    children: [
                      Container(
                        width: size.width*0.3,
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.symmetric(horizontal: 5,vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:  Colors.redAccent.withOpacity(0.8),

                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Live Users',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Icon(Icons.live_tv, size: 20, )
                          ],
                        ),
                      ),

                      StreamBuilder<dynamic>(
                        stream: FirebaseFirestore.instance
                            .collection('livestream').
                          orderBy('viewers', descending: false)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const LoadingIndicator();
                          }

                          return Expanded(
                            child: ResponsiveLatout(
                              desktopBody: GridView.builder(
                                itemCount: snapshot.data.docs.length,
                                gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                ),
                                itemBuilder: (context, index) {
                                  LiveStream post = LiveStream.fromMap(
                                      snapshot.data.docs[index].data());
                                  return InkWell(
                                    onTap: () async {
                                      await FirestoreMethods()
                                          .updateViewCount(post.channelId, true);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => BroadcastScreen(
                                            isBroadcaster: false,
                                            channelId: post.channelId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: size.height * 0.35,
                                            child: Image.network(
                                              post.image,
                                              fit: BoxFit.contain,

                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color:  Colors.purple
                                                ),

                                              ),
                                              Text(
                                                post.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text('${post.viewers} watching'),
                                              Text(
                                                'Started ${timeago.format(post.startedAt.toDate())}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              mobileBody:snapshot.data.docs.length ==0 ? Center(child: Text('No User is live'),): isLoading ? Center(
                                child: CircularProgressIndicator(),
                              ) : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                  itemCount:snapshot.data.docs.length,
                                  itemBuilder: (context, index) {
                                    LiveStream post = LiveStream.fromMap(
                                        snapshot.data.docs[index].data());
                                    print(post.name);

                                    return InkWell(
                                      onTap: () async {
                                        print('Challaaaa 1');

                                        print('Challaaaa 2');

                                        print('Challaaaa 3');


                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => BroadcastScreen(
                                              isBroadcaster: false,
                                                    channelId: post.channelId,
                                            ),
                                          ),
                                        );
                                        await FirestoreMethods()
                                            .updateViewCount(post.channelId, true);
                                        print('Challaaaa 4');
                                print('Challaaaa 5');

                                      },
                                      child:Container(

                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),

                                            image: DecorationImage(image: NetworkImage(post.image, ),
                                                fit: BoxFit.fill,opacity: 0.7)
                                        ),

                                        height: size.height* 0.2,
                                        width: size.width*0.33,
                                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                                        child:  Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly
                                              ,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                            width: size.width*0.2,
                                                  child: Text(

                                                    post.name,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.purple
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: size.width*0.2,
                                                  child: Text(
                                                    post.title,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,

                                                    ),
                                                  ),
                                                ),
                                                Container(width: size.width*0.2,
                                                    child: Text('${post.viewers} watching', overflow: TextOverflow.ellipsis,),),
                                                Container(
                                                  width: size.width*0.20,
                                                  child: Text(
                                                    '${timeago.format(post.startedAt.toDate())}',
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                Icons.more_vert,
                                              ),
                                              alignment: Alignment.center,
                                            ),
                                          ],
                                        ),
                                      ),

                                    );
                                  }),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10,),
                Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(10))
                      ),
                    height: size.height*0.55,
                    child: FollowingPost())
              ],
            ),
          ),
        ),
      ),
    );
  }
}