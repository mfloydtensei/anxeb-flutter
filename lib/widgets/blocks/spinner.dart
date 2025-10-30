import 'package:flutter/material.dart';

class SpinnerBlock extends StatefulWidget {
  /// Icono que se va a rotar
  final Icon icon;

  /// Duración de una rotación completa (por defecto 1.8 segundos)
  final Duration duration;

  const SpinnerBlock({
    super.key,
    required this.icon,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<SpinnerBlock> createState() => _SpinnerBlockState();
}

class _SpinnerBlockState extends State<SpinnerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(); // Repetir animación indefinidamente
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: widget.icon,
    );
  }
}
