import 'package:flutter/material.dart';

import 'design.dart';

/// Shared semantic colors. Features never choose their own glass opacity.
class UiColors {
  UiColors(BuildContext context)
    : dark = Theme.of(context).brightness == Brightness.dark,
      scheme = Theme.of(context).colorScheme,
      solid =
          MediaQuery.highContrastOf(context) ||
          MediaQuery.accessibleNavigationOf(context);

  final bool dark;
  final ColorScheme scheme;
  final bool solid;

  Color get panel => useGlass && !solid
      ? (dark ? const Color(0xAC223542) : const Color(0xA6FFFFFF))
      : scheme.surfaceContainerLow;
  Color get line => dark ? const Color(0xFF49616F) : const Color(0xFFD7E4E9);
  Color get muted => dark ? const Color(0xFFB7CAD3) : const Color(0xFF536F7C);
  Color get accent => dark ? const Color(0xFF8EDBE4) : const Color(0xFF176D80);
  Color get inset => dark ? const Color(0xFF203644) : const Color(0xFFEAF2F5);
}
