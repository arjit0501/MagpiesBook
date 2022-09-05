

import 'package:flutter/material.dart';
import 'package:jojo/widgets/gesture.dart';

class ProfileCard extends StatelessWidget {
  final String name ;
  final String imageUrl;
  final String level;
  final String profession;
  final String uid;
  final VoidCallback onTap;
  const ProfileCard({Key? key, required this.name, required this.profession, required this.level, required this.imageUrl, required this.uid, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: Colors.grey[200],
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: Image.network(  imageUrl).image,
                        radius: size.width * 0.1,
                      ),
                      Container(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children:  [
                                GestureCustom(
                                    text: profession, value: name)
                              ],
                            ),
                            const SizedBox(
                              width: 40,
                            ),
                            GestureCustom(
                                text: 'Level', value: level),
                            const SizedBox(
                              width: 40,
                            ),
                            Container(
                                height: 40,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    image: const DecorationImage(
                                        image: NetworkImage(
                                            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-1NFiSNQdRU5I5p5Kr3BQiDcLC6OWVycfHQ&usqp=CAU"),
                                        fit: BoxFit.fill)))
                          ],
                        ),
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
