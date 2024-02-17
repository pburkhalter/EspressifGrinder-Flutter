import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String text;
  final double padding;

  const TitleText({
    Key? key,
    required this.text,
    this.padding = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 40,
          height: 1.1,
          letterSpacing: -2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
