import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jojo/screens/live_stream/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'dart:typed_data';
import 'package:jojo/resources/storage_method.dart';

class EditProfile extends StatefulWidget {
  String name;
  String profession;
  String imageUrl;
  String bio ;
  EditProfile(
      {Key? key,
      required this.name,
      required this.imageUrl,
      required this.profession,
      required this.bio})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  var name = "";
  var profession = "";
  var ImageUrl = "";
  var bio = "";

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  File? imageFile;

 Uint8List? image;
late String profile ;


  final StorageMethods _storageMethods = StorageMethods();





  onSave() async {
    setState((){
      isLoading = true ;
    });
    if (image != null ) {
     profile= await _storageMethods.uploadImageToStorage(
        'profileImages',
        image!,
        _auth.currentUser!.uid,
      );
    }
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      'imageUrl': image != null ? profile : widget.imageUrl,
      'name': name == "" ? widget.name : name,
      'profession': profession == "" ? widget.profession : profession,
      'bio': bio == "" ? widget.bio : bio,
    });
    print('on save');
    print(ImageUrl);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          elevation: 0,
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      child: CircleAvatar(
                        backgroundImage:  image != null ? Image.memory(image!).image : NetworkImage(widget.imageUrl),
                        radius: size.width * 0.20,
                      ),
                      backgroundColor: Colors.purple,
                      radius: size.width * 0.21,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: GestureDetector(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: size.width*0.1,),
                              Text(
                                'Change profile photo',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Icon(Icons.edit,),
                              SizedBox(width: size.width*0.1,)
                            ],
                          ),
                          onTap: () async {
                            Uint8List? pickedImage = await pickImage();
                            if (pickedImage != null) {
                              setState(() {
                                image = pickedImage;


                              });}},)
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    initialValue: widget.name,
                    autofocus: false,
                    onChanged: (value) {
                      name = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Name: ',
                      labelStyle: TextStyle(fontSize: 20.0),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:  Colors.purple.withOpacity(0.8), width: 2)),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Name';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    initialValue: widget.profession,
                    autofocus: false,
                    onChanged: (value) {
                      profession = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Profession: ',
                      labelStyle: TextStyle(fontSize: 20.0),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:  Colors.purple.withOpacity(0.8), width: 2)),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Email';
                      } else if (!value.contains('@')) {
                        return 'Please Enter Valid Email';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    initialValue: widget.bio,
                    autofocus: false,
                    onChanged: (value) {
                      bio = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Bio: ',
                      labelStyle: TextStyle(fontSize: 20.0),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:  Colors.purple.withOpacity(0.8), width: 2)),
                      errorStyle:
                      TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Bio';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator(),)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ElevatedButton(
                        onPressed: onSave,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.purple.withOpacity(0.8),
                          minimumSize: Size(double.infinity, 40),
                        ),
                      ),
                    ),
            ],
          ),
        ));
  }
}
