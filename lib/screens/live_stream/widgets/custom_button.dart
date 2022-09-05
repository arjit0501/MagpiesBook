
import 'package:flutter/material.dart';
import 'package:jojo/screens/live_stream/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed ;
  final String text ;
  const CustomButton({Key? key , required this.onPressed ,
  required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      primary: Colors.red,
      minimumSize: const Size(double.infinity,40)
    ), child: Text(text),);
  }
}
