

import 'package:flutter/material.dart';
import 'package:jojo/widgets/gesture.dart';

class ChatCard extends StatelessWidget {
  final String name ;
  final String imageUrl;

  final String status;
  final String uid;
  final VoidCallback onTap;
  const ChatCard({Key? key, required this.name, required this.status,  required this.imageUrl, required this.uid, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width*0.9,
      child: GestureDetector(
        onTap: onTap,
        child: Card(

          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage( imageUrl),
                        radius: size.width * 0.08,
                      ),

                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20),
                         child: Column(
                           children: [
                             Text(name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.grey[900]),),
                             Text(status, style:  TextStyle(fontWeight: FontWeight.bold , color :status == 'Online' ? Colors.green : Colors.grey[600] ),)
                           ],
                         )
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
