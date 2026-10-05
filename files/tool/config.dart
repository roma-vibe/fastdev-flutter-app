import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:dotenv/src/parser.dart';

// DotEnv.load accepts this parser in its public API. Keep configuration literal:
// names must never expand shell variables. Decode fastDev's double-quote escapes.
class LiteralEnvParser extends Parser {
  const LiteralEnvParser();
  @override
  String interpolate(String val, Map<String, String> env) =>
      val.replaceAllMapped(
        RegExp(r'\\(.)'),
        (match) => match[1] == 'n' ? '\n' : match[1]!,
      );
}

class ProjectConfig {
  ProjectConfig(Map<String, String> env)
    : name = _required(env, 'APP_NAME'),
      slug = _required(env, 'APP_SLUG'),
      identifier = _required(env, 'APP_IDENTIFIER'),
      port = int.parse(_required(env, 'WEB_PORT')) {
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
      throw const FormatException(
        'APP_SLUG must contain lowercase letters, digits and single dashes.',
      );
    }
    if (!RegExp(r'^[a-z][a-z0-9]*(?:\.[a-z][a-z0-9]*)+$')
        .hasMatch(identifier)) {
      throw const FormatException(
        'APP_IDENTIFIER must be a reverse-domain identifier.',
      );
    }
    if (name.contains('\n') ||
        name.contains('\r') ||
        port < 1024 ||
        port > 65535) {
      throw const FormatException(
        'APP_NAME must be one line and WEB_PORT must be between 1024 and 65535.',
      );
    }
  }
  factory ProjectConfig.load([String path = '.env']) {
    if (!File(path).existsSync()) {
      throw StateError('Missing $path. Copy .env.example to .env first.');
    }
    final env = DotEnv()..load([path], const LiteralEnvParser());
    return ProjectConfig({
      for (final key in ['APP_NAME', 'APP_SLUG', 'APP_IDENTIFIER', 'WEB_PORT'])
        key: env[key] ?? '',
    });
  }
  static String _required(Map<String, String> env, String key) {
    final value = env[key];
    if (value == null || value.trim().isEmpty) {
      throw FormatException('$key is required.');
    }
    return value;
  }

  final String name;
  final String slug;
  final String identifier;
  final int port;
  Map<String, String> get publicDefines => {'APP_NAME': name, 'APP_SLUG': slug};
}

String xmlEscape(String value) =>
    const HtmlEscape(HtmlEscapeMode.element).convert(value);
void configureProject(ProjectConfig config, {String root = '.'}) {
  void write(String path, String value) {
    final file = File('$root/$path');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(value);
  }

  write(
    'build/config/public.json',
    '${const JsonEncoder.withIndent('  ').convert(config.publicDefines)}\n',
  );
  final androidName = config.name
      .replaceAll('\\', '\\\\')
      .replaceAll("'", "\\'")
      .replaceAll('"', '\\"')
      // A leading @ or ? would make the string a resource or theme reference.
      .replaceFirst(RegExp('^(?=[@?])'), '\\');
  write(
    'android/app/src/main/res/values/app_name.xml',
    '<?xml version="1.0" encoding="utf-8"?>\n<resources><string name="app_name">${xmlEscape(androidName)}</string></resources>\n',
  );
  write(
    'android/app/app-config.properties',
    'applicationId=${config.identifier}\n',
  );
  write(
    'ios/Flutter/AppConfig.xcconfig',
    'APP_BUNDLE_ID = ${config.identifier}\n',
  );
  final project = File('$root/ios/Runner.xcodeproj/project.pbxproj');
  if (project.existsSync()) {
    project.writeAsStringSync(
      project.readAsStringSync().replaceAllMapped(
        RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;'),
        (match) =>
            'PRODUCT_BUNDLE_IDENTIFIER = ${config.identifier}${match[0]!.contains('RunnerTests') ? '.RunnerTests' : ''};',
      ),
    );
  }
  final plist = File('$root/ios/Runner/Info.plist');
  if (plist.existsSync()) {
    var content = plist.readAsStringSync();
    for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
      content = content.replaceAllMapped(
        RegExp('<key>$key</key>\\s*<string>[^<]*</string>'),
        (match) =>
            '<key>$key</key>\n\t<string>${xmlEscape(config.name)}</string>',
      );
    }
    plist.writeAsStringSync(content);
  }
  // Only the names come from .env; keep every other web manifest field as edited.
  final manifestFile = File('$root/web/manifest.json');
  final manifest = manifestFile.existsSync()
      ? Map<String, Object?>.from(
          jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>,
        )
      : <String, Object?>{
          'name': config.name,
          'short_name': config.name,
          'start_url': '.',
          'display': 'standalone',
          'background_color': '#faf8ff',
          'theme_color': '#5262cf',
          'description': 'Your personal notes app.',
          'icons': [
            {
              'src': 'icons/Icon-192.png',
              'sizes': '192x192',
              'type': 'image/png',
            },
            {
              'src': 'icons/Icon-512.png',
              'sizes': '512x512',
              'type': 'image/png',
            },
          ],
        };
  manifest
    ..['name'] = config.name
    ..['short_name'] = config.name;
  write(
    'web/manifest.json',
    '${const JsonEncoder.withIndent('  ').convert(manifest)}\n',
  );
  final index = File('$root/web/index.html');
  if (index.existsSync()) {
    index.writeAsStringSync(
      index.readAsStringSync().replaceAll(
        RegExp(r'<title>[^<]*</title>'),
        '<title>${xmlEscape(config.name)}</title>',
      ),
    );
  }
}
