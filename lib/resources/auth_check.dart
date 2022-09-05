import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthMethod{
final _userRef = FirebaseFirestore.instance.collection('users');
final _auth = FirebaseAuth.instance;

Future<Map<String, dynamic>?> getCurrentUser(String? uid) async {
if (uid != null) {
final snap = await _userRef.doc(uid).get();
return snap.data();
}
return null;
}
}