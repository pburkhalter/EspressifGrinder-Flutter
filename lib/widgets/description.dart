import 'package:flutter/material.dart';

class DescriptionText extends StatelessWidget {
  final String text;
  final double padding;

  const DescriptionText({
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
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
