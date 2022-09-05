import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:jojo/resources/firestore_methods.dart';
import 'package:jojo/screens/live_stream/responsive/responsive.dart';
import 'package:jojo/screens/live_stream/utils/utils.dart';

import 'broadcast_screen.dart';


class GoLiveScreen extends StatefulWidget {
  static String routeName = '/goLive';
  const GoLiveScreen({Key? key}) : super(key: key);

  @override
  State<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends State<GoLiveScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool isLoading = false ;
  Uint8List? image;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  goLiveStream() async {
    setState((){
      isLoading = true ;
    });
    String channelId = await FirestoreMethods()
        .startLiveStream(context, _titleController.text, image);


    if (channelId.isNotEmpty) {
      showSnackBar(context, 'Livestream has started successfully!');
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastScreen(
          isBroadcaster: true,
         channelId: channelId,
          ),
        ),
      );
    }
    setState((){
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Live Stream'),
        centerTitle: true,
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: GestureDetector(
                onTap: () async {
    Uint8List? pickedImage = await pickImage();
    if (pickedImage != null) {
    setState(() {
    image = pickedImage;
    });}},
                child: image != null
                    ? SizedBox(
                  height: 300,
                  child: Image.memory(image!),
                ):DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(12),
                    dashPattern: const [10, 4],
                    strokeCap: StrokeCap.round,
                    color: Colors.purple,
                    child: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Container(

                          decoration: BoxDecoration(

borderRadius: BorderRadius.circular(12),
                            gradient:  LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,

                                colors: [Colors.purple.withOpacity(0.3), Colors.blue.withOpacity(0.3)]
                            ) ,

                          ),
                          height: size.height * 0.3,
                          width: size.width * 0.7,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.create_new_folder_outlined,
                                  size: 40,
                                  
                                  color: Colors.purple.withOpacity(0.8),
                                ),
                                Text('Thumbnail')
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: _titleController,
                    decoration:  InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.purple.withOpacity(0.8),width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2)),
                    ),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            isLoading? Center(child: CircularProgressIndicator(
              color: Colors.purple,
            )): Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: ElevatedButton(
                onPressed: goLiveStream,
                style: ElevatedButton.styleFrom(
                  primary:  Colors.purple.withOpacity(0.8),
                  minimumSize: Size(size.width * 0.4, 40),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Start Live Stream',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.video_call_sharp,
                      color: Colors.grey[300],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
