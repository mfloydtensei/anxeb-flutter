import 'dart:async';
import 'package:flutter/material.dart';

class Slide {
  final ImageProvider image;
  final double? zoomFrom;
  final Offset? pushFrom;
  final Offset? pushTo;
  final double? scale;
  int index = 0;
  late SliderOptions options;

  Slide({
    required this.image,
    this.zoomFrom,
    this.scale,
    this.pushFrom,
    this.pushTo,
  });
}

class SliderOptions {
  final Duration fadeinDuration;
  final Duration fadeoutDuration;
  final Duration transformDuration;
  final Duration transitionDuration;
  final double scale;
  int index = 0;

  SliderOptions({
    this.fadeinDuration = const Duration(milliseconds: 400),
    this.fadeoutDuration = const Duration(milliseconds: 600),
    this.transformDuration = const Duration(milliseconds: 4000),
    this.transitionDuration = const Duration(milliseconds: 2000),
    this.scale = 1.0,
  });
}

class SliderContainer extends StatefulWidget {
  final Widget Function() body;
  final List<Slide> slides;
  final Gradient? gradient;
  final SliderOptions? options;
  final ImageProvider? image;

  SliderContainer({
    super.key,
    required this.body,
    required this.slides,
    this.gradient,
    this.options,
    this.image,
  }) {
    for (var i = 0; i < slides.length; i++) {
      slides[i].index = i;
      slides[i].options = options ?? SliderOptions();
    }
  }

  @override
  State<SliderContainer> createState() =>
      _SliderContainerState(body: body, gradient: gradient, slides: slides);
}

class _Slide extends StatefulWidget {
  final Slide definition;
  final bool visible;

  const _Slide(this.definition, {Key? key, required this.visible}) : super(key: key);

  @override
  State<_Slide> createState() => _SlideState();
}

class _SlideState extends State<_Slide> with TickerProviderStateMixin {
  late final AnimationController _opacityController;
  late final AnimationController _scaleController;
  late final AnimationController _positionController;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _positionAnimation;

  bool _isVisible = false;

  Slide get definition => widget.definition;

  @override
  void initState() {
    super.initState();

    final options = definition.options;

    _opacityController = AnimationController(
      duration: options.fadeinDuration,
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      reverseDuration: options.fadeoutDuration,
    );

    _opacityController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _scaleController.reverse();
        _positionController.reverse();
      }
    });

    _opacityAnimation =
        CurvedAnimation(parent: _opacityController, curve: Curves.linear);

    _scaleController = AnimationController(
      duration: options.transformDuration,
      vsync: this,
      lowerBound: definition.zoomFrom ?? 0.8,
      upperBound: 1.0,
    );

    _scaleAnimation =
        CurvedAnimation(parent: _scaleController, curve: Curves.linear);

    _positionController = AnimationController(
      duration: options.transformDuration,
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
    );

    _positionAnimation = Tween<Offset>(
      begin: definition.pushFrom ?? Offset.zero,
      end: definition.pushTo ?? Offset.zero,
    ).animate(_positionController);

    _opacityController.addListener(_refresh);
    _scaleController.addListener(_refresh);
    _positionController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _scaleController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  double get _scale => definition.scale ?? definition.options.scale;

  double get _scaleSubtract => _scale < 0 ? 2 : 0;

  @override
  Widget build(BuildContext context) {
    if (_isVisible != widget.visible) {
      if (widget.visible) {
        _scaleController.forward();
        _positionController.forward();
        _opacityController.forward();
      } else {
        _opacityController.reverse();
      }
      _isVisible = widget.visible;
    }

    return Transform.scale(
      scale: (_scaleAnimation.value - _scaleSubtract) * _scale,
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: SlideTransition(
          position: _positionAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Image(
              image: definition.image,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}

class _SliderContainerState extends State<SliderContainer> {
  final Widget Function() body;
  final Gradient? gradient;
  final List<Slide> slides;

  _SliderContainerState({
    required this.body,
    required this.gradient,
    required this.slides,
  });

  int _currentIndex = 0;
  Timer? _timer;

  void _nextSlide() {
    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % slides.length;
    });
  }

  @override
  void initState() {
    super.initState();
    final duration =
        widget.options?.transitionDuration ?? const Duration(seconds: 2);
    _timer = Timer.periodic(duration, (_) => _nextSlide());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Slides con animaciones
        Stack(
          children: widget.slides.map((slide) {
            return _Slide(
              slide,
              visible: slide.index == _currentIndex,
            );
          }).toList(),
        ),

        // Gradiente opcional
        if (gradient != null)
          Container(
            decoration: BoxDecoration(gradient: gradient),
          ),

        // Imagen fija opcional
        if (widget.image != null)
          Image(
            image: widget.image!,
            fit: BoxFit.cover,
            width: size.width,
            height: size.height,
            alignment: Alignment.topCenter,
          ),

        // Cuerpo principal
        body(),
      ],
    );
  }
}
