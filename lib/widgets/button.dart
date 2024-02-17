import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double minWidth;
  final double height;
  final double padding;

  const CustomElevatedButton({
    Key? key,
    required this.buttonText,
    required this.onPressed,
    this.padding = 16.0,
    this.backgroundColor = Colors.black,
    this.textColor = Colors.white,
    this.minWidth = 150,
    this.height = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: textColor,
            backgroundColor: backgroundColor,
            shape: const StadiumBorder(),
            minimumSize: Size(minWidth, height),
          ),
          onPressed: onPressed,
          child: Text(buttonText,
            style: const TextStyle(fontSize: 16)
          ),
        ),
      ),
    );
  }
}
