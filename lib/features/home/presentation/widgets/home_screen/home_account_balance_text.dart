import 'package:flutter/material.dart';

class HomeAccountBalanceText extends StatelessWidget {
  const HomeAccountBalanceText({
    super.key,
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Text(text, style: style, maxLines: 1),
      ),
    );
  }
}
