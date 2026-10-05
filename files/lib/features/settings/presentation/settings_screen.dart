import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../ui/surface.dart';
import '../../../ui/tokens.dart';
import '../../../ui/workspace_shell.dart';
import '../application/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => WorkspaceShell(
    name: ref.watch(appConfigProvider).name,
    section: WorkspaceSection.settings,
    title: 'Make it yours.',
    subtitle: 'A familiar space, in the light that suits you.',
    onNotes: () => context.go('/'),
    onSettings: () {},
    onBack: () => context.canPop() ? context.pop() : context.go('/'),
    children: [
      AppSurface(
        blur: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.brightness_4_outlined,
              size: 28,
              color: UiColors(context).accent,
            ),
            const SizedBox(height: 20),
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Follow your device, or choose your own look.',
              style: TextStyle(color: UiColors(context).muted),
            ),
            const SizedBox(height: 24),
            ref
                .watch(settingsControllerProvider)
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Column(
                    children: [
                      const Text('Could not load settings.'),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(settingsControllerProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                  data: (mode) => DropdownButtonFormField<ThemeMode>(
                    initialValue: mode,
                    decoration: const InputDecoration(labelText: 'Color mode'),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      try {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setTheme(value);
                      } on Exception {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not save appearance.'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
          ],
        ),
      ),
    ],
  );
}
