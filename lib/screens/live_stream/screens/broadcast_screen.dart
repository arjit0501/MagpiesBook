

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jojo/config/appId.dart';
import 'package:jojo/provider/provider.dart';
import 'package:jojo/resources/firestore_methods.dart';
import 'package:jojo/screens/live_stream/responsive/reponsive_layout.dart';
import 'package:jojo/screens/live_stream/screens/hopOn.dart';
import 'package:jojo/screens/live_stream/widgets/chat.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;
import 'package:flutter/physics.dart';


class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;

  BroadcastScreen({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> with WidgetsBindingObserver   {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;
 late  String namee ;
  late String uiid ;

  bool hopOn= false ;
  late String channelId ;





  final  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance ;

  void onHopOn() async{
    DocumentSnapshot<Map<String, dynamic>> docc =  await _firestore.collection('livestream').doc(widget.channelId).collection('hopOn').doc(widget.channelId).get();
    bool isHopOn = docc['isHopOn'];

    hopOn = isHopOn ;

  }

  @override

  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initEngine();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // online
      _leaveChannel();
      print('band ho gyi');
    }
  }





  void _initEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  String baseUrl = "https://filam.herokuapp.com";

  String? token;


  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelId +
          '/publisher/userAccount/' +
          _auth.currentUser!.uid +
          '/'),
    );

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)['rtcToken'];
      });
    } else {
      debugPrint('Failed to fetch the token');
    }
  }

  void _addListeners() {
    _engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
          debugPrint('joinChannelSuccess $channel $uid $elapsed');
        }, userJoined: (uid, elapsed) {
          debugPrint('userJoined $uid $elapsed');
          setState(() {
            remoteUid.add(uid);
          });
        }, userOffline: (uid, reason) {
          debugPrint('userOffline $uid $reason');
          setState(() {
            remoteUid.removeWhere((element) => element == uid);
          });
        }, leaveChannel: (stats) {
          debugPrint('leaveChannel $stats');
          setState(() {
            remoteUid.clear();
          });
        }, tokenPrivilegeWillExpire: (token) async {
          await getToken();
          await _engine.renewToken(token);
        }));
  }

  void _joinChannel() async {
    await getToken();
    if (token != null) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [Permission.microphone, Permission.camera].request();
      }
      await _engine.joinChannelWithUserAccount(
        token,
        widget.channelId,
        _auth.currentUser!.uid,
      );
    }
  }

  void _switchCamera() {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  _startScreenShare() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screensharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScreenSharing = true;
    });
    await helper.joinChannelWithUserAccount(
      token,
      widget.channelId,
      _auth.currentUser!.uid,
    );
  }

  _stopScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScreenSharing = false;
      });
    }).catchError((err) {
      debugPrint('StopScreenShare $err');
    });
  }

  _leaveChannel() async {
    Navigator.pop(context);
    Navigator.pop(context);
    DocumentSnapshot<Map<String, dynamic>> docc =  await  _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    var name = docc['name'];
    await _engine.leaveChannel();
    if ('${_auth.currentUser!.uid}$name' ==
        widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }

  }

  _leaveChannel2() async {
    Navigator.pop(context);
    DocumentSnapshot<Map<String, dynamic>> docc =  await  _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    var name = docc['name'];
    await _engine.leaveChannel();
    if ('${_auth.currentUser!.uid}$name' ==
        widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }

  }



  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size ;

    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel2();
        return Future.value(true);
      },
      child: SafeArea(
        child: StreamBuilder<DocumentSnapshot?>(
            stream:  _firestore.collection('livestream').doc(widget.channelId).snapshots() ,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                Map<String, dynamic> data = snapshot.data!.data() as Map<
                    String,
                    dynamic>;
                var viewers = data['viewers'];
                var usernamee = data['name'];
                return Scaffold(
                  appBar: AppBar(
                    title: Text(usernamee.toString()),
                    actions: [
                      IconButton(onPressed: () {}

                          ,
                          icon: Icon(
                            Icons.video_call_rounded, color: Colors.purple[300],
                            size: 30,)),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.1),
                        child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.redAccent
                                  ), child: Text('Live')),
                              Icon(Icons.remove_red_eye_outlined),
                              SizedBox(width: size.width * 0.04,),
                              Text(viewers.toString())
                            ]),
                      )
                    ],
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

                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ResponsiveLatout(
                      desktopBody: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _renderVideo(
                                      usernamee.toString(), isScreenSharing),
                                  if ("${_auth.currentUser!.uid}${usernamee
                                      .toString()}" == widget.channelId)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceEvenly,
                                      children: [
                                        InkWell(
                                            onTap: _switchCamera,
                                            child: switchCamera
                                                ? Icon(
                                                Icons.switch_camera_outlined)
                                                : Icon(
                                                Icons.switch_camera)
                                        ),
                                        InkWell(
                                          onTap: onToggleMute,
                                          child: isMuted
                                              ? Icon(Icons.mic_off_sharp)
                                              : Icon(Icons.mic),
                                        ),
                                        InkWell(
                                            onTap: isScreenSharing
                                                ? _stopScreenShare
                                                : _startScreenShare,
                                            child: isScreenSharing
                                                ? Icon(
                                                Icons.screen_share_outlined)
                                                : Icon(
                                                (Icons
                                                    .stop_screen_share_outlined))
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Chat(channelId: widget.channelId),
                        ],
                      ),
                      mobileBody: SingleChildScrollView(
                        child: Container(
                          height: size.height * 0.9,
                          width: size.width,
                          child: Column(

                            children: [
                              "${_auth.currentUser!.uid}${usernamee
                                  .toString()}" ==
                                  widget.channelId ?
                              Container(
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(10),),
                                  color: Colors.orangeAccent.withOpacity(0.5),

                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,

                                      colors: [
                                        Colors.purple.withOpacity(0.7),
                                        Colors.blue.withOpacity(0.7)
                                      ]
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    InkWell(
                                        onTap: _switchCamera,
                                        child: switchCamera
                                            ? Icon(
                                            Icons.switch_camera_outlined)
                                            : Icon(
                                            Icons.switch_camera)
                                    ),
                                    //SizedBox(width:size.width*0.3 ,),
                                    InkWell(
                                      onTap: onToggleMute,
                                      child: isMuted
                                          ? Icon(Icons.mic_off_sharp)
                                          : Icon(
                                          Icons.mic),
                                    ),
                                    InkWell(
                                      onTap: _leaveChannel,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.all(5)
                                        ,
                                        child: Icon(Icons.call_end, size: 15,),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                20),
                                            color: Colors.redAccent
                                        ),),
                                    ),

                                  ],
                                ),
                              ) : Container(),
                              _renderVideo(
                                  usernamee.toString(), isScreenSharing),

                              Expanded(
                                child: Chat(
                                  channelId: widget.channelId,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              else{
                return Container() ;
              }
            }

        ),
      ),
    );
  }

  _renderVideo(String name, isScreenSharing) {
    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: AspectRatio(
          aspectRatio: 8 / 9,
          child: "${_auth.currentUser!.uid}$name" == widget.channelId
              ? isScreenSharing
              ? kIsWeb
              ? const RtcLocalView.SurfaceView.screenShare()
              : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
            zOrderMediaOverlay: true,
            zOrderOnTop: true,
          )
              : isScreenSharing
              ? kIsWeb
              ? const RtcLocalView.SurfaceView.screenShare()
              : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty
              ? kIsWeb
              ? RtcRemoteView.SurfaceView(
            uid: remoteUid[0],
            channelId: widget.channelId,
          )
              : RtcRemoteView.TextureView(
            uid: remoteUid[0],
            channelId: widget.channelId,
          )
              : Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),),


    );
  }
}

class DraggableCard extends StatefulWidget {
  final Widget child;

  DraggableCard({required this.child});

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  var _dragAlignment = Alignment.center;

  late Animation<Alignment> _animation;

  final _spring = const SpringDescription(
    mass: 10,
    stiffness: 1000,
    damping: 0.9,
  );

  double _normalizeVelocity(Offset velocity, Size size) {
    final normalizedVelocity = Offset(
      velocity.dx / size.width,
      velocity.dy / size.height,
    );
    return -normalizedVelocity.distance;
  }

  void _runAnimation(Offset velocity, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.center,
      ),
    );

    final simulation =
    SpringSimulation(_spring, 0, 0.0, _normalizeVelocity(velocity, size));

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() => _dragAlignment = _animation.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanStart: (details) => _controller.stop(canceled: true),
      onPanUpdate: (details) => setState(
            () => _dragAlignment += Alignment(
          details.delta.dx / (size.width / 2),
          details.delta.dy / (size.height / 2),
        ),
      ),
      onPanEnd: (details) =>
          _runAnimation(details.velocity.pixelsPerSecond, size),
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}




