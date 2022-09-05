import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/home_screen.dart';
import 'package:jojo/screens/sign.dart';
class AuthClass {






   void signIn ( BuildContext context, String email, String password, String username) async{
     try {
       final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
         email: email,
         password: password,
       );
       FirebaseFirestore firestore = FirebaseFirestore.instance;
       CollectionReference users = firestore.collection('users');
       users
           .doc(credential.user!.uid).set({
         'email': email, // John Doe
         'password': password,
         'name': username,
         'imageUrl' :"https://firebasestorage.googleapis.com/v0/b/magpiesbook-87281.appspot.com/o/user_default_pic.png?alt=media&token=c06c2cba-1486-402c-958f-e9b1de8c2a0e",
         'level': 'New',
         'profession': 'Magpie',
         'followers':0,
         'following':0,
         'comments':0,
       'liveStreams': 0,// Stokes and Sons
         'uid': credential.user!.uid,
         'status' :'offline',
         'verified': false,
         'private': false ,
         'bio': "Hello Everyone!",
         'time': FieldValue.serverTimestamp(),
         'timeAgo': DateTime.now(),
         'totalPost':0,
         'totalMedia':0,
         'country': 'India'


       })
           .then((value) => print("User Added"))
           .catchError((error) => print("Failed to add user: $error"));
       Navigator.pushReplacementNamed(context, HomeScreen.routeName) ;
     } on FirebaseAuthException catch (e) {
       if (e.code == 'weak-password') {
         print('The password provided is too weak.');
       } else if (e.code == 'email-already-in-use') {
         print('The account already exists for that email.');
       }
     } catch (e) {
       print(e);
     }

   }

   void logIn ( BuildContext context, String email, String password) async {

     try {
       final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
           email: email,
           password: password,
       );

       Navigator.pushReplacementNamed(context, HomeScreen.routeName) ;
     } on FirebaseAuthException catch (e) {
       if (e.code == 'user-not-found') {
         print('No user found for that email.');
       } else if (e.code == 'wrong-password') {
         print('Wrong password provided for that user.');
       }
     }

   }

   Future logOut(BuildContext context) async {
     FirebaseAuth _auth = FirebaseAuth.instance;

     try {
       await _auth.signOut().then((value) {
         Navigator.push(
             context, MaterialPageRoute(builder: (_) => SignUpScreen()));
       });
     } catch (e) {
       print("error");
     }
   }

}