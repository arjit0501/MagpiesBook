import 'package:flutter/material.dart';
import 'package:jojo/screens/tabs/person_search/user_search.dart';
import 'package:jojo/widgets/textfield.dart';


class PersonSearchScreen extends StatefulWidget {
  const PersonSearchScreen({Key? key}) : super(key: key);

  @override
  State<PersonSearchScreen> createState() => _PersonSearchScreenState();
}

class _PersonSearchScreenState extends State<PersonSearchScreen> {
  TextEditingController controller =TextEditingController();
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,
      body: UserSearch()
    );
  }
}
