import 'package:flutter/material.dart';

import 'surface.dart';
import 'tokens.dart';
import 'wallpaper.dart';

enum WorkspaceSection { notes, settings }

/// Presentation only: routing and providers stay in the feature screens.
class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({
    required this.name,
    required this.section,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.onNotes,
    required this.onSettings,
    this.onBack,
    super.key,
  });

  final String name;
  final WorkspaceSection section;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback onNotes;
  final VoidCallback onSettings;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = UiColors(context);
    return Wallpaper(
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= 960 && constraints.maxHeight >= 560;
              final content = ListView(
                padding: EdgeInsets.all(wide ? 40 : 20),
                children: [
                  if (!wide) ...[
                    Row(
                      children: [
                        if (onBack != null)
                          IconButton(
                            tooltip: 'Back',
                            onPressed: onBack,
                            icon: const Icon(Icons.arrow_back_rounded),
                          )
                        else
                          const _AppMark(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (section == WorkspaceSection.notes)
                          IconButton(
                            tooltip: 'Settings',
                            onPressed: onSettings,
                            icon: const Icon(Icons.tune_rounded),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Workspace / ${section == WorkspaceSection.notes ? 'Notes' : 'Settings'}',
                          style: TextStyle(color: colors.muted, fontSize: 13),
                        ),
                      ),
                      if (wide)
                        Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: colors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'On this device',
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(title, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colors.muted,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...children,
                  const SizedBox(height: 24),
                ],
              );
              return Row(
                children: [
                  if (wide)
                    SizedBox(
                      width: 268,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
                        child: AppSurface(
                          blur: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _AppMark(),
                              const SizedBox(height: 20),
                              Tooltip(
                                message: name,
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'A space of your own',
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 40),
                              _NavItem(
                                label: 'Notes',
                                icon: Icons.notes_rounded,
                                selected: section == WorkspaceSection.notes,
                                onPressed: onNotes,
                              ),
                              const SizedBox(height: 8),
                              _NavItem(
                                label: 'Settings',
                                icon: Icons.tune_rounded,
                                selected: section == WorkspaceSection.settings,
                                onPressed: onSettings,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.cloud_off_rounded,
                                size: 22,
                                color: colors.muted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Your ideas, close by.',
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Notes are saved locally\non this device.',
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 12,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: content,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF86D4D9), Color(0xFF23637E)],
      ),
      border: Border.all(color: Colors.white.withValues(alpha: .65)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2212445C),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: const Icon(Icons.edit_note_rounded, size: 28, color: Colors.white),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      selected: selected,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: selected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : UiColors(context).muted,
          backgroundColor: selected
              ? Theme.of(context).colorScheme.primaryContainer
                    .withValues(alpha: .7)
              : Colors.transparent,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
