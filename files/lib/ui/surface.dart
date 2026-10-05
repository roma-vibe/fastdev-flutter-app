import 'dart:ui';

import 'package:flutter/material.dart';

import 'design.dart';
import 'styled_panel.dart';
import 'tokens.dart';

/// Blur only the shell/composer, never every item in a scrolling collection.
class AppSurface extends StatelessWidget {
  const AppSurface({required this.child, this.blur = false, super.key});
  final Widget child;
  final bool blur;

  @override
  Widget build(BuildContext context) {
    final colors = UiColors(context);
    final content = StyledPanel(child: child);
    final glass = useGlass && !colors.solid;
    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: glass && blur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: content,
            )
          : content,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: glass
            ? [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: colors.dark ? .12 : .045,
                  ),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          panel,
          if (glass)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: colors.dark ? .16 : .65,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
