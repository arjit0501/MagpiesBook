//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// class FollowSuggestion extends StatefulWidget {
//   const FollowSuggestion({Key? key}) : super(key: key);
//
//   @override
//   State<FollowSuggestion> createState() => _FollowSuggestionState();
// }
//
// class _FollowSuggestionState extends State<FollowSuggestion> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//         future: FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.uid)
//         .get(),
//     builder: (_, snapshot) {
//     if (snapshot.hasError) {
//     print('something wet wrong');
//     }
//     if (snapshot.connectionState == ConnectionState.waiting) {
//     return Shimmer.fromColors(
//     // enabled: true,
//     baseColor: Colors.grey[400]!,
//     highlightColor: Colors.grey[100]!,
//     child: ListView.separated(
//     shrinkWrap: true,
//     physics: const ClampingScrollPhysics(),
//     itemCount: 1,
//     itemBuilder: (_, __) => Padding(
//     padding: const EdgeInsets.only(bottom: 4),
//     child: placeHolderRow(),
//     ),
//     separatorBuilder: (_,__) => const SizedBox(height: 2),
//     ),
//
//     );
//     }
//     var data = snapshot.data!.data();
//     var name = data!['name'];
//     var imageUrl = data['imageUrl'];
//
//     return Container();
//   }
// }
