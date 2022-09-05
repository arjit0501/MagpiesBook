import 'package:flutter/material.dart';

class TextFieldCustom extends StatelessWidget {
 final TextEditingController controller ;
  TextFieldCustom({required this.controller,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(

      controller: controller,
 decoration: const InputDecoration(
   focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.purple, width: 2)),
enabledBorder:  OutlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2)),
 ),
      style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),

    );
  }
}
