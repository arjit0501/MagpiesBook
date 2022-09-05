import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:jojo/screens/live_stream/screens/feed_screen.dart';
import 'package:jojo/screens/tabs/chat.dart';
import 'package:jojo/screens/tabs/person-search.dart';
import 'package:jojo/screens/tabs/post.dart';
import 'package:jojo/screens/tabs/profile.dart';


class HomeScreen extends StatefulWidget {
  static String routeName = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _page = 0;
  List<Widget> pages = [
    const FeedScreen(),
    const PersonSearchScreen(),
    const PostScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
       backgroundColor: Colors.purple.withOpacity(1),
        elevation: 0.01,
        onTap: onPageChange,
        currentIndex: _page,
        selectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,


        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
          label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_search),
          label: 'Search'),
          BottomNavigationBarItem(icon:Icon(Icons.emoji_objects_outlined ),
          label: 'Ideas'),
          BottomNavigationBarItem(icon: Icon(Icons.chat),
          label: 'Inbox   '),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),
          label: 'Profile')

        ],
      ) ,
      body: pages[_page],
    );
  }
}
