import 'package:anxeb_flutter/middleware/scope.dart';
import 'package:flutter/material.dart';

class CaptionBlock extends StatelessWidget {
  final Scope scope;
  final String title;
  final String? trailTitle;
  final EdgeInsets? margin;
  final IconData? icon;
  final double? iconSize;
  final bool visible;

  const CaptionBlock({
    required this.scope,
    required this.title,
    this.trailTitle,
    this.margin,
    this.icon,
    this.iconSize,
    this.visible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final colors = scope.application.settings.colors;

    return Container(
      margin: margin,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 5, top: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.5, color: colors.primary),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null)
                    SizedBox(
                      width: 33,
                      child: Icon(
                        icon,
                        size: iconSize ?? 25,
                        color: colors.primary,
                      ),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        color: colors.secudary,
                      ),
                    ),
                  ),
                  if (trailTitle != null && trailTitle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        trailTitle!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.text.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
