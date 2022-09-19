import 'package:fishery_management_client/utils/colors.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  final String text;

  const ButtonWidget({
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      color: secondaryColor,
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(80, 15, 80, 15),
        child: Text(
          text,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.white,
              fontFamily: 'QRegular'),
        ),
      ),
    );
  }
}
