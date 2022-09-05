import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed ;
  final String text;
  const CustomButton({required this.text, required this.onPressed,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(onPressed: onPressed, child: Text(text,), style: ElevatedButton.styleFrom(
      primary: Colors.purple.withOpacity(0.7 ),
      minimumSize: Size(size.width*0.4, 40)
    ),);
  }
}


class CustomButton2 extends StatelessWidget {
  final VoidCallback onPressed ;
  final String text;
  const CustomButton2({required this.text, required this.onPressed,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(onPressed: onPressed, child: Text(text,style: TextStyle(color: Colors.black),), style: ElevatedButton.styleFrom(
        primary: Colors.white54,
        minimumSize: Size(size.width*0.4, 40)
    ),);
  }
}
