
import 'package:flutter/material.dart';

class GestureCustom extends StatelessWidget {
  final String text ;
  final String value ;
  const GestureCustom({Key? key, required this.text, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[900]),),
        SizedBox(height: 6,),
        Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),),
      ],
    );
  }
}
