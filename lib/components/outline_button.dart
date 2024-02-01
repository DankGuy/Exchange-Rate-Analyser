import 'package:flutter/material.dart';

class OutlineBtn extends StatelessWidget {
  final VoidCallback onPressed;
  final String btnText;

  const OutlineBtn({super.key, required this.onPressed, required this.btnText});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.purpleAccent[700],
        side: const BorderSide(
            color: Colors.purpleAccent, width: 2, style: BorderStyle.solid),
      ),
      onPressed: onPressed,
      child: Text(
        btnText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}
