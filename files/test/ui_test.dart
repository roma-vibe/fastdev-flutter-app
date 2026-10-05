import 'package:app/app/theme.dart';
import 'package:app/ui/design.dart';
import 'package:app/ui/surface.dart';
import 'package:app/ui/tokens.dart';
import 'package:app/ui/workspace_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wide navigation exposes both routes with selected semantics', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 820);
    addTearDown(tester.view.reset);
    var settingsCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: WorkspaceShell(
          name: 'Workspace with a very long product name',
          section: WorkspaceSection.notes,
          title: 'Your notes',
          subtitle: 'Capture an idea.',
          onNotes: () {},
          onSettings: () => settingsCalls++,
          children: const [AppSurface(child: Text('Content'))],
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    expect(settingsCalls, 1);
    expect(find.text('Notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact settings supports enlarged text and back navigation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    var backCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme(Brightness.dark),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: WorkspaceShell(
            name: 'A very long name with Магазин and punctuation',
            section: WorkspaceSection.settings,
            title: 'Make it yours.',
            subtitle: 'Choose your appearance.',
            onNotes: () {},
            onSettings: () {},
            onBack: () => backCalls++,
            children: const [AppSurface(child: Text('Appearance settings'))],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    expect(backCalls, 1);
    await tester.scrollUntilVisible(
      find.text('Appearance settings'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'accessible navigation and high contrast use opaque surfaces without blur',
    (tester) async {
      for (final accessibility in [
        const MediaQueryData(highContrast: true),
        const MediaQueryData(accessibleNavigation: true),
        const MediaQueryData(),
      ]) {
        Color? panelColor;
        await tester.pumpWidget(
          MaterialApp(
            theme: appTheme(Brightness.light),
            home: MediaQuery(
              data: accessibility,
              child: Builder(
                builder: (context) {
                  panelColor = UiColors(context).panel;
                  return const AppSurface(
                    blur: true,
                    child: Text('Readable content'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final solid =
            accessibility.highContrast ||
            accessibility.accessibleNavigation ||
            !useGlass;
        expect(
          find.byType(BackdropFilter),
          solid ? findsNothing : findsOneWidget,
        );
        if (solid) expect(panelColor!.a, 1);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
