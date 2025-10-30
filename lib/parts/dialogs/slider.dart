import 'package:anxeb_flutter/middleware/dialog.dart';
import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:anxeb_flutter/anxeb.dart' as Anxeb;
import 'package:flutter/material.dart' hide Dialog;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../middleware/application.dart';

class SliderDialog<V> extends ScopeDialog<V> {
  final List<SliderItem> slides;

  SliderDialog(
    Scope scope, {
    required this.slides,
  }) : super(scope) {
    super.dismissible = true;
  }

  @override
  Widget build(BuildContext context) {
    return _SliderBlock(
      scope: scope,
      slides: slides,
    );
  }
}

class _SliderBlock extends StatefulWidget {
  final Scope scope;
  final List<SliderItem> slides;

  const _SliderBlock({
    required this.scope,
    required this.slides,
  });

  @override
  State<_SliderBlock> createState() => _SliderBlockState();
}

class _SliderBlockState extends State<_SliderBlock> {
  late final PageController _controller;
  int _index = 0;
  late final double _width;

  @override
  void initState() {
    super.initState();
    _controller = PageController(keepPage: true);

    _width = widget.scope.window.available.width;

    if (widget.slides.isNotEmpty) {
      widget.slides.first.onOpened?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    final pages = widget.slides.map((slide) {
      final fillColor = slide.color ?? Colors.white;

      return Stack(
        fit: StackFit.expand,
        children: [
          if (slide.cover != null)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                    fillColor.withOpacity(0.4),
                    BlendMode.screen,
                  ),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  image: slide.cover!.image,
                ),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  fillColor.withOpacity(0.5),
                  Colors.white.withOpacity(0.6),
                  Colors.white.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  slide.title ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                ),
              ),
              if (slide.image != null)
                SizedBox(
                  width: _width * 0.35,
                  height: _width * 0.35,
                  child: slide.image,
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  child: slide.content?.call() ??
                      Text(
                        slide.body ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                        ),
                      ),
                ),
              ),
              if (slide.action != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  child: slide.action!,
                ),
              const SizedBox(height: 60),
            ],
          ),
        ],
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 80, top: 40),
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: radius),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                children: pages,
                onPageChanged: (index) {
                  setState(() {
                    _index = index;
                    widget.slides[_index].onOpened?.call();
                  });
                },
              ),
              // 🔹 Indicadores + botones navegación
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isOnePage)
                        Anxeb.IconButton(
                          padding: const EdgeInsets.only(left: 12),
                          iconSize: 24,
                          fillColor: _isFirstPage
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.5),
                          innerColor: _isFirstPage
                              ? application.settings.colors.primary.withOpacity(0.3)
                              : application.settings.colors.primary,
                          size: 33,
                          icon: Icons.chevron_left,
                          action: () async {
                            if (!_isFirstPage) {
                              await _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease,
                              );
                            }
                          },
                        ),
                      if (pages.length > 1)
                        Expanded(
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _controller,
                              count: pages.length,
                              effect: WormEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: application.settings.colors.primary,
                                dotColor: application.settings.colors.primary.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                      Anxeb.IconButton(
                        padding: const EdgeInsets.only(right: 12),
                        iconSize: 24,
                        fillColor: Colors.white.withOpacity(0.5),
                        innerColor: _isLastPage
                            ? application.settings.colors.primary.withOpacity(0.5)
                            : application.settings.colors.primary,
                        size: 33,
                        icon: _isLastPage ? Icons.check : Icons.chevron_right,
                        action: () async {
                          if (_isLastPage) {
                            Navigator.of(context).pop();
                          } else {
                            await _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isOnePage => widget.slides.length == 1;

  bool get _isLastPage => _isOnePage ? true : _index >= widget.slides.length - 1;

  bool get _isFirstPage => _isOnePage ? true : _index == 0;

  Application get application => widget.scope.application;
}

class SliderItem {
  final String? title;
  final String? body;
  final Widget Function()? content;
  final Image? cover;
  final Image? image;
  final Color? color;
  final Anxeb.TextButton? action;
  final VoidCallback? onOpened;

  const SliderItem({
    this.title,
    this.body,
    this.content,
    this.cover,
    this.image,
    this.color,
    this.action,
    this.onOpened,
  });
}
