import 'package:flutter/material.dart';

class ParagraphBlock extends StatelessWidget {
  final String? text;
  final List<TextSpan>? content;
  final TextAlign alignment;
  final bool bold;

  const ParagraphBlock({
    super.key,
    this.text,
    this.content,
    this.alignment = TextAlign.left,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    // Estilo base
    final baseStyle = TextStyle(
      fontSize: 18,
      fontWeight: bold ? FontWeight.w600 : FontWeight.w300,
      letterSpacing: 0.3,
      color: const Color(0xff444444),
      height: 1.4,
    );

    // Si se pasa 'content', usamos RichText; si no, usamos Text plano.
    if (content != null && content!.isNotEmpty) {
      return RichText(
        textAlign: alignment,
        text: TextSpan(
          style: baseStyle,
          children: content,
        ),
      );
    }

    return Text(
      text ?? '',
      textAlign: alignment,
      style: baseStyle,
    );
  }
}
