import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/person_search/card_profile.dart';
import 'package:jojo/screens/tabs/user_profile/user_profile.dart';


class UserSearch extends StatefulWidget {
  const UserSearch({Key? key}) : super(key: key);

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  Map<String, dynamic> userMap = {};
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();

  List<Map> store = [];

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isGreaterThanOrEqualTo: _searchController.text.trim())
        .get()
        .then((value) {
      setState(() {
        userMap = {};
       store = [];
        int k = value.docs.length;
        print(k);
        for (var i = 0; i < k; i++) {
          userMap = value.docs[i].data();
          store.add(userMap);
        }
        isLoading = false;
      });
      print(userMap);
    });
  }



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: TextFormField(
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      labelStyle: TextStyle(fontSize: 20),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 20),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color:  Colors.purple.withOpacity(0.8), width: 2)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2)),
                    ),
                    controller: _searchController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter';
                      }
                      return null;
                    },
                  ),
                ),
                isLoading
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          onPressed: onSearch,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Search',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: size.width * 0.02,
                              ),
                              Icon(Icons.search),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.purple.withOpacity(0.8),
                            minimumSize: Size(double.infinity, 40),
                          ),
                        ),
                      ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                isLoading
                    ? Container(
                        width: size.width * 0.5,
                        height: size.height * 0.5,
                        child: Center(child: CircularProgressIndicator()))
                    : userMap.length != 0
                        ? Container(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (var i = 0; i < store.length; i++) ...[
                                    Container(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 10),
                                        child: ProfileCard(
                                          name: store[i]['name'],
                                          imageUrl: store[i]['imageUrl'],
                                          level: store[i]['level'],
                                          profession: store[i]['profession'],
                                          uid: store[i]['uid'],
                                          onTap: (){
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => UserProfile(
                                                  uuid: store[i]['uid'],
                                                ),
                                              ),
                                            );
                                          },
                                        ))
                                  ]
                                ],
                              ),
                            ),
                            height: size.height * 0.71,
                          )
                        : Container(
                            width: size.width * 0.5,
                            height: size.height * 0.5,
                            child: Center(
                              child: Text(
                                'No Result',
                                style:
                                    TextStyle(color: Colors.black, fontSize: 18),
                              ),
                            ))
              ],
            ),
          ),
        ),
      ),
         decoration: BoxDecoration(
    gradient:  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,

        colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)]
    ) ,
    ),
    );
  }
}
