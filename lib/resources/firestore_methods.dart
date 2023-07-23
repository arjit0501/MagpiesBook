import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:jojo/models/live_stream.dart';
import 'package:jojo/provider/provider.dart';
import 'package:jojo/resources/storage_method.dart';
import 'package:jojo/screens/live_stream/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';


class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance ;
  final StorageMethods _storageMethods = StorageMethods();


  Future<String> startLiveStream(
      BuildContext context, String title, Uint8List? image) async {
    DocumentSnapshot<Map<String, dynamic>> docc =  await  _firestore.collection('users').doc(_auth.currentUser!.uid).get();
   var name = docc['name'];
    print(name);
    String channelId = '';
    try {
      if (title.isNotEmpty && image != null) {
        if (!((await _firestore
            .collection('livestream')
            .doc('${_auth.currentUser!.uid}${name}')
            .get())
            .exists)) {
          String thumbnailUrl = await _storageMethods.uploadImageToStorage(
            'livestream-thumbnails',
            image,
            _auth.currentUser!.uid,
          );
          channelId = '${_auth.currentUser!.uid}${name}';
          print('chagya 1');
          LiveStream liveStream = LiveStream(
            title: title,
            image: thumbnailUrl,
            uid: _auth.currentUser!.uid,
            name: name,
            viewers: 0,
            channelId: channelId,
            startedAt: DateTime.now(),
          );

          await _firestore
              .collection('livestream')
              .doc(channelId)
              .set(liveStream.toMap());

        } else {
          showSnackBar(
              context, 'Two Livestreams cannot start at the same time.');
        }
      } else {
        showSnackBar(context, 'Please enter all the fields');
      }
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
    return channelId;
  }


  Future<String> HopOn(String uid, String name, String channelId2 ) async {
    String channelId = '';
    try {

      if (!((await _firestore
          .collection('livestream').
      doc(channelId2).collection('hopOn').
      doc('${uid}${name}')
          .get())
          .exists)) {

        channelId = '${uid}${name}';
        print('chagya 1');
        await _firestore
            .collection('livestream')
            .doc(channelId2)
            .collection('hopOn').doc(channelId).update({'uid': uid, 'isHopOn': false});
        print('chal gya 2');
      } else {
        SnackBar(content: Text('Two Livestreams cannot start at the same time.'));
      }
    } on FirebaseException catch (e) {
      SnackBar(content:Text( e.message!));
    }

    return channelId;

  }


  Future<void> chat(String text, String id, BuildContext context) async {
    DocumentSnapshot<Map<String, dynamic>> docc =  await  _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    var name = docc['name'];
    var imageUrl = docc['imageUrl'];

    try {
     String commentId = const Uuid().v1();
      await _firestore
          .collection('livestream')
          .doc(id)
          .collection('comments')
          .doc(commentId)
          .set({
        'username': name,
        'message': text,
        'uid': _auth.currentUser!.uid,
        'createdAt': DateTime.now(),
        'commentId': commentId,
        'imageUrl': imageUrl,
        'hopOn': false,
        'hopMan':""
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.message!);
    }
  }

  Future<void> updateViewCount(String id, bool isIncrease) async {
    try {
      await _firestore.collection('livestream').doc(id).update({
        'viewers': FieldValue.increment(isIncrease ? 1 : -1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> endLiveStream(String channelId) async {
    try {
      QuerySnapshot snap = await _firestore
          .collection('livestream')
          .doc(channelId)
          .collection('comments')
          .get();

      for (int i = 0; i < snap.docs.length; i++) {
        await _firestore
            .collection('livestream')
            .doc(channelId)
            .collection('comments')
            .doc(
          ((snap.docs[i].data()! as dynamic)['commentId']),
        )
            .delete();
      }
      await _firestore.collection('livestream').doc(channelId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}