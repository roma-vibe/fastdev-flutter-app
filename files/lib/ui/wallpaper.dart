import 'package:flutter/material.dart';

import 'design.dart';

/// Painted gradients stay local and deterministic on web and mobile.
class Wallpaper extends StatelessWidget {
  const Wallpaper({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surface,
    child: useGlass && !MediaQuery.highContrastOf(context)
        ? DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context).brightness == Brightness.dark
                    ? const [
                        Color(0xFF163E50),
                        Color(0xFF112433),
                        Color(0xFF234C51),
                      ]
                    : const [
                        Color(0xFFD6EEF1),
                        Color(0xFFF1F4EF),
                        Color(0xFFC8DDEB),
                      ],
              ),
            ),
            child: CustomPaint(
              painter: _WallpaperPainter(
                Theme.of(context).brightness == Brightness.dark,
              ),
              child: child,
            ),
          )
        : child,
  );
}

class _WallpaperPainter extends CustomPainter {
  const _WallpaperPainter(this.dark);
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .85, size.height * .12);
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                (dark ? const Color(0xFF4F8491) : Colors.white).withValues(
                  alpha: .75,
                ),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.width * .65),
            ),
    );
    final wave = Path()
      ..moveTo(-80, size.height * .78)
      ..cubicTo(
        size.width * .35,
        size.height * .15,
        size.width * .60,
        size.height * 1.05,
        size.width + 80,
        size.height * .42,
      );
    for (var index = 0; index < 18; index++) {
      canvas.drawPath(
        wave.shift(Offset(0, index * 13)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = (dark ? Colors.white : const Color(0xFF3A7286)).withValues(
            alpha: dark ? .035 : .055,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_WallpaperPainter oldDelegate) => dark != oldDelegate.dark;
}
