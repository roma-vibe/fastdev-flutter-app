import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/config.dart';

void main() {
  test('dotenv preserves quotes, Unicode, backslashes and literal dollars', () {
    const parser = LiteralEnvParser();
    expect(
      parser.parse(["APP_NAME='Test \"Shop\" Магазин \u0024USER'"])['APP_NAME'],
      'Test "Shop" Магазин \u0024USER',
    );
    expect(
      parser.parse([
        r'''APP_NAME="Tom's \"Shop\" $USER \\ путь"''',
      ])['APP_NAME'],
      r'''Tom's "Shop" $USER \ путь''',
    );
    expect(parser.parse(["APP_NAME='A # shop'"])['APP_NAME'], 'A # shop');
  });
  test('validates config and emits only public compile-time values', () {
    final env = {
      'APP_NAME': 'Name',
      'APP_SLUG': '123-shop',
      'APP_IDENTIFIER': 'com.example.fd123.fdshop',
      'WEB_PORT': '8410',
      'SECRET': 'must-not-ship',
    };
    expect(ProjectConfig(env).publicDefines, {
      'APP_NAME': 'Name',
      'APP_SLUG': '123-shop',
    });
    expect(
      () => ProjectConfig({...env, 'WEB_PORT': '12'}),
      throwsFormatException,
    );
    expect(
      () => ProjectConfig({...env, 'APP_IDENTIFIER': 'bad id'}),
      throwsFormatException,
    );
    expect(
      () => ProjectConfig({...env, 'APP_NAME': ''}),
      throwsFormatException,
    );
  });
  test(
    'configuration encodes native and web names without leaking secrets',
    () {
      final root = Directory.systemTemp.createTempSync('app-config-test-');
      addTearDown(() => root.deleteSync(recursive: true));
      final plist = File('${root.path}/ios/Runner/Info.plist')
        ..parent.createSync(recursive: true);
      plist.writeAsStringSync(
        '<key>CFBundleDisplayName</key><string>App</string><key>CFBundleName</key><string>app</string>',
      );
      final index = File('${root.path}/web/index.html')
        ..parent.createSync(recursive: true);
      index.writeAsStringSync('<title>App</title>');
      const name = r'''Tom's "Shop" & <Магазин> $USER''';
      final config = ProjectConfig({
        'APP_NAME': name,
        'APP_SLUG': 'test',
        'APP_IDENTIFIER': 'com.example.fdtest',
        'WEB_PORT': '8410',
        'SECRET': 'private',
      });
      configureProject(config, root: root.path);
      expect(
        jsonDecode(
          File('${root.path}/build/config/public.json').readAsStringSync(),
        ),
        {'APP_NAME': name, 'APP_SLUG': 'test'},
      );
      expect(
        (jsonDecode(File('${root.path}/web/manifest.json').readAsStringSync())
            as Map<String, dynamic>)['name'],
        name,
      );
      expect(plist.readAsStringSync(), contains('&amp; &lt;Магазин&gt;'));
      expect(index.readAsStringSync(), contains('&lt;Магазин&gt;'));
      expect(
        File('${root.path}/android/app/src/main/res/values/app_name.xml')
            .readAsStringSync(),
        contains(r'''Tom\'s \"Shop\"'''),
      );
      configureProject(config, root: root.path);
      expect(plist.readAsStringSync(), isNot(contains('&amp;amp;')));
    },
  );
  test('configuration keeps edited web manifest fields', () {
    final root = Directory.systemTemp.createTempSync('app-config-test-');
    addTearDown(() => root.deleteSync(recursive: true));
    File('${root.path}/web/manifest.json')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
        '{"name": "Old", "short_name": "Old", "theme_color": "#123456"}',
      );
    configureProject(
      ProjectConfig({
        'APP_NAME': '@home ?app',
        'APP_SLUG': 'home',
        'APP_IDENTIFIER': 'com.example.fdhome',
        'WEB_PORT': '8410',
      }),
      root: root.path,
    );
    expect(
      jsonDecode(File('${root.path}/web/manifest.json').readAsStringSync()),
      {
        'name': '@home ?app',
        'short_name': '@home ?app',
        'theme_color': '#123456',
      },
    );
    expect(
      File('${root.path}/android/app/src/main/res/values/app_name.xml')
          .readAsStringSync(),
      contains('>\\@home ?app<'),
    );
  });
}
