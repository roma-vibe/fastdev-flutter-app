import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:app/app/app.dart';
import 'package:app/core/config/app_config.dart';
import 'package:app/features/notes/data/preferences_notes_repository.dart';
import 'package:app/features/settings/application/settings_controller.dart';

import 'support/fakes.dart';

void main() {
  setUp(
    () => SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty(),
  );
  testWidgets(
    'adds and deletes notes, navigates to settings and switches theme',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(
              const AppConfig(name: 'Test "Shop" Магазин', slug: 'test-shop'),
            ),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test "Shop" Магазин'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'A new idea');
      await tester.tap(find.text('Add note'));
      await tester.pumpAndSettle();
      expect(find.text('A new idea'), findsOneWidget);
      await tester.ensureVisible(
        find.widgetWithIcon(IconButton, Icons.delete_outline_rounded),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete note'));
      await tester.pumpAndSettle();
      expect(find.text('A new idea'), findsNothing);
      await tester.scrollUntilVisible(
        find.byTooltip('Settings'),
        -120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      );
      expect(
        container.read(settingsControllerProvider).requireValue,
        ThemeMode.dark,
      );
      container.invalidate(settingsControllerProvider);
      expect(
        await container.read(settingsControllerProvider.future),
        ThemeMode.dark,
      );
    },
  );
  testWidgets('small screens stay usable with the keyboard open', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(name: 'Small app', slug: 'small'),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(TextField),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mobile idea');
    await tester.scrollUntilVisible(
      find.text('Add note'),
      80,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();
    // Overflow errors are reported by the binding.
    await tester.scrollUntilVisible(
      find.text('Mobile idea'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Mobile idea'), findsOneWidget);
  });
  testWidgets('shows load errors with a working retry', (tester) async {
    final repository = FakeNotesRepository()..failLoad = true;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(name: 'Test', slug: 'test'),
          ),
          notesRepositoryProvider.overrideWithValue(repository),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    repository.failLoad = false;
    await tester.ensureVisible(find.text('Retry'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.text('No notes yet. Add your first idea above.'),
      findsOneWidget,
    );
  });
}
