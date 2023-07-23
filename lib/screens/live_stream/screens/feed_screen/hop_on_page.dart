import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jojo/config/appId.dart';
import 'package:jojo/resources/firestore_methods.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:http/http.dart' as http;


class BroadcastScreen2 extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;

  BroadcastScreen2({
    Key? key,
    required this.isBroadcaster,
    required this.channelId,
  }) : super(key: key);

  @override
  State<BroadcastScreen2> createState() => _BroadcastScreenState2();
}

class _BroadcastScreenState2 extends State<BroadcastScreen2>
    with WidgetsBindingObserver {
  late final RtcEngine _engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;
  late String namee;
  late String uiid;

  bool hopOn = false;
  late String channelId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initEngine();
  }

  @override
  void dispose() {
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
        },
            userJoined: (uid, elapsed) {
              debugPrint('userJoined $uid $elapsed');
              setState(() {
                remoteUid.add(uid);
              });
            },
            userOffline: (uid, reason) {
              debugPrint('userOffline $uid $reason');
              setState(() {
                remoteUid.removeWhere((element) => element == uid);
              });
            },
            leaveChannel: (stats) {
              debugPrint('leaveChannel $stats');
              setState(() {
                remoteUid.clear();
              });
            },
            tokenPrivilegeWillExpire: (token) async {
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

  }

  // _leaveChannel2() async {
  //   Navigator.pop(context);
  //   DocumentSnapshot<Map<String, dynamic>> docc =
  //   await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
  //   var name = docc['name'];
  //   await _engine.leaveChannel();
  //   if ('${_auth.currentUser!.uid}$name' == widget.channelId) {
  //     await FirestoreMethods().endLiveStream(widget.channelId);
  //   } else {
  //     await FirestoreMethods().updateViewCount(widget.channelId, false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;

    return WillPopScope(
      onWillPop: () async {
        // await _leaveChannel2();
        return Future.value(true);
      },

      child: Container(

                          width: size.width,
                          child: Column(
                            children: [
                              _auth.currentUser!.uid
                                  ==
                                  widget.channelId
                                  ? Container(
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(10),
                                  ),
                                  color: Colors.orangeAccent
                                      .withOpacity(0.5),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.purple.withOpacity(0.7),
                                        Colors.blue.withOpacity(0.7)
                                      ]),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                        onTap: _switchCamera,
                                        child: switchCamera
                                            ? Icon(Icons
                                            .switch_camera_outlined)
                                            : Icon(Icons.switch_camera)),
                                    //SizedBox(width:size.width*0.3 ,),
                                    InkWell(
                                      onTap: onToggleMute,
                                      child: isMuted
                                          ? Icon(Icons.mic_off_sharp)
                                          : Icon(Icons.mic),
                                    ),
                                    InkWell(
                                      onTap: _leaveChannel,
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        margin: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.call_end,
                                          size: 15,
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(20),
                                            color: Colors.redAccent),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  : Container(),

                              _renderVideo ("", false),

                            ],
                          )
                  ),


    );
  }

  _renderVideo(String name, isScreenSharing) {
    return Container(
      height: 100,
      width: 100,
      margin: EdgeInsets.only(bottom: 5),
      child:  "${_auth.currentUser!.uid}$name" == widget.channelId
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
          ),

    );
  }


}